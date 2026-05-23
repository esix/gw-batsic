# gw-batsic docs

Notes on how the GW-BASIC interpreter is built, in batch.

## Architecture & internals

- [01 — Architecture overview](01-architecture.md) — the pipeline (lex → parse → exec), where state lives, the tagged-value convention.
- [02 — Numerics & MBF](02-numerics.md) — 4-bit → 64-bit hex arithmetic, MBF singles and doubles, the `int`/`sng`/`dbl` facades, conversion quirks.
- [03 — Strings & hex encoding](03-strings-hex.md) — why we represent text as hex, the `str` module, `certutil`-based input, batch metacharacter problems it solves.
- [04 — Lexer](04-lexer.md) — state machine, token format, keyword table, and the `.BAS` binary load/save converter at the file boundary.
- [05 — Parser](05-parser.md) — LL(1) grammar, table generation, `@action` markers, the postfix-output trick, the two known conflicts.
- [06 — Grammar (BNF)](06-bnf.md) — reading guide to `bnf.txt`: notation, statement vocabulary, expression precedence ladder, known conflicts, how to extend.

## Implemented features (planned articles)

These pages will walk through the GW-BASIC surface area we actually
implement, grouped by category.  Numbers 07–98 are reserved so the
"not implementable" page can sit at the end at a stable URL.

- 07 — Executor & RTL (stack machine, dispatch, propagation idioms).
- 08 — Program storage, the RUN loop, control flow (`GOTO`, `GOSUB`/`RETURN`, `IF`/`THEN`/`ELSE`, `FOR`/`NEXT`, `WHILE`/`WEND`, `END`, `STOP`).
- 09 — Variables, types, and `DEFINT` / `DEFSNG` / `DEFDBL` / `DEFSTR`.
- 10 — Arrays (`DIM`, indexing, OPTION BASE, multi-dim).
- 11 — Operators (arithmetic `+`-`*`/`^`, integer `\` and `MOD`, comparisons, boolean `AND`/`OR`/`NOT`/`XOR`/`EQV`/`IMP`).
- 12 — Built-in functions: numeric (`ABS`/`INT`/`SGN`/`FIX`/`CINT`/`CSNG`/`CDBL`/...).
- 13 — Built-in functions: strings (`LEN`/`CHR$`/`STR$`/`VAL`/`ASC`/`LEFT$`/`RIGHT$`/`MID$`/`SPACE$`/...).
- 14 — `PRINT` formatting (`PEND`/`PSEMI`/`PTAB`, `TAB(`/`SPC(`).
- 15 — `INPUT` (interactive read, prompt, type coercion).
- 16 — Errors (`ERR` / `ERL`, the canonical message table, `_printErr`).
- 17 — Batch quirks encountered along the way (`set /p` whitespace, `^` escaping, parenthesised-block `%var%` parse time, CRLF requirement, …).

## What we won't be implementing

- [99 — Not implementable in batch](99-not-implementable.md) — keywords that depend on real-mode DOS hardware (`PEEK`/`POKE`/`USR`/...), graphics modes (`SCREEN`/`LINE`/`CIRCLE`/...), light pen / joystick, COM/LPT ports, the PC speaker, and the partial-authenticity cases.  Honest about what would be a degraded approximation versus simply impossible.
