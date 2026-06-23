# Grammar (BNF)

The full grammar lives in [`src/parser/bnf.txt`](../src/parser/bnf.txt) —
that file is the single source of truth and gets compiled into the
parse table (`src/parser/_table.dat`) by `_rebuild.bat`. This article
is a reading guide: it explains the notation, walks through the
structure, and pulls out the parts that need context to make sense
(operator precedence, the few unobvious productions, the known
conflicts).

For the machinery that consumes the grammar — how `_rebuild.bat` turns
it into a table, what `@ACTION` markers do, how postfix gets emitted —
see [05 — Parser](05-parser.md).

## Notation

```
UPPER_CASE     terminal (token from the lexer)
CamelCase      nonterminal
::=            production
e              epsilon — empty production
@NAME          action marker — emit "NAME" into the postfix output stream
;              comment line
```

A few token classes stand for whole families of lexer outputs:

| Grammar term | Matches |
|---|---|
| `NUM` | any `NUM_i…`, `NUM_s…`, `NUM_d…`, `HEX_…`, or `OCT_…` |
| `VAR` | any `VAR_UNK_…`, `VAR_INT_…`, `VAR_SNG_…`, `VAR_DBL_…`, or `VAR_STR_…` |
| `STR` | any `STR_…` |
| `REM_TEXT` | any `REM_…` |

The lexer's full token table is in [04 — Lexer](04-lexer.md).

## Entry point

The parser sees **one program line at a time** and never sees the
`LN__` line-number token — the REPL/RUN dispatcher strips it before
calling the parser:

```
LN__ present  →  store the line in program memory (no parse yet)
LN__ absent   →  immediate mode: parse and execute now
```

The grammar's start symbol is `StmtList`. A line is a colon-separated
sequence of statements:

```
StmtList      ::= Stmt StmtRest
StmtRest      ::= COLON Stmt StmtRest
StmtRest      ::= e
```

`Stmt` is the big disjunction — one alternative per supported
statement, plus an epsilon production so empty lines and trailing
colons parse cleanly.

## Statements at a glance

The full `Stmt → …` block covers about 35 alternatives. Grouped:

| Category | Statements |
|---|---|
| Output | `PRINT`, `LPRINT`, `WRITE` |
| Assignment | `LET`, bare `AssignStmt` (`A = 1` works without `LET`) |
| Control flow | `IF…THEN…ELSE`, `FOR…NEXT…STEP`, `WHILE`/`WEND`, `GOTO`, `GOSUB`/`RETURN`, `ON…GOTO/GOSUB`, `END`, `STOP` |
| Input | `INPUT`, `LINE INPUT`, `READ`/`DATA` |
| Arrays | `DIM`, `ERASE`, `SWAP` |
| User functions | `DEF FN` |
| Variable types | `DEFINT`, `DEFSNG`, `DEFDBL`, `DEFSTR` |
| Comments | `REM body` and `' body` (apostrophe form) |
| Memory | `POKE`, `RANDOMIZE` |
| Files | `OPEN`, `CLOSE`, `WRITE #` |
| Screen | `CLS`, `LOCATE`, `COLOR`, `SCREEN`, `LINE` (both `LINE INPUT` and graphics `LINE (x,y)-(x,y)`) |
| Sound | `SOUND`, `BEEP` |
| Keyboard | `KEY ON/OFF/LIST`, `KEY n, STR$`, `KEY(n) ON/OFF/STOP`, `ON KEY(n) GOSUB` |
| Errors | `ERROR`, `RESUME`, `RESUME NEXT`, `RESUME line` |

Two notes:

- **`Stmt → e`** is there so that `: : :` and trailing colons parse.
  Empty statements are legal in GW-BASIC.
- **`AssignStmt → VAR AssignTail`** where `AssignTail` chooses between
  `EQ Expr @ASSIGN` (scalar) and `@ARR_START OPAR ExprList CPAR EQ Expr
  @ASSIGN_ARR` (array element). This is the only place in the grammar
  where the same LHS production splits on what comes *after* a `VAR`.

## REM has two forms

The bnf has:

```
RemStmt       ::= REM REM_TEXT @REM
RemStmt       ::= REM_TEXT @REM
```

`REM body` lexes as two tokens (`REM` keyword + `REM_<hex>` body), so
the first rule matches. `'body` (apostrophe shorthand) lexes as a
single `REM_<hex>` token — no preceding `REM` keyword — and matches
the second rule. Both forms emit the same `@REM` action; the executor
treats them identically. The distinction is preserved only at the file
boundary (see [04 — Lexer § Binary `.BAS` format](04-lexer.md#binary-bas-format)).

## Expression precedence

This is the most important section of the grammar to get right. GW-BASIC
defines a precedence ladder from lowest to highest:

| Precedence | Operators | Associativity |
|---:|---|---|
| 1 (lowest) | `IMP` | left |
| 2 | `EQV` | left |
| 3 | `XOR` | left |
| 4 | `OR` | left |
| 5 | `AND` | left |
| 6 | `NOT` (prefix) | right |
| 7 | `=`  `<`  `>`  `<=`  `>=`  `<>` | left |
| 8 | `+`  `-` | left |
| 9 | `MOD` | left |
| 10 | `\` (integer division) | left |
| 11 | `*`  `/` | left |
| 12 | `-` (unary minus) | right |
| 13 | `^` | **right** |
| 14 (highest) | primary (literal, var, paren, function call) | — |

The grammar encodes precedence by **nesting** — each level has its own
nonterminal that defers to the next level up:

```
ImpExpr   ::= EqvExpr ImpRest
ImpRest   ::= IMP EqvExpr @IMP ImpRest
ImpRest   ::= e

EqvExpr   ::= XorExpr EqvRest
EqvRest   ::= EQV XorExpr @EQV EqvRest
EqvRest   ::= e

… and so on, down to:

PowExpr   ::= Primary PowRest
PowRest   ::= POW PowExpr @POW
PowRest   ::= e
```

A few details that aren't obvious from the table:

- **Left associativity is implemented by tail recursion** in the
  `*Rest` nonterminals. Each `@OP` marker fires after `EqvExpr` (or
  whatever) is reduced, so `a OP b OP c` becomes postfix
  `a b OP c OP` — left-associative.
- **Power (`^`) is right-associative**, so `PowRest` recurses on
  `PowExpr` itself rather than `PowRest`. `2 ^ 3 ^ 2` parses as
  `2 ^ (3 ^ 2) = 512`, not `(2 ^ 3) ^ 2 = 64`.
- **Unary minus** sits between `MulExpr` and `PowExpr`, so `-2^2`
  parses as `-(2^2) = -4`, matching GW-BASIC. To get `(-2)^2 = 4`
  you have to write it that way explicitly.
- **NOT** is at precedence 6, below comparisons. So `NOT A = B` parses
  as `NOT (A = B)`, not `(NOT A) = B`.
- **Relational operators** chain through `RelRest` like the
  arithmetic ones, so `A < B < C` parses without a syntax error —
  but it doesn't mean what a mathematician would expect, it means
  `(A < B) < C` (the boolean result of `A < B` compared with `C`).
  Same as classic BASIC.

## Primary

```
Primary       ::= NUM
Primary       ::= STR
Primary       ::= VarOrCall
Primary       ::= OPAR Expr CPAR
Primary       ::= FnCall
Primary       ::= BuiltinCall

VarOrCall     ::= VAR ArrayIndex
ArrayIndex    ::= @ARR_START OPAR ExprList CPAR @AIDX
ArrayIndex    ::= e
```

`VarOrCall` covers both `X` (scalar read) and `A(1,2)` (array index)
with the same production — `ArrayIndex` is nullable, so the parser
picks the array branch only when an open paren follows the variable.

`FnCall` is the user-defined `FN NAME(args)` form (`DEF FN` declared
it). `BuiltinCall` is the long list of built-in functions —
`ABS(x)`, `LEFT$(s, n)`, `MID$(s, n[, m])`, and so on. Each function
has its own production so the action marker can identify it:

```
AbsFn         ::= ABS  OPAR Expr CPAR @FN_ABS
LeftFn        ::= LEFT$ OPAR Expr COMA Expr CPAR @FN_LEFT
MidFn         ::= MID$ OPAR Expr COMA Expr MidLen CPAR @FN_MID
MidLen        ::= COMA Expr
MidLen        ::= e
```

The pattern is uniform: keyword `OPAR` args `CPAR @FN_NAME`. The
executor's `src/rtl/FN_<NAME>.bat` does the work.

`ERR`, `ERL`, `INKEY$`, and `CSRLIN` are zero-argument primaries that
look like keywords (no parens):

```
BuiltinCall   ::= ERL @FN_ERL
BuiltinCall   ::= ERR @FN_ERR
BuiltinCall   ::= CSRLIN @FN_CSRLIN
InkeyFn       ::= INKEY$ @FN_INKEY
```

## Known LL(1) conflicts

`_rebuild.bat` reports six warnings every time it runs. All are
intentional:

```
CONFLICT: table.StmtRest.COLON   = ... [FOLLOW]
CONFLICT: table.ElseClause.ELSE  = ... [FOLLOW]
CONFLICT: table.KeyWhat.OPAR     = ...
CONFLICT: table.AddRest.MINUS    = ... [FOLLOW]
CONFLICT: table.ArrayIndex.OPAR  = ... [FOLLOW]
CONFLICT: table.RndArgs.OPAR     = ... [FOLLOW]
```

- **`StmtRest` on `COLON`** — both "consume the colon and parse
  another `Stmt`" and "epsilon" match. The table keeps the parse-another
  rule, which is correct for `A = 1 : B = 2`.
- **`ElseClause` on `ELSE`** — inside a nested `IF`, the parser has
  to decide whether the `ELSE` belongs to the inner or outer `IF`.
  The table keeps the inner-IF rule (the classic "dangling else").
- **`KeyWhat` on `OPAR`** — after `KEY`, an open paren begins either
  `KEY(n) ON/OFF/STOP` (event trapping) or a parenthesised first arg of
  `KEY n, str$`. The trap form must win; since two FIRST entries overwrite
  (last wins), the grammar lists the trap rule *after* `KEY n, str$`.
- **`AddRest` on `MINUS`** — in `PRINT A -5`, GW-BASIC continues the
  expression (`A - 5`) rather than starting a juxtaposed print item.
- **`ArrayIndex` on `OPAR`** — `A(5)` is an array access, not `A`
  juxtaposed with `(5)`.
- **`RndArgs` on `OPAR`** — `RND(x)` binds the argument to `RND`.

For the five `[FOLLOW]` cases the table keeps the rule `bnf.txt` lists
**first**; for the `KeyWhat` FIRST/FIRST case it keeps the one listed
**last**. Either way the result is the branch GW-BASIC intends. These are
documented in [05 — Parser § Conflicts](05-parser.md#conflicts).

## Extending the grammar

To add a new statement (say, `BLOAD filename, offset`):

1. Add one production under the big `Stmt → …` block:
   ```
   Stmt          ::= BloadStmt
   ```
2. Define the right-hand side:
   ```
   BloadStmt     ::= BLOAD Expr COMA Expr @BLOAD
   ```
3. Add the keyword to `src/lexer/keyword.bat` if it isn't there.
4. Create `src/rtl/BLOAD.bat` to handle the action at run time.
5. Run `src/parser/_rebuild.bat` to regenerate `_table.dat`.
6. Both `bnf.txt` and `_table.dat` are committed to git — commit
   the pair together.

The grammar is the contract between the lexer and the executor:
adding a rule with an `@ACTION` that has no matching `src/rtl/`
file means the parser succeeds but the executor halts on an
"unknown action" message. Keep them in sync.
