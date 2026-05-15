# Parser

The parser turns the lexer's token stream into **postfix** — a flat
sequence of values and action names that the executor runs straight
through with a stack machine. It's an LL(1) table-driven parser, with
the table generated from a BNF grammar file by a separate build script.

## Why LL(1)

LL(1) means "Left-to-right, Leftmost derivation, 1-token lookahead". In
practice:

- Read input left to right, one token at a time.
- For each non-terminal at the top of the parse stack, decide which
  production to use by looking at exactly **one** upcoming token.
- No backtracking, no second pass.

GW-BASIC fits LL(1) cleanly because its statement forms are
distinguished by their leading keyword (`PRINT`, `FOR`, `IF`, `DIM`,
…). Once you've seen the keyword, the rest of the statement is
unambiguous. The few places where LL(1) struggles (`IF…THEN` with
dangling `ELSE`, `Stmt → StmtList` separator overlap) produce
**conflicts** at table-build time; we resolve them by preferring the
non-epsilon production, matching GW-BASIC's actual behaviour.

LL(1) is also a good fit for batch: the parser is just a loop over a
stack of nonterminals, with table lookups via findstr. No recursion, no
state machine, no complex decisions at runtime.

## The grammar file

`src/parser/bnf.txt` is the single source of truth — a plain-text BNF
with one production per line. Conventions:

| Form | Meaning |
|---|---|
| `UPPER_CASE` | terminal (a token class from the lexer) |
| `CamelCase` | nonterminal |
| `::=` | production rule |
| `e` | epsilon (empty production) |
| `@NAME` | **action marker** — emitted as a token in the postfix output |
| `;` | line comment |

Alternatives are written as separate lines:

```
StmtRest      ::= COLON Stmt StmtRest
StmtRest      ::= e
```

This avoids the `|` pipe (which is a batch metacharacter and a pain to
write in grep patterns) and keeps each rule on its own line for easier
diffing.

The grammar currently has ~300 rules across ~150 nonterminals and ~110
terminals. The full GW-BASIC statement vocabulary is in there, including
DIM, DEF FN, ON…GOTO, INPUT, READ/DATA, OPEN/CLOSE, WRITE, LINE,
LOCATE, COLOR, SCREEN, SOUND, KEY, SWAP, ERASE, ERROR, RESUME, plus all
the expression operators in their correct precedence.

## Terminals and token classification

The lexer emits ~25 distinct token *forms* (see [04 — Lexer](04-lexer.md)),
but many of them collapse to a single terminal class for parsing purposes:

| Lexer token form | Parser terminal |
|---|---|
| `NUM_iXXXX`, `NUM_sXXXXXXXX`, `NUM_dXXXXXXXXXXXXXXXX` | `NUM` |
| `HEX_…`, `OCT_…` | `NUM` (parser doesn't care about base) |
| `VAR_UNK_…`, `VAR_INT_…`, `VAR_SNG_…`, `VAR_DBL_…`, `VAR_STR_…` | `VAR` |
| `STR_…` | `STR` |
| `REM_…` | `REM_TEXT` |
| `EOL` | `$` (end-of-input sentinel) |
| Everything else (keywords, operators, punctuation) | itself |

This collapsing happens in `parse.bat`'s `:_classify` block — three
short prefix checks and we know which terminal column to look up in the
parse table. The original token (`NUM_i000A`, `VAR_UNK_A`, etc.) is
preserved separately and emitted into the postfix output if it carries
a value.

## Actions: the postfix trick

The piece that turns a parse tree into postfix is `@NAME` markers in
the grammar. Look at a small rule:

```
AddRest  ::= PLUS ModExpr @ADD AddRest
```

The parser's job for `AddRest` is to:

1. Match the terminal `PLUS`.
2. Recursively parse `ModExpr`.
3. Emit `@ADD` into the output.
4. Recursively parse `AddRest`.

Steps 1, 2, 4 are familiar. Step 3 is the new thing: when the top of
the parse stack is a token starting with `@`, the parser pushes its
name (minus the `@`) into the output stream and pops it — no input
matching, no nonterminal expansion. Just an emit.

In `parse.bat`:

```
if "!_tc!"=="@" (
  set "_output=!_output! !_top:~1!"
  set "_stack=!_stail!"
  goto :_parse_loop
)
```

The output stream therefore interleaves **value tokens** (matched
`NUM_…`, `VAR_…`, `STR_…`, `REM_…`) with **action names** (the
de-`@`-d markers). Structural terminals like `OPAR`, `CPAR`, `COMA`,
`SEMICOLON`, `THEN`, `TO`, `STEP`, `EQ` are matched and *consumed* by
the parser but **not** copied to the output — they only exist in the
grammar to drive the parse, not to be executed.

Worked example: `PRINT 1 + 2 * 3` lexes to

```
PRINT NUM_i0001 PLUS NUM_i0002 MUL NUM_i0003 EOL
```

The relevant rules:

```
PrintStmt ::= PRINT PrintList @PEND
PrintItem ::= Expr
AddExpr   ::= ModExpr AddRest
AddRest   ::= PLUS ModExpr @ADD AddRest
AddRest   ::= e
MulExpr   ::= UnaryExpr MulRest
MulRest   ::= MUL UnaryExpr @MUL MulRest
MulRest   ::= e
```

The parser walks through, matches the terminals, emits values and
actions, and produces:

```
NUM_i0001 NUM_i0002 NUM_i0003 MUL ADD PEND
```

— the expression in postfix, with precedence already baked in (`MUL`
runs before `ADD` because the grammar puts it deeper). That's exactly
what the executor's stack machine wants. No tree, no recursion, no
intermediate representation.

This is **action grammar** territory — close to attribute grammars
or syntax-directed translation, just stripped down to a single
output stream and one global emit operation.

## Parse-table generation

The table that drives the parser is precomputed by `_rebuild.bat`. The
flow:

```
bnf.txt
   │   _nonterminals read   →  list of nonterminals
   │   _terminals compute    →  list of terminals
   ▼
nonterminals, terminals
   │   _first compute        →  FIRST(X) for every nonterminal X
   ▼
FIRST sets
   │   _follow compute       →  FOLLOW(X) for every nonterminal X
   ▼
FOLLOW sets
   │   _table compute         →  parse table: (nonterminal, terminal) → rule
   ▼
_table.dat
```

Each step is its own small batch file under `src/parser/`. The final
`_table.dat` is a flat text file (~1900 lines) with three kinds of
entries:

```
grammar.start=StmtList
grammar.rules.length=298
grammar.nonterminals=StmtList StmtRest Stmt …
grammar.terminals=COLON RETURN WEND STOP …
rule.0=StmtList Stmt StmtRest
rule.1=StmtRest COLON Stmt StmtRest
rule.2=StmtRest e
…
table.StmtList.PRINT=0
table.StmtList.LET=0
table.Stmt.PRINT=3
table.Stmt.LET=4
…
```

The 298 `rule.N` entries are the productions, indexed. The 1558
`table.X.T` entries are the parse-table cells: "if the top of the stack
is nonterminal `X` and the upcoming terminal is `T`, apply rule `N`."

Rebuild takes a few minutes (mostly the FIRST/FOLLOW fixed-point
iterations in batch). The output is committed to git so day-to-day
development doesn't trigger it. `_table.bat`'s `loadCache` reads the
file once at parser startup; `lookup` and `rule` are findstr-backed
queries against the in-memory snapshot.

## Conflicts

`_rebuild.bat` warns when the table tries to set two different rules for
the same `(nonterminal, terminal)` cell. There are currently two such
warnings:

```
CONFLICT: table.StmtRest.COLON = 1 vs 2 [FOLLOW]
CONFLICT: table.ElseClause.ELSE = 57 vs 58 [FOLLOW]
```

Both are classic LL(1) limitations:

- **`StmtRest.COLON`**: after parsing a `Stmt`, seeing `COLON` could
  mean either "continue the StmtList with another statement" (rule 1,
  `COLON Stmt StmtRest`) or "the empty production" (rule 2). The first
  is the right choice — we always want to extend.
- **`ElseClause.ELSE`**: the dangling-else problem. After parsing the
  THEN branch of an inner IF, an upcoming `ELSE` could belong to that
  inner IF or to an outer IF. GW-BASIC binds it to the innermost, so
  we prefer rule 57 (`ELSE @ELSE ThenClause`) over rule 58 (epsilon).

The build keeps whichever rule was inserted **first**, which (by
production order in `bnf.txt`) is the non-epsilon one in both cases.
This matches GW-BASIC's behaviour, so we accept the warnings rather
than rewrite the grammar.

## The parse loop

`parse.bat`'s `:parse` function is small enough to summarise:

1. Initialise the parse stack to `StmtList $` and read the first
   input token.
2. Classify the input token into a terminal class (`:_classify`).
3. **Loop:**
   - Pop the stack top.
   - If it's an `@action`, emit and continue.
   - If it's `$` (end-of-stack) and input is `$`: success.
   - If it equals the current terminal: consume the input, advance,
     emit if it's a value-bearing token.
   - Otherwise: look up `(top, terminal)` in the parse table to get
     a rule number. Get the rule's RHS. Replace the popped top with
     the rule's RHS (or pop nothing if RHS is `e`).
4. Returns the postfix string in `__` (or the named retVar).

There's one extra branch: if input is exhausted (`$`) but the stack
isn't, try the epsilon entry `(top, $)` to see if the remaining
nonterminals can collapse to nothing. That's how empty statements and
trailing `e` productions terminate.

## Errors

When the parser hits a `(top, terminal)` cell that's not in the table,
it bails with errorlevel 2 and a stderr message:

```
Syntax error: No rule for Stmt with token MINUS (MINUS)
```

The REPL drops back to the prompt; the RUN loop terminates the program
and sets `ERR` / `ERL` (well, will — that wiring isn't fully in place
on the lexer/parser side yet; see the [Errors planned article](README.md)).

## Where this connects

- **Lexer → Parser**: token classification at `:_classify` is the seam.
  Add a new token form (say, a date literal `DATE_…`) and you also add
  one line to `:_classify` to map it to its terminal class.
- **Parser → Executor**: the output postfix stream is what the executor
  walks. New actions in the grammar (`@FOO`) just need a matching
  `src/rtl/FOO.bat`; no other plumbing.
- **`bnf.txt` is the spec.** Any change there triggers `_rebuild.bat`
  (manually), which regenerates `_table.dat`. Both files are committed,
  so end users don't pay rebuild cost.
