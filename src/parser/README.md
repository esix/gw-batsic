# src/parser — LL(1) Parser

Table-driven LL(1) parser for GW-BASIC. The parse table is pre-computed from the BNF grammar and stored in a data file for instant runtime loading.

## Workflow

```
bnf.txt  --[_rebuild.bat]-->  _table.dat  --[parser]-->  postfix output
  ^                              |
  |  edit grammar                |  committed to git
  |  run _rebuild.bat            |  used at runtime via findstr
```

### When you change the grammar:

```
> src\parser\_rebuild.bat
```

This reads `bnf.txt`, computes FIRST/FOLLOW sets, builds the LL(1) parse table, and writes `_table.dat`. Takes ~3-4 minutes (batch is slow for set operations). Only needed when `bnf.txt` changes.

Two expected warnings are printed during rebuild:

```
CONFLICT: table.StmtRest.COLON = 1 vs 2 [FOLLOW]
CONFLICT: table.ElseClause.ELSE = 55 vs 56 [FOLLOW]
```

These are known LL(1) limitations, both resolved correctly:

- **StmtRest.COLON**: `:` can start a new statement (rule 1) or end the statement list (rule 2). FIRST entry wins — `:` continues parsing. Correct.
- **ElseClause.ELSE**: `ELSE` can match an else clause (rule 55) or be skipped (rule 56). FIRST entry wins — `ELSE` is matched. This is the classic "dangling else" resolution. Correct.

The `[FOLLOW]` tag means the FOLLOW-derived entry was NOT written because a FIRST entry already existed. Any NEW conflicts (without `[FOLLOW]`, or between different FIRST rules) would indicate a real grammar ambiguity that needs fixing.

### At runtime:

```batch
call init readAll           &:: loads _table.dat path (instant, no env vars)
call _table lookup Stmt PRINT _r    &:: _r = "3"
call _table rule 3 _rule            &:: _rule = "Stmt PrintStmt"
```

All lookups use `findstr` against `_table.dat`. No parse table data in environment memory.

## Files

| File | Purpose | When |
|---|---|---|
| `bnf.txt` | LL(1) grammar (source of truth) | Edit this |
| `_rebuild.bat` | Reads BNF, builds `_table.dat` | Run after editing BNF |
| `_table.dat` | Pre-computed parse table + rules (git tracked) | Runtime lookup |
| `_table.bat` | Table utilities: lookup, rule, meta, saveCache | Runtime |
| `init.bat` | Loads `_table.dat` for parser use | Runtime |
| `parse.bat` | LL(1) parse engine (planned) | Runtime |
| `_nonterminals.bat` | Extract nonterminals from BNF | Build step |
| `_terminals.bat` | Extract terminals from rules | Build step |
| `_first.bat` | Compute FIRST sets | Build step |
| `_follow.bat` | Compute FOLLOW sets | Build step |

Build-step files (`_nonterminals`, `_terminals`, `_first`, `_follow`) are also runnable standalone for inspection:

```
> src\parser\_nonterminals.bat     &:: list all nonterminals + rules
> src\parser\_terminals.bat        &:: list all terminals
> src\parser\_first.bat            &:: show FIRST sets
> src\parser\_follow.bat           &:: show FOLLOW sets
```

## _table.dat Format

Plain text, one entry per line, searched by `findstr`:

```
; metadata
grammar.start=StmtList
grammar.rules.length=296
grammar.nonterminals=StmtList StmtRest Stmt ...
grammar.terminals=COLON RETURN WEND ...

; rules (LHS + RHS symbols)
rule.0=StmtList Stmt StmtRest
rule.1=StmtRest COLON Stmt StmtRest
rule.2=StmtRest e
rule.3=Stmt PrintStmt
...

; parse table (nonterminal + terminal -> rule number)
table.StmtList.PRINT=0
table.Stmt.PRINT=3
table.Stmt.IF=5
table.Stmt.GOTO=8
table.AddRest.PLUS=187
table.AddRest.MINUS=188
table.MulRest.MUL=197
...
```

## Runtime API

```batch
@REM Load table (once at startup)
call _table loadCache "path\_table.dat"

@REM Look up which rule to use for nonterminal + lookahead terminal
call _table lookup StmtList PRINT __     &:: __ = "0"

@REM Get rule RHS by rule number
call _table rule 0 __                    &:: __ = "StmtList Stmt StmtRest"

@REM Get grammar metadata
call _table meta grammar.start __        &:: __ = "StmtList"
```

All lookups return results in the named variable. Errorlevel 1 if not found.

## Grammar

The grammar in `bnf.txt` is LL(1) with these conventions:

- `CamelCase` = nonterminal
- `UPPER_CASE` = terminal (token from lexer)
- `e` = epsilon (empty production)
- `::=` separates LHS from RHS
- Lines starting with `;` are comments

The parser entry point is `StmtList` (one line of GW-BASIC, no line numbers).

See `bnf.txt` for the full grammar and `src/lexer/README.md` for token definitions.
