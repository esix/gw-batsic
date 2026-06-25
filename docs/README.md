# gw-batsic docs

Notes on how the GW-BASIC interpreter is built, in batch.

For the project overview, how to run programs and tests, and the current
feature matrix (what works / what doesn't), see the
[top-level README](../README.md). These pages are the *internals*.

## Architecture & internals

- [01 — Architecture overview](01-architecture.md) — the pipeline (lex → parse → exec), where state lives, the tagged-value convention.
- [02 — Numerics & MBF](02-numerics.md) — 4-bit → 64-bit hex arithmetic, MBF singles and doubles, the `int`/`sng`/`dbl` facades, conversion quirks.
- [03 — Strings & hex encoding](03-strings-hex.md) — why we represent text as hex, the `str` module, `certutil`-based input, batch metacharacter problems it solves.
- [04 — Lexer](04-lexer.md) — state machine, token format, keyword table, and the `.BAS` binary load/save converter at the file boundary.
- [05 — Parser](05-parser.md) — LL(1) grammar, table generation, `@action` markers, the postfix-output trick, the known grammar conflicts.
- [06 — Grammar (BNF)](06-bnf.md) — reading guide to `bnf.txt`: notation, statement vocabulary, expression precedence ladder, known conflicts, how to extend.

## Implemented features

The GW-BASIC surface area below is **implemented and regression-tested**
(1,080+ assertions, see the `*.test.bat` files). The numbered deep-dive
articles are still to be written — until then, the live reference is the
[feature matrix in the top-level README](../README.md#what-works) plus the
code itself (one `src/rtl/*.bat` per statement/operator/function). Article
numbers 07–98 are reserved so the "not implementable" page keeps a stable URL.

- 07 — Executor & RTL — stack machine, filesystem dispatch, propagation idioms. ✅ *implemented*
- 08 — Program storage, the RUN loop, control flow (`GOTO`, `GOSUB`/`RETURN`, `IF`/`THEN`/`ELSE`, `FOR`/`NEXT` incl. single-line, `WHILE`/`WEND`, `ON…GOTO/GOSUB`, `END`, `STOP`). ✅ *implemented*
- 09 — Variables, types, and `DEFINT` / `DEFSNG` / `DEFDBL` / `DEFSTR`. ✅ *implemented*
- 10 — Arrays (`DIM`, indexing, multi-dim, read/write & `READ`/`INPUT` into elements, `OPTION BASE 0/1`, `ERASE`, `SWAP`). ✅ *implemented*
- 11 — Operators (`+ - * / ^`, integer `\` and `MOD`, comparisons, boolean `AND`/`OR`/`NOT`/`XOR`/`EQV`/`IMP`). ✅ *implemented*
- 12 — Numeric built-ins (`ABS`/`INT`/`SGN`/`FIX`/`SQR`/`SIN`/`COS`/`TAN`/`ATN`/`LOG`/`EXP`/`RND`/`CINT`/`CSNG`/`CDBL`/`TIMER`). ✅ *implemented*
- 13 — String built-ins (`LEN`/`CHR$`/`STR$`/`VAL`/`ASC`/`LEFT$`/`RIGHT$`/`MID$` func & statement/`SPACE$`/`STRING$`/`INSTR`/`HEX$`/`OCT$`). ✅ *implemented*
- 14 — `PRINT` formatting (`PEND`/`PSEMI`/`PTAB`/`PZONE`, `TAB(`/`SPC(`), `PRINT USING` (incl. after-item & variable values), `LPRINT`. ✅ *implemented*
- 14b — `DEF FN` user functions, `CHAIN`/`COMMON`, `DATE$`/`TIME$`, `CLEAR`, `LIST`. ✅ *implemented*
- 15 — `INPUT` (interactive read, prompt forms, type coercion), `LINE INPUT`, `READ`/`DATA`/`RESTORE`. ✅ *implemented*
- 16 — Errors: `ERR` / `ERL`, the canonical message table, `_printErr`, **plus `ON ERROR GOTO` / `RESUME` / `ERROR n` runtime trapping**. ✅ *implemented*
- 17 — Batch quirks encountered along the way (`set /p` whitespace, `^` escaping, parenthesised-block `%var%` parse time, CRLF requirement, …).
- 18 — **File I/O** — handle table, sequential `OPEN`/`CLOSE`/`PRINT #`/`WRITE #`/`INPUT #`/`INPUT$(n,#f)`/`EOF`/`LOF`/`LOC`, random-access `FIELD` (incl. the dense `5ASO1$` form)/`LSET`/`RSET`/`GET`/`PUT` live-window records, `MKI$`…`CVD` codecs, `FILES`/`KILL`/`NAME`. ✅ *implemented*

## What we won't be implementing

- [99 — Not implementable in batch](99-not-implementable.md) — keywords that depend on real-mode DOS hardware (`PEEK`/`POKE`/`USR`/...), graphics modes (`SCREEN`/`LINE`/`CIRCLE`/...), the `SCREEN(row,col)` read-char function (no readable shadow buffer), light pen / joystick, COM/LPT ports, the PC speaker, and the partial-authenticity cases.  Honest about what would be a degraded approximation versus simply impossible.
