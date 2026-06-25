# File I/O: handle table, sequential streams, and random-access records

GW-BASIC programs talk to disk through *file channels* — small integers
(`1`..`255`) bound to an open file by `OPEN`. Everything else — `PRINT #`,
`INPUT #`, `GET`, `PUT`, `EOF`, `LOC` — refers to the channel, never the
path. To make that work in batch we need a place to remember "channel 1 is
this path, opened for input, currently N lines in." There is no process
with open descriptors here: every RTL handler is a fresh `cmd.exe` that
exits when the statement finishes. So all the per-channel state lives in
**files under `temp/`**, and the subsystem is a thin set of helpers that
read, mutate, and rewrite them.

This page covers the lot: the handle table; the three `OPEN` spellings;
the sequential write/read family (`PRINT #` / `WRITE #` / `INPUT #` /
`LINE INPUT #`) plus `EOF` / `LOF`; raw-byte `INPUT$(n,#f)` and `LOC`; the
random-access `FIELD` / `LSET` / `RSET` / `GET` / `PUT` *live-window*
machinery; and the `MKI$`…`MKD$` ↔ `CVI`…`CVD` binary codecs that pack
numbers into record fields. The keystone for almost all of it is
`src/exec/_files.bat`.

## Calling convention recap

Every statement and function handler in `src/rtl/` takes the name of a
postfix **stack vector** as `%1`, pops its operands with `vec pop`,
resolves any `VAR_`/`STR_`/`NUM_` tokens through `src/exec/_resolve.bat`,
does its work, and returns the (usually unchanged) stack via the standard

```
endlocal & set "%~1=%_final%" & exit /B <gwcode>
```

idiom. The `exit /B` code is a GW-BASIC error number (`0` = ok). See
the executor/RTL notes (README entry *07 — Executor & RTL*) and
[01 — Architecture](01-architecture.md) for the dispatch loop and the
tagged-value convention. Each file handler defines its own copy of the same
private `:_toInt` helper (a copied idiom, not one shared routine) that turns a
resolved `i`/`s`/`d` tagged value into a plain decimal channel number.

## The handle table — `temp/files.dat`

`src/exec/_files.bat` owns one file, `temp/files.dat`, with **one line per
open channel**:

```
@REM N=MODE POS RECLEN HEXPATH
@REM   N        file number 1..255 (the key, before '=')
@REM   MODE     O output / I input / A append / R random
@REM   POS      byte offset (sequential) or current record (random), 0-based
@REM   RECLEN   record length (random) else 0
@REM   HEXPATH  hex-encoded OS path (str encode) so spaces/&/|/<> survive
```

The path is stored as **hex** because OS paths routinely contain `&`, `|`,
`<`, `>`, spaces, and `^` — all of which would wreck a `for /f` rewrite of
a plain-text line. Crucially the hex is the *lexer's* case-correct hex
(passed straight through by `_doopen`), not a re-encode through
`str encode`, which uppercases (lossy) and would break case-sensitive
filesystems and `..\..` resolution.

`_files.bat` is a labelled dispatcher (`goto :%_ffn%`). The operations:

| Op | What it does |
|---|---|
| `init` / `clear` / `closeall` | Truncate `files.dat`; **also** clear `fields.dat`, `recbuf_*.hex`, `bpos_*.dat` (see the leak war story). |
| `open N MODE RECLEN HEXPATH` | Append a row. `55` if already open, `53` if an `I`-mode file is missing; `O` truncates, `A`/`R` create-if-absent. |
| `close N` | Rewrite `files.dat` minus row N; drop its `bpos_N.dat`. |
| `isopen N` | errorlevel `0`/`1`. |
| `get N PREFIX` | Split row N into `<PREFIX>mode/pos/reclen/path` (path decoded). `52` if not open. |
| `setpos N POS` | Rewrite only the `POS` field of row N. |
| `readseq` / `atEof` / `lof` | Sequential line read, end-of-data test, byte size (below). |
| `binpos` / `setbinpos` | The separate raw-byte cursor for `INPUT$` (below). |
| `filehex` / `writehex` | Whole-file ↔ uppercase-hex, via `certutil -encodehex … 12` / `-decodehex`. |
| `bufinit` / `bufget` / `bufput` | The per-handle record buffer for random access. |
| `freg` / `fget` / `fdel` | The `FIELD` registry. |

### `OPEN`: three spellings, one back end

The lexer/parser accept GW's three `OPEN` syntaxes, and each gets its own
tiny handler that unpacks a differently-shaped stack and calls
`src/exec/_doopen.bat`: `OPEN_FO`/`OPEN_FI`/`OPEN_FA` for the verbose
`OPEN file FOR OUTPUT|INPUT|APPEND AS [#]chan` form (modes `O`/`I`/`A`);
`OPEN_R` for the random `OPEN file AS [#]chan [LEN= reclen]` form (mode
`R`); and `OPEN_M` for the mode-comma form `OPEN modeStr, [#]chan, file
[, reclen]`, which decodes the leading mode character (defaulting to `R`).

`_doopen` is where the real validation happens: resolve and range-check
the channel (`52` outside `1..255`), require a `STR_` filename (`64`
otherwise), default `R`'s record length to `128`, then call
`_files open`. Note it deliberately keeps the lexer's path hex rather than
re-encoding:

```
@REM Pass the lexer's case-correct hex straight through; re-encoding the path
@REM via `str encode` would uppercase it (lossy) and break case-sensitive
@REM filesystems and ..\.. resolution.
set "_fthex=!_ft:~4!"
```

## Sequential I/O

### Writing — `PRINT #` / `WRITE #`

There is no separate "print to file" code. `PRINT #n` and `WRITE #n` reuse
the *exact same* `PRINT`/`WRITE` formatter family, redirected by a sink
variable. The grammar emits a `PFILE_SET` action before the print items;
`src/rtl/PFILE_SET.bat` looks the channel up, refuses an input-mode
channel (`54`) or an unopened one (`52`), and sets `_print_path` to the
file:

```
endlocal & set "%~1=%_final%" & set "_print_path=%_hpath%" & set "_print_col=0" & exit /B 0
```

With `_print_path` set, `src/exec/_pemit.bat` appends formatted text to the
file (through `str decodePrint`, so leading spaces and the trailing CRLF
survive — a bare newline echoed to a file emits nothing on the cmd port).
`WRITE`/`PRINT` clear `_print_path` when they finish, so the next plain
`PRINT` returns to the console. `WRITE #` differs only in formatting:
strings double-quoted (`22`), fields comma-separated (`2C`), numbers
without a leading space.

### Reading — `INPUT #` / `LINE INPUT #` and `readseq`

The mirror image: an `IFILE_SET` action verifies the channel is open
*for input* (`54`/`52` otherwise) and sets `_input_fh`. `INPUT.bat` and
`LINE_INPUT.bat` both branch on `_input_fh` to pull a line from the file
instead of the console:

```
if defined _input_fh goto :_inp_fromfile
...
:_inp_fromfile
call %GWSRC%\exec\_files readseq !_input_fh! _lh _feof
```

`:readseq` is the line engine. It hexes the whole file (`certutil`),
uppercases the hex, collapses `0D0A` to a single `0A` and strips any remaining
bare `0D` (a lone CR is removed, not turned into a line break), then walks the
hex two chars at a time counting `0A` line breaks until it reaches the line
index in the handle's `POS`. It returns that line as hex (so quoted fields
and embedded commas survive — `INPUT #` splits at the hex level via
`_takeFieldHex`) and advances `POS`. `INPUT #` with several variables
refills from the next line when the current one is spent; running out
mid-list raises `62` (Input past end).

### `EOF` and `LOF`

`EOF(n)` (`src/rtl/FN_EOF.bat`) delegates to `:atEof` (`-1`/`0`, pushed as
an `int`). Its line path peeks the next line with `readseq` then *undoes*
the `POS` advance via `setpos`, so the peek is non-destructive. `LOF(n)`
(`FN_LOF.bat`) returns the file's byte size from `:lof` (which reads
`%%~zS` of the decoded path), pushed as a single.

### Raw bytes — `INPUT$(n,#f)` and `LOC`

`INPUT$(n,#f)` reads exactly *n raw bytes*, and it must not be confused by
the line-based `POS`. It keeps a **separate** byte cursor per handle in
`temp/bpos_<n>.dat`, read/written by `:binpos` / `:setbinpos`. The handler
hexes the file, slices `n` bytes at `cursor*2`, advances the cursor with
`setbinpos`, and pushes the bytes as `STR_<hex>`.

The payoff is that `:atEof` becomes **byte-aware** once that cursor file
exists: it compares the byte cursor against `LOF` instead of peeking a
line. That makes the classic copy loop terminate correctly:

```
10 IF EOF(1) THEN 70
20 C$=INPUT$(1,#1) : ... : GOTO 10
```

`LOC(n)` (`FN_LOC.bat`) simply returns the handle's `POS` field as a
single — for a random file that is the record number of the last
`GET`/`PUT`; for sequential input it is the count of lines read. Both meanings
share the one field.

## Random-access records: the live-window model

This is the subtle part. After `OPEN "R"`, `FIELD #n, w1 AS v1$, ...`
declares string variables to be **live windows** onto a fixed record
buffer. Reading `v1$` does not read a stored value — it reads a *slice of
the current record buffer*. The implementation (called *Architecture A* in
the source) has three pieces:

- a per-handle record buffer `temp/recbuf_<n>.hex` — `RECLEN` bytes as one line of uppercase hex, space-filled (`20`) by `:bufinit`;
- a registry `temp/fields.dat`, rows `KEY N OFF WIDTH` where `KEY` is the field var's token (`VAR_STR_<base>`);
- one read hook in `src/exec/_resolve.bat`.

### `FIELD` registers windows

`FIELD.bat` pops the `(width, var)` pairs, creates the buffer if absent,
and walks the pairs in declaration order, registering each var at the
accumulating byte offset via `:freg`:

```
:_fld_reg
  for /f "tokens=1,2,*" %%a in ("!_pairs!") do (set "_w=%%a" & set "_v=%%b" & set "_pairs=%%c")
  call %GWSRC%\exec\_files freg !_v! !_n! !_off! !_w!
  set /a "_off+=_w"
```

`:freg` *replaces* any existing row for that key, so re-`FIELD`ing the same
handle with overlapping widths just rebinds the windows — aliased views
over one buffer coexist. (The dense GW form `5ASO1$`, where width, `AS`,
and the var are glued together, is split apart earlier at the lexer; see
[04 — Lexer](04-lexer.md).)

### `_resolve` is the one read hook

The only place a field var becomes its buffer slice is `_resolve.bat`. It
is on the hot path of *every* variable read, so it is gated on
`fields.dat` even existing before it does any registry work:

```
if not exist "%GWTEMP%\fields.dat" goto :_res_var
call %GWSRC%\exec\_files fget !_v! _ff
if errorlevel 1 goto :_res_var
call %GWSRC%\exec\_files bufget !_ffn! _fbuf
set /a "_p=_ffoff*2"
set /a "_len=_ffwidth*2"
set "_r=STR_!_fbuf:~%_p%,%_len%!"
```

A registered var resolves to `STR_<that slice>`; an unregistered one falls
through to the ordinary `_vars get`.

### `LSET` / `RSET` write into the buffer

`LSET v$=expr` / `RSET v$=expr` look the field up with `:fget`; on a hit
they build exactly `WIDTH` bytes of hex — left-justified (`LSET`) or
right-justified (`RSET`), space-padded or truncated — and splice them into
the buffer at the field's byte offset, then `bufput`:

```
set "_field=!_take!!_pad!"          @REM LSET: value then padding (RSET reverses)
call %GWSRC%\exec\_files bufget !_fn! _buf
set /a "_p=_foff*2"
set /a "_aft=_p+_max"
set "_buf=!_buf:~0,%_p%!!_field!!_buf:~%_aft%!"
call %GWSRC%\exec\_files bufput !_fn! !_buf!
```

If the target is *not* a field var, both fall back to a plain
`_vars set` — matching GW, where `LSET` on an ordinary string just
left-justifies into it.

### `GET` / `PUT` move records by hex seek

`GET #n[, rec]` reads record `rec` (default current+1) by hexing the whole
file (`filehex`), slicing `RECLEN` bytes at the byte offset
`(rec-1)*RECLEN*2`, padding short or past-EOF reads with spaces, and
`bufput`-ing the slice:

```
call %GWSRC%\exec\_files filehex !_n! _all
set /a "_off=(_r-1)*_hreclen*2"
set /a "_len=_hreclen*2"
set "_slice=!_all:~%_off%,%_len%!"
```

`PUT #n[, rec]` is the inverse — splice the buffer into the whole-file hex
at the same offset, extending with spaces if the record is past the current
end, then `writehex`. Both update `POS` to `rec` (which is what `LOC`
reports).

### Detach on plain assignment

In GW, a plain assignment to a `FIELD`ed var unbinds it from the buffer.
`ASSIGN.bat` honours that by deleting the registry row before storing the
ordinary value:

```
@REM FIELD detach: a plain assignment to a FIELDed variable unbinds it from
@REM the record buffer (GW semantics) — drop its registry row, then store the
@REM ordinary value.
if exist "%GWTEMP%\fields.dat" call %GWSRC%\exec\_files fdel !_var!
call %GWSRC%\exec\_vars set !_var! !_val!
```

## The `MK*` / `CV*` codecs

Numbers go into fixed-width fields as binary strings. `MKI$`/`MKS$`/`MKD$`
pack; `CVI`/`CVS`/`CVD` unpack. They bridge our tagged numeric format and
the on-disk MBF layout:

- `MKI$` / `CVI` — the 2-byte signed int. Our `int` hex is big-endian (`HH LL`); disk order is little-endian, so `MKI$` swaps to `LL HH` and `CVI` swaps back.
- `MKS$` / `CVS` (4 bytes) and `MKD$` / `CVD` (8 bytes) — MBF single/double, mantissa little-endian with the exponent byte last. Our internal MBF uses **bias 128**; the disk format uses **bias 129**, so `MK*` increments the exponent byte (`_xbyte inc`) and `CV*` decrements it (`_xbyte dec`). A zero exponent (`00`) is the all-zero value and is short-circuited.

Because they touch `_xbyte` (which reaches `_xhalf` via `PATH`), the MBF
codecs must put the num dir on `PATH` first or the bias inc/dec won't
resolve:

```
@REM _xbyte calls _xhalf via PATH; add the num dir so the bias inc/dec resolve.
set "PATH=%GWSRC%\num;%PATH%"
```

A full round-trip — `LSET S$=MKS$(95.5) : PUT … : GET … : CVS(S$)` — keeps
the value bit-faithful through the buffer, the disk hex, and back.

## Problems & gotchas

**The leaking live window.** The nastiest bug the subsystem hit.
`_files init`/`closeall` originally truncated only `files.dat`. But
`_resolve` intercepts *any* read of a var whose token is still in
`fields.dat`. So a program that `FIELD`ed `S$`, then later — after closing
the file — used a plain variable also named `S$`, got the *stale
record-buffer slice* instead of its real value, because the registry row
outlived the file. The fix clears the field registry **and** the record
buffers (and byte cursors) whenever all handles are released:

```
:init
:clear
:closeall
  type nul > "%GWTEMP%\files.dat"
  if exist "%GWTEMP%\fields.dat" del "%GWTEMP%\fields.dat"
  del "%GWTEMP%\recbuf_*.hex" >nul 2>nul
  del "%GWTEMP%\bpos_*.dat" >nul 2>nul
```

**The `_v` collision.** `FIELD.bat`'s `:_toInt` helper runs *without*
`setlocal` (it has to set `__` in the caller's scope). An early version
reused `_v` as a scratch name — but `FIELD` itself uses `_v` to hold the
field-var token across the pop loop, so the helper clobbered it and
corrupted the registration. The helper now uses private names `_tiv`/`_tit`
and the comment spells out the hazard:

```
@REM No setlocal (must return __ in caller scope), so use private names
@REM _tiv/_tit — must NOT touch _v (FIELD reuses _v as the field-var token).
```

**Two cursors, one handle.** Sequential `POS` (a line index, or record
number for random) and the `INPUT$` byte cursor (`bpos_<n>.dat`) are
deliberately independent, so mixing line-`INPUT #` and `INPUT$` on one
channel will not keep them in lockstep — but that is exactly what lets the
byte-driven `EOF` copy loop terminate.

**Deferred limits.** Field vars with computed/subscripted widths
(`FIELD 1, 19+2*I AS FILL$(I)`) are not modelled — only literal-width
windows over named string vars. `GET`/`PUT` slurp the whole file into a hex
string in an env var, so there is an effective record/file size ceiling
around **~4 KB** before the hex string outgrows what `cmd.exe` will hold.

## How it is tested

`src/rtl/fileops.test.bat` is the end-to-end suite for the whole
subsystem. It asserts **both** the GW error code and the real filesystem
effect, with every path under `%GWTEMP%` so the working tree is never
touched. Highlights:

- `fileops.open.*` — the three OPEN forms, `53` (missing input), `55` (already open).
- `fileops.print.file.*` / `fileops.write.file.csv` / `fileops.print.input.mode.err54` — the redirected `PRINT #`/`WRITE #` family and the input-mode guard.
- `fileops.input.file.roundtrip` / `fileops.input.file.eofloop` / `fileops.lineinput.file` — sequential read and line-based `EOF`.
- `fn.loc.random.last.record`, `fn.inputdollar.file.exact.bytes`, `fn.inputdollar.eof.copies.all.bytes` — `LOC`, raw-byte `INPUT$`, the byte-aware-EOF copy loop.
- `fileops.record.numeric.roundtrip` (`MKS$`→`PUT`→`GET`→`CVS`), `fileops.field.dense.form`, `fileops.record.getmodifyput`, `fileops.record.norecord.advance`, `fileops.record.detach` — the random-access record path, codecs, and detach.

`src/exec/input.test.bat` covers the `INPUT` line-splitting engine that
`INPUT #` shares with the console.
