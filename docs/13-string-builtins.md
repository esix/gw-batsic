# String built-in functions

GW-BASIC's string functions — `LEN`, `VAL`, `STR$`, `ASC`, `CHR$`, `LEFT$`,
`RIGHT$`, `MID$`, `SPACE$`, `STRING$`, `INSTR`, `HEX$`, `OCT$` — are where the
hex-string representation earns its keep. A string never exists as raw
characters inside the interpreter: it is carried as a tagged value
`STR_<hex>`, two uppercase hex digits per byte (see
[03 — Strings & hex](03-strings-hex.md) for *why*). `"HELLO"` is
`STR_48454C4C4F`; the empty string is the bare tag `STR_` with nothing after
it. Because the payload is always in `[0-9A-F]`, no batch metacharacter ever
appears in it, so every function below can do its work with ordinary `set`
substring surgery and never has to escape `>`, `&`, `%` or a leading space.

The pleasant consequence is that almost every "string" operation is really
**hex arithmetic on character positions**. One character is two hex digits, so
a length is half the hex string's length, "first n characters" is "first 2n
hex digits", and "from position n" is "skip `(n-1)*2` hex digits". The
functions in this group are mostly thin shells of `set "_h=...:~off,len"`
around that one idea. The single place where characters have to become real
bytes again is output, and that goes through `str decodePrint`, the one path
hardened against batch eating `=`, `<`, `>`, `&`, `|`, `!` and leading spaces.

## Calling convention

Each function is one file under `src/rtl/`, named after the postfix token the
parser emits for it. The parser turns `LEN(A$)` into the postfix stream
`VAR_STR_A FN_LEN PEND`; `MID$(S$,2,3)` into
`VAR_STR_S NUM_i0002 NUM_i0003 FN_MID PEND`. The executor walks that stream,
pushing operands onto a stack vector and, for any token that has a matching
RTL file, dispatching to it:

```
if exist "%GWSRC%\rtl\!_tok!.bat" call %GWSRC%\rtl\!_tok!.bat _stk
```

So every RTL receives **one argument**: the *name* of the operand-stack vector
(here `_stk`). The handler pops its operands off the top, computes, and pushes
the result back. The shared skeleton is visible in every file:

```bat
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a          @REM topmost operand
call %GWSRC%\exec\_resolve !_a! _a        @REM VAR_ → its STR_/NUM_ value
...
call %GWSRC%\stl\vec push %_s% STR_!_out!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
```

`_resolve` turns a `VAR_…` reference into its stored value (and is a no-op on a
literal `STR_`/`NUM_`). The `endlocal & set "%~1=%_final%"` idiom hoists the
modified stack out of the local scope — `%_final%` is expanded at *parse* time,
before `endlocal` runs, so the inner value survives. This is the same
propagation pattern documented for the numerics layer in
[02 — Numerics](02-numerics.md#endlocal-propagation); the executor and RTL
dispatch itself is the subject of article 07 (Executor & RTL) in the
[docs index](README.md). Watch this idiom — it sets up the war story below.

The exit code is the GW-BASIC error number. Two recur throughout this group:

| Exit | GW-BASIC error | When |
|---|---|---|
| `0` | — | success |
| `5` | Illegal function call | `ASC("")`, negative length/count, `CHR$` out of `0..255`, `MID$` start `< 1` |
| `13` | Type mismatch | a string function handed a non-`STR_` operand (or the reverse) |

## How the members are implemented

### LEN, ASC — reading the hex back as positions and bytes

`FN_LEN` never decodes. It walks the hex two digits at a time and counts:

```bat
set "_h=!_a:~4!"
set /a "_n=0"
:_len_loop
  if "!_h!"=="" goto :_len_done
  set /a "_n+=1"
  set "_h=!_h:~2!"
  goto :_len_loop
```

The count is then re-tagged as an int with `num\int fromDec` and pushed. (A
batch substring length can't be read directly, hence the loop — the same shape
recurs as `:_rl_loop` in `FN_RIGHT` and the `:_hexlen` helper in `FN_INSTR` and
`MID_SET`. `FN_MID` needs no length count — it clamps via the `_rem:~0,%_take%`
slice instead.)

`FN_ASC` takes the first byte, i.e. the first hex pair, and turns it into a
number with a `0x` literal:

```bat
set "_h=!_a:~4!"
if "!_h!"=="" ( ... exit /B 5 )       @REM ASC("") → Illegal function call
set /a "_n=0x!_h:~0,2!"
```

### CHR$, STR$, VAL — crossing the number/string boundary

`FN_CHR` is the inverse of `ASC`: coerce the operand to an int (via the
type-tag dispatch `i`/`s`/`d` shared by every numeric-taking function here),
range-check `0..255`, and format the value as a single hex pair through the
`0123456789ABCDEF` nibble table:

```bat
set /a "_h1=!_n!/16"
set /a "_h2=!_n!%%16"
set "_HD=0123456789ABCDEF"
call set "_hh=%%_HD:~%_h1%,1%%%%_HD:~%_h2%,1%%"
```

`FN_STR` formats a number as its display string and, faithfully to GW-BASIC,
prepends a space placeholder for non-negative values (negatives already carry
their `-`):

```bat
if "!_d:~0,1!"=="-" (set "_txt=!_d!") else (set "_txt= !_d!")
...
call %GWSRC%\str\str encode "!_txt!" _hex
```

So `STR$(42)` is `" 42"` and `STR$(-5)` is `"-5"` — the leading-space rule that
makes `PRINT` line numbers up. `FN_VAL` goes the other way: it `decode`s the
hex to text, strips leading spaces, then greedily eats a leading
`[+-]?[0-9.]*` run and hands it to `num\sng fromDec`. Anything non-numeric (or
a bare sign) yields `0`, so `VAL("12XYZ")` is `12` and `VAL("abc")` is `0`.
The result is always single-precision.

### LEFT$, RIGHT$, MID$ — slicing by hex offset

These are the pure position arithmetic. `FN_LEFT` keeps the first `2n` hex
digits:

```bat
set /a "_take=_ni*2"
set "_out=!_h:~0,%_take%!"
```

`FN_MID` (the *function*) skips `(start-1)*2` and keeps `len*2`, clamped to
whatever remains:

```bat
set /a "_skip=(_startN-1)*2"
set /a "_take=_lenN*2"
set "_rem=!_h:~%_skip%!"
set "_out=!_rem:~0,%_take%!"
```

`FN_RIGHT` is the awkward one, because batch can't index "from the end" by a
computed offset cleanly — it has to know the total length first (the
`:_rl_loop` counter), then `set /a "_skip=_len-_take"` and slice. See the war
stories below for the two bugs that lived here.

### SPACE$, STRING$ — building hex by repetition

`FN_SPACE` is the simplest function in the project: append the pair `20` (the
space byte) `n` times in a loop. `FN_STRING` generalises it — the fill
argument may be a number (an ASCII code, formatted to a hex pair via the same
nibble table as `CHR$`) **or** a string (its first hex pair is taken), and
that one pair is repeated `n` times:

```bat
if "!_ch:~0,4!"=="STR_" (
  set "_body=!_ch:~4!"
  set "_pair=!_body:~0,2!"
) else (
  ...                          @REM number → nibble-table hex pair
)
```

So `STRING$(10,42)` and `STRING$(10,"*")` both give ten asterisks. A negative
count is `5` (Illegal function call).

### INSTR — search, with an optional start position

`INSTR` scans a hex window for a sub-window. The interesting part is the
two-form signature, covered under war stories. Once the start `_n`, haystack
hex `_xh` and needle hex `_yh` are sorted out, it slides a needle-wide window
across the haystack comparing hex segments:

```bat
set /a "_last=_lx-_ly+1"
set "_i=!_n!"
:_scan
  if !_i! GTR !_last! goto :_emit
  set /a "_off=(_i-1)*2"
  set /a "_w=_ly*2"
  for /f %%o in ("!_off!") do for /f %%w in ("!_w!") do set "_seg=!_xh:~%%o,%%w!"
  if /I "!_seg!"=="!_yh!" (set "_pos=!_i!" & goto :_emit)
```

The comparison is `/I` (case-insensitive) and positions are 1-based; not-found
emits `0`. An empty needle returns `_n` (GW-BASIC's documented behaviour).

### HEX$, OCT$ — radix formatting via set /a

Both convert the operand to its 4-char int hex first (the shared `:_toIHex`
helper strips the `i` tag off an `i<HHHH>` value). `HEX$` then just trims
leading zeros from that hex and encodes it as text:

```bat
:_hstrip
  if not "!_h:~0,1!"=="0" goto :_hdone
  if "!_h:~1!"=="" goto :_hdone
  set "_h=!_h:~1!"
  goto :_hstrip
call %GWSRC%\str\str encode "!_h!" _ph
```

`OCT$` reads that hex as a number with a `0x` literal, then emits octal digits
by repeated `% 8` / `/= 8` (`set /a "_dg=_u%%8"` … `set /a "_u/=8"`). Both
produce *digit strings*, which are then `str encode`d into the usual
`STR_<hex>` so the rest of the pipeline sees a normal string.

## The MID$ statement is a different thing

`MID$` is overloaded in GW-BASIC: as a function it *extracts*, but
`MID$(A$,n[,len]) = value` *overwrites in place*. The two are separate RTLs.
`MID_SET` (the statement) splices the replacement hex into the target's hex,
leaving the target's overall length unchanged:

```bat
set /a "_p1=_so*2"
set /a "_p2=(_so+_rep)*2"
set /a "_vc=_rep*2"
set "_new=!_thex:~0,%_p1%!!_vhex:~0,%_vc%!!_thex:~%_p2%!"
call %GWSRC%\exec\_vars set !_target! STR_!_new!
```

The replacement count `_rep` is clamped to both the supplied length and what
the target can actually hold (`_avail = _tlen - _so`), so writing past the end
silently truncates rather than growing the string — exactly GW-BASIC's
semantics. Note that, unlike the function, this writes the result straight
back to the variable via `_vars set` instead of pushing onto the stack.

## Printing: why output goes through decodePrint

The functions return `STR_<hex>`; turning that back into visible characters is
deliberately *not* their job. That happens at the display edge, in
`str decodePrint`, because naive output is exactly where batch bites:

```
@REM   - echo/echo( mangle `=`, `<`, `>`, `&`, `|`
@REM   - <nul set /p "_=text" refuses prompts that start with `=`
@REM   - delayed expansion eats `!` from any cross-scope set
```

`decodePrint` sidesteps all of it by writing the hex to a temp file, running
`certutil -decodehex` to materialise the real bytes, and `type`-ing the binary
file out — the only mechanism that round-trips every printable byte (including
a leading space, the `STR$` placeholder, and the metacharacters above)
faithfully. When a `PRINT #` file sink is active the trailing `0D0A` is baked
into the hex first (`set "_s=!_s!0D0A"`) because a newline-only `echo. >> file`
writes nothing on the cmd port. See
[03 — Strings & hex](03-strings-hex.md) for the full encode/decode story.

## Problems & gotchas

### RIGHT$ with n ≥ length used to return empty

`RIGHT$("HI", 10)` should be `"HI"` — asking for more characters than exist
gives you the whole string. An earlier `FN_RIGHT` computed
`_skip = _len - _take`, which goes **negative** when `n` exceeds the length;
the negative offset made `!_h:~%_skip%!` slice from the wrong place and return
empty. The fix is the explicit whole-string branch now at the top of the clip:

```bat
if !_take! GEQ !_len! (
  call %GWSRC%\stl\vec push %_s% STR_!_h!
  goto :_rl_ret
)
```

### …and that fix exposed the parse-time %var% trap

The obvious way to write that branch is to set `_final` and return *inside* the
parentheses. That fails. A parenthesised `if` block is parsed as a unit, so any
`%_final%` written inside it is expanded **once, at parse time**, before the
`set "_final=..."` on the line above has run — you propagate a stale (usually
empty) value. The handler's own comment spells it out:

```bat
@REM Whole string.  Propagation happens after the block: %_final% inside
@REM parens would expand at parse time, before set "_final=..." runs.
```

The cure is to do the push inside the block but jump to a shared
`:_rl_ret` tail *outside* it, where `set "_final=!%_s%!"` and the
`endlocal & set "%~1=%_final%"` run with delayed `!…!` expansion. This same
trap recurs anywhere an RTL tries to finalise inside an `if (...)` block, and
the standard remedy is the same: assign with `!delayed!` or hop out to a tail
label.

### INSTR's two forms, disambiguated by a sentinel

`INSTR` has a 2-argument form `INSTR(x$,y$)` (search from position 1) and a
3-argument form `INSTR(n,x$,y$)` (search from `n`). The executor's stack is
positional, so a handler popping three values can't otherwise tell whether the
bottom value is a start position or the haystack. The grammar resolves it by
always pushing **three** operands: for the 2-arg form it pushes the literal
sentinel `INSTR_NIL` on top (that is the whole job of `src/rtl/INSTR_NIL.bat`).
`FN_INSTR` branches on it:

```bat
if "!_c!"=="INSTR_NIL" (
  set "_n=1" & set "_x=!_a!" & set "_y=!_b!"
) else (
  call %GWSRC%\exec\_resolve !_a! _a & call :_toInt !_a! _n
  set "_x=!_b!" & set "_y=!_c!"
)
```

### MID$ uses the same trick for its optional length

The `MID$` *function* takes an optional length: `MID$(s,n)` means "to the end
of the string". Same problem, same solution — the grammar pushes the sentinel
`i7FFF` (the maximum 16-bit int, 32767) when no length is written, courtesy of
`src/rtl/MID_DEFAULT_LEN.bat`. `FN_MID` therefore *always* pops three operands;
the giant default length simply clamps to "everything remaining" via the
`_rem:~0,%_take%` slice. The handler comment notes this directly: "the
grammar's @MID_DEFAULT_LEN pushes i7FFF as a sentinel when the user wrote no
length."

### Case-folding on the encode side

`str encode` keys its lookup by a batch variable name, and those are
case-folded, so functions that build a string with it — `STR$`, `HEX$`, `OCT$`
— emit uppercase letters. That is harmless here because their outputs are
digits, signs and `E`/`.` only. `INSTR` likewise compares with `/I`, so its
match is case-insensitive on the bytes. For literals that must preserve case,
the project uses a different path (`encodeRaw`/`str input` via `certutil`) —
see [03 — Strings & hex](03-strings-hex.md#the-case-insensitivity-wrinkle).

## How it is tested

The function-level regressions live in
`src/exec/strings.test.bat`. They feed pre-parsed postfix straight to the
executor (`call :_rexec "<postfix>" "<expected>"`) — deliberately bypassing the
lexer/parser, because a `"` in a source line gets mangled by `call`'s argument
parser before it ever reaches the interpreter. Each assertion documents the
`STR_<hex>` it uses, e.g.:

```bat
call :_rexec "STR_48454C4C4F FN_LEN PEND" " 5"            @REM LEN("HELLO")
call :_rexec "STR_4849 NUM_i000A FN_RIGHT PEND" "HI"      @REM RIGHT$ past length
call :_rexec "STR_48454C4C4F NUM_i0003 MID_DEFAULT_LEN FN_MID PEND" "LLO"
```

Note the `FN_RIGHT past length` and `FN_MID` 2-arg cases — they pin the two
sentinel/whole-string war stories above. The lower-level `str` codec
(`encode`/`decode`/`ch2hex`/`hex2ch`) has its own suite in
`src/str/str.test.bat`. Run either through the project's test harness; both are
part of the 1,080+ assertion regression set.
