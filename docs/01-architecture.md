# Architecture overview

`gw-batsic` is a GW-BASIC interpreter written in Windows batch (`.bat`). The
goal is faithfulness to GW-BASIC semantics — same operators, same number
formats (MBF singles and doubles), same line-numbered program model — but
the implementation is done entirely in `cmd.exe`, with no compiled helpers
or external tools beyond what ships with Windows (`certutil` for hex
encoding, `sort` for line ordering).

## The pipeline

A single source line goes through five stages:

```
keyboard input
   │   (str input — certutil -encodehex)
   ▼
hex-encoded text          "10 PRINT 1+2" → 31302050524956…
   │   (lexer)
   ▼
token stream              LN__10 PRINT NUM_i0001 PLUS NUM_i0002 EOL
   │   (parser — LL(1), table-driven)
   ▼
postfix token stream      NUM_i0001 NUM_i0002 ADD PEND
   │   (executor — stack machine)
   ▼
side effects + output     " 3"
```

The whole pipeline runs on **one line at a time**. Multi-line programs are
stored in `temp/program.dat`, and `RUN` walks the lines, running each one
through parse+exec.

## Modules

| Directory | What lives here |
|---|---|
| `src/str/` | Hex / text encoding (`str encode`, `str decode`, `str input`). Used everywhere user-typed text needs to be safe against batch metacharacters. |
| `src/lexer/` | Tokenizer (`lexer ParseTxt`) and keyword table. Also `unlexer print` for `LIST`. |
| `src/parser/` | LL(1) parser. `bnf.txt` is the grammar; `_rebuild.bat` regenerates the cached `_table.dat`. `parse parse` produces postfix from a token stream. |
| `src/exec/` | The executor (`exec run`), the program/variable/array stores, and the RUN loop. |
| `src/rtl/` | Runtime library — one `.bat` per postfix action (`ADD.bat`, `PEND.bat`, `GOTO.bat`, …). Called by `exec run` when it encounters an action token. |
| `src/num/` | Number layers: 16/32/64-bit hex words (`_xword`, `_xdword`, `_xqword`) and the typed facades (`int`, `sng`, `dbl`). |
| `src/stl/` | Containers used by the runtime: `vec` (ordered list, used as the eval stack and the GOSUB stack), `set`, `iter`. |
| `tests/` | Test harness (`expect.bat`, `expecterr.bat`, declaration helper). Each module has its own `test.bat` discovered by the root `test.bat`. |

## Tagged values

Numbers on the eval stack and in variables carry a one-character type tag:

| Tag | Type | Hex width | Representation |
|---|---|---|---|
| `i` | signed 16-bit int | 4 chars | two's-complement (`iFFFF` = -1) |
| `s` | single-precision MBF | 8 chars | EE SM MM MM (big-endian, biased-128 exponent) |
| `d` | double-precision MBF | 16 chars | EE SM MM MM MM MM MM MM |
| `t` | string | variable | distinct token type, not a numeric tag |

So `i0064` is integer 100, `s86480000` is single 100.0, `d8649000000000000` is
double 100.0. Tagged values are opaque strings everywhere outside `src/num/`.
The numeric facades convert between them (`int fromDec`, `sng fromInt`,
`dbl toDec`, etc.) and do the arithmetic. The executor pushes / pops them
untouched; promotion between types lives in `src/exec/_promote.bat`.

## State

Everything that has to survive past one `cmd.exe` `setlocal` boundary lives
in a file under `temp/`. Everything else lives in environment variables and
is propagated up through the standard `endlocal & set "…=%…%"` idiom.

| Where | What |
|---|---|
| `temp/vars.dat` | Scalar variables. One per line: `VAR_TYP_NAME=tagged_value`. |
| `temp/arrays.dat` | Arrays. One per line: `ARR_TYP_NAME NDIMS BOUND1…BOUNDN V0 V1 …`. |
| `temp/program.dat` | Program lines. One per line: `NNNNN TOKENS…` with `NNNNN` as a zero-padded 5-digit sortable key. |
| env `_stk` | Eval stack (space-separated tagged values), local to `exec :run`. |
| env `_next_line` | Next program line to execute. RTLs like `GOTO` overwrite it. |
| env `_gosub_stack` | Return-address stack for `GOSUB` / `RETURN`. |
| env `_err_code` / `_err_line` | `ERR` / `ERL`. Cleared on `RUN`, otherwise persistent. |
| env `_cur_line` | Current executing line (set by the RUN loop; `65535` in immediate mode). Used to populate `_err_line` on error. |

## Modes

- **Immediate** — the REPL. Type something without a leading number, it's
  lexed, parsed and executed right away. `_cur_line` is `65535` so `ERL`
  reports `65535` for direct-mode errors.
- **Program entry** — a line that starts with a number is stored in
  `temp/program.dat` (replacing any existing line with the same number).
  Typing just `10` deletes line 10.
- **RUN** — walks lines in order from the lowest. Each line is parsed and
  executed; `_cur_line` is set first so errors record the right `ERL`.
  `GOTO` / `GOSUB` / `RETURN` override `_next_line` to jump.
- **Direct commands** — `LIST`, `RUN`, `SYSTEM` are recognised at the REPL
  level (before the parser is even invoked) by looking at the first token.

## Why batch?

For the challenge, mostly. The constraint forces interesting design
decisions — no real types, only env vars and files; no real call stack
beyond `cmd.exe`'s; no library beyond what ships with Windows. The MBF
arithmetic is built from 4-bit lookup tables; the LL(1) parser is
table-driven with a generator that runs in batch; the stack machine
passes data through space-separated strings.

It's not fast. A single multiplication can take hundreds of `cmd.exe`
commands. But it's faithful, and the layering is reusable.
