# gw-batsic

**A working GW-BASIC interpreter written entirely in Windows `.bat` batch files.**

No C, no Python, no executables we compiled — just `cmd.exe` batch scripts
parsing and running 1980s BASIC. The lexer, the LL(1) parser, the Microsoft
Binary Format floating-point math, the file system, the random-access record
buffers, the error trapping — all of it is `SET`, `CALL`, `GOTO`, and
`FOR /F`.

```
$ cmd gw-batsic.bat /R examples/99BOB.BAS
 99  BOTTLES OF BEER ON THE WALL
 99  BOTTLES OF BEER
 TAKE ONE DOWN
 PASS IT AROUND
 98  BOTTLES OF BEER ON THE WALL
 ...
```

Yes, really. It boots to an `Ok` prompt, you can `LOAD "PROG.BAS"`, `LIST` it,
edit a line, `RUN` it, and `SAVE` it back out as tokenized binary — the same
things you did on a 1985 IBM PC, driven by a language whose only data
structure is a string.

---

## Run it anywhere — the cmd port

Real `cmd.exe` only exists on Windows. To run gw-batsic on **macOS or Linux**
(and *faster* than the real thing even **on Windows**), use the companion
project — a clean-room `cmd.exe` reimplementation in Go:

### 👉 [github.com/esix/cmd](https://github.com/esix/cmd)

```sh
# 1. Build the cmd port (Go toolchain required)
git clone https://github.com/esix/cmd && cd cmd
go build -o cmd .

# 2. Run a BASIC program with it
cd /path/to/gw-batsic
/path/to/cmd/cmd gw-batsic.bat /R examples/HELLO.BAS
```

The port implements enough of `cmd.exe` — `setlocal`/`endlocal`, delayed
expansion, `for /f`, `call` with labels, arithmetic `set /a`, `certutil`,
`chcp` — that the *exact same `.bat` files* run unchanged on every OS. On
native Windows you can also just run `gw-batsic.bat` directly with the
built-in `cmd.exe`; the Go port is simply quicker.

> Throughout this README, `cmd` means "your `cmd.exe`, or the Go port binary."

---

## Running programs

gw-batsic mirrors the original command line:

```
gw-batsic [/R] [file.bas]
```

| Invocation | What happens |
|---|---|
| `cmd gw-batsic.bat` | Empty program, drops into the interactive **REPL** (`Ok` prompt). |
| `cmd gw-batsic.bat PROG.BAS` | **Loads** `PROG.BAS` into memory, then REPL (type `RUN`). |
| `cmd gw-batsic.bat /R PROG.BAS` | **Load + RUN + exit.** Process exit code = the GW-BASIC error code. |

### Loading, running, and saving existing files

Either pass a file on the command line, or use the direct commands at the
`Ok` prompt — exactly like vintage GW-BASIC:

```basic
Ok
LOAD "MYPROG.BAS"     ' replaces the in-memory program
LIST                  ' show it
RUN                   ' run it
20 PRINT "edited!"    ' a line with a number edits the program
SAVE "MYPROG.BAS"     ' save tokenized binary (GW-BASIC default)
SAVE "MYPROG.BAS",A   ' save plain ASCII source
SYSTEM                ' quit
```

**Both file formats load transparently:** plain-ASCII numbered source *and*
GW-BASIC's tokenized binary `.BAS` (auto-detected by the leading `0xFF`
byte). Vintage CP/M `Ctrl-Z` end-of-file markers are honored.

A line typed **without** a line number runs immediately (`PRINT 2+2` prints
`4`); a line **with** one is stored as program text; a bare line number
deletes that line. You can script a whole session over stdin:

```sh
cmd gw-batsic.bat <<'EOF'
10 PRINT "HELLO"
20 FOR I=1 TO 3: PRINT I,: NEXT
RUN
SYSTEM
EOF
```

---

## What works

The interpreter is well past "toy." Roughly **160 statement/operator/function
handlers** are implemented and covered by **~1,000 passing unit tests**. The
full sequential **and** random-access file I/O surface is complete.

| Area | Supported |
|---|---|
| **Numbers** | Integer `%`, single `!`, double `#` — genuine **Microsoft Binary Format** floats (not IEEE 754), built from 4-bit→64-bit hex arithmetic. `+ - * / \ MOD ^`, unary `-`, round-to-nearest. |
| **Comparisons / logic** | `= < > <= >= <>`, `AND OR NOT XOR EQV IMP`, full precedence ladder. |
| **Math functions** | `ABS INT FIX SGN SQR SIN COS TAN ATN LOG EXP` (pure-batch Taylor series + range reduction), `RND`, `RANDOMIZE`, `CINT CSNG CDBL`, `TIMER`. |
| **Strings** | `LEN VAL STR$ ASC CHR$ LEFT$ RIGHT$ MID$ SPACE$ STRING$ INSTR HEX$ OCT$`, `MID$(a$,n)=...` statement form, `TAB( SPC(`, `+` concatenation. |
| **Control flow** | `IF…THEN…ELSE`, `IF…GOTO`, `FOR/TO/STEP/NEXT` (incl. single-line & `NEXT i,j`), `WHILE/WEND`, `GOTO`, `GOSUB/RETURN`, `ON…GOTO`, `ON…GOSUB`, `END`, `STOP`, `:` separators. |
| **Arrays** | `DIM` (multi-dimensional, multiple per statement), element read/write, `READ`/`INPUT` into elements, `ERASE`, `SWAP` (scalars & array elements). |
| **User functions** | `DEF FN` — glued `FNname`, multiple/typed params, string returns, body refs to globals, nested `FN` calls (params save/restore). |
| **Console** | `PRINT` (zones, `;`/`,`, juxtaposition), `PRINT USING`, `LPRINT`, `?`, `INPUT` (all prompt forms), `LINE INPUT`, `READ/DATA/RESTORE`, `CLS`, `BEEP`, `LOCATE`, `COLOR` (CGA→ANSI), `KEY` on/off/list/set, `INKEY$`, `WIDTH`. |
| **Files — sequential** | `OPEN` (all three syntaxes), `CLOSE`/`RESET`, `PRINT #`, `WRITE #`, `INPUT #`, `LINE INPUT #`, `EOF`, `LOF`. |
| **Files — random** | `FIELD … AS` (live-window record buffers), `LSET`/`RSET`, `GET`/`PUT` with byte-seek, `MKI$/MKS$/MKD$` ↔ `CVI/CVS/CVD`. |
| **Files — disk** | `FILES`, `KILL`, `NAME … AS`. |
| **Error handling** | `ON ERROR GOTO` / `GOTO 0`, `RESUME` / `RESUME NEXT` / `RESUME` *line*, `ERROR n`, `ERR`, `ERL`, the standard GW error-code table. |
| **Types & program** | `DEFINT/DEFSNG/DEFDBL/DEFSTR`, `LET`, `REM`/`'`, `CLEAR`, `RUN [line|"file"]`, `LOAD`, `SAVE [,A]`, `LIST`, `NEW`, `SYSTEM`. |

---

## What doesn't work yet

**Not implemented (planned):**

- **`DATE$` / `TIME$`** — ⛔ *blocked on the cmd port*: the Go port returns
  empty `%DATE%`/`%TIME%` (real `cmd.exe` populates them). Tracked in
  `~/pro/cmd/issues/006`; once the port exposes them, these are a quick add.
- **`CHAIN` / `CHAIN MERGE`** — program-to-program chaining (vintage menu
  systems).
- **Cheap missing handlers** — `POS`, `FRE`, `CSRLIN`: the grammar accepts
  them, they just need a small RTL each (currently raise *"Advanced Feature"*).

**Not implementable in batch** (by nature — see
[`docs/99-not-implementable.md`](docs/99-not-implementable.md)):

- **Graphics** (`SCREEN` graphics modes, `LINE`, `CIRCLE`, `PSET`, `PAINT`,
  `DRAW`, `PALETTE`) — a terminal has no framebuffer.
- **Direct hardware** — `PEEK`/`POKE`, `INP`/`OUT`, `USR`, `WAIT`, `DEF SEG`,
  `VARPTR`, COM/LPT ports, the PC speaker (`SOUND`/`PLAY` as real tones).
- **Function-key event trapping** (`KEY(n) ON/OFF/STOP`, `ON KEY(n) GOSUB`) —
  *parsed and accepted* so programs run, but the handler can never fire:
  trapping needs a non-blocking keyboard read between statements, which batch
  lacks (same limit as the blocking `INKEY$`).

**Known quirks:** a mid-line `GOTO`/`GOSUB` followed by more statements on the
*same* line currently runs the trailing statements too (control-flow only
behaves correctly as the last statement on a line); `PRINT USING` omits the
`^^^^` exponential field; single-precision display can drift in the last digit
(MBF rounding).

### Corpus status

Against a **207-program** vintage example corpus, the latest headless sweep:
~**92 programs (44%) now reach their real interactive/compute logic** — up
from **4** at the start of the project. The remaining wall is grammar gaps
(`CHAIN`, the `SCREEN` function), not the engine.

---

## How it works

A line of BASIC flows through five stages, each a batch module:

```
source ──▶ hex-encode ──▶ lex ──▶ parse (LL(1)) ──▶ execute (stack machine)
           (certutil)    tokens   postfix/RPN       one .bat per action
```

1. **Hex pre-encode** — source is turned into hex byte-pairs so quotes, `^`,
   and other batch metacharacters survive every `call`. Text lives as hex
   throughout (`STR_414243` = `"ABC"`).
2. **Lex** — a hand-written character state machine emits tagged tokens.
   Numeric literals are converted to MBF *right there*.
3. **Parse** — an LL(1) table-driven parser (table generated from
   [`src/parser/bnf.txt`](src/parser/bnf.txt)) outputs a **postfix** token
   stream; `@ACTION` markers in the grammar become operations.
4. **Execute** — a postfix **stack machine**. Values push onto a stack;
   every other token dispatches to `src/rtl/<TOKEN>.bat`. **The dispatch
   table is the filesystem** — one statement/operator/function = one `.bat`.
5. **Values are self-describing strings** with a one-char type tag
   (`i`/`s`/`d`/`STR_`), so type checks are a substring read.

The deep dives live in [`docs/`](docs/) — architecture, the MBF numerics, the
hex/string layer, the lexer, the parser, and the BNF.

---

## Running the tests

A ~1,000-assertion suite drives every module. Run it through the cmd port
from the repo root:

```sh
cmd test.bat            # everything (prints "Total tests / PASSED / FAILED")
cmd test.bat exec       # just one module
cmd test.bat rtl        # …or another (exec, lexer, num, parser, rtl, stl, str)
```

The runner exits with the failed-test count. Tests are per-module
`*.test.bat` files under `src/<module>/`, driven by `test.bat` and the tiny
`tests/` harness (`expect` / `expecterr`). The file-I/O tests assert *both*
GW error codes and real on-disk effects.

> Run a full-suite pass from a clean `temp/` — the immediate-mode tests share
> the on-disk variable store, so stale `temp/*.dat` from an interrupted run
> can cause spurious failures.

---

## Project layout

```
gw-batsic.bat      entry point (/R, REPL, file load)
test.bat           test orchestrator
src/
  lexer/           tokenizer + keyword table + .BAS binary load/save
  parser/          LL(1) grammar (bnf.txt), table generator, parser
  exec/            the run loop, stack machine, variables, arrays, files
  rtl/             ~160 action handlers — one .bat per statement/op/function
  num/             int / single / double facades + MBF & hex-arithmetic codecs
  str/             hex string layer
  stl/             vec / set data-structure helpers
examples/          207 vintage GW-BASIC programs
docs/              architecture & internals write-ups
```

---

## Status

The engine is solid: full expression evaluation, control flow, arrays,
complete file I/O (sequential + random-access records), and runtime
error trapping all work and are regression-tested at ~1,000 assertions green.
The frontier is **grammar coverage** of the long tail of vintage statements
(`CHAIN`, the `SCREEN` function) and a few remaining handlers (`POS`, `FRE`,
`CSRLIN`) — plus `DATE$`/`TIME$` once the cmd port grows `%DATE%`/`%TIME%`.

Built and tested on macOS via the [Go cmd port](https://github.com/esix/cmd);
the same `.bat` files run on Windows and Linux.
