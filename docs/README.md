# gw-batsic docs

Notes on how the GW-BASIC interpreter is built, in batch.

## Articles

- [01 — Architecture overview](01-architecture.md) — the pipeline (lex → parse → exec), where state lives, the tagged-value convention.
- [02 — Numerics & MBF](02-numerics.md) — 4-bit → 64-bit hex arithmetic, MBF singles and doubles, the `int`/`sng`/`dbl` facades, conversion quirks.
- [03 — Strings & hex encoding](03-strings-hex.md) — why we represent text as hex, the `str` module, `certutil`-based input, batch metacharacter problems it solves.
- [04 — Lexer](04-lexer.md) — state machine, token format, keyword table, and the `.BAS` binary load/save converter at the file boundary.
- [05 — Parser](05-parser.md) — LL(1) grammar, table generation, `@action` markers, the postfix-output trick, the two known conflicts.
- [06 — Grammar (BNF)](06-bnf.md) — reading guide to `bnf.txt`: notation, statement vocabulary, expression precedence ladder, known conflicts, how to extend.

## Planned
- 07 — Executor & RTL (stack machine, dispatch, propagation idioms).
- 08 — Program storage, RUN loop, control flow (`GOTO` / `GOSUB` / `RETURN`).
- 09 — Errors (`ERR` / `ERL`).
- 10 — Arrays.
- 11 — Batch quirks encountered along the way.
