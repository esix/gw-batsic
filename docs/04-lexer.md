# Lexer

The lexer reads a hex-encoded line (see [03 — Strings & hex](03-strings-hex.md))
and produces a space-separated **token stream**. It's a hand-written state
machine, one transition per hex pair, with a side table of GW-BASIC keywords.

## Entry and output

```
call %GWSRC%\lexer\lexer ParseTxt <hex> <retVar>
```

The hex argument is the line in hex pairs (e.g. `31302050524953` for `"10 PRI"`).
The output goes into `<retVar>` as a space-separated string of tokens.
If `<retVar>` is omitted, tokens are echoed to stdout.

Tokens always end with the sentinel `EOL`.

## Token types

| Token form | Meaning | Example |
|---|---|---|
| `LN__nnn` | Line number at the start of a line | `LN__10` |
| `NUM_<tagged>` | Numeric literal, already converted to MBF | `NUM_i000A`, `NUM_s83200000`, `NUM_d8649…` |
| `STR_<hex>` | String literal `"…"`, body in hex | `STR_48454C4C4F` for `"HELLO"` |
| `REM_<hex>` | Comment body (everything after `REM` or `'`) | `REM_2048454C4C4F` for `" HELLO"` (note leading space) |
| `HEX_<hex>` | `&H…` hex integer literal | `HEX_FF` for `&HFF` |
| `OCT_<oct>` | `&O…` or `&…` octal literal | `OCT_17` for `&O17` |
| `VAR_UNK_<NAME>` | Identifier, untyped (resolves via DEF table) | `VAR_UNK_A`, `VAR_UNK_COUNT` |
| `VAR_INT_<NAME>` | Identifier with `%` suffix | `VAR_INT_A` |
| `VAR_SNG_<NAME>` | Identifier with `!` suffix | `VAR_SNG_A` |
| `VAR_DBL_<NAME>` | Identifier with `#` suffix | `VAR_DBL_A` |
| `VAR_STR_<NAME>` | Identifier with `$` suffix | `VAR_STR_S` |
| `<KEYWORD>` | A recognised reserved word, kept as-is | `PRINT`, `FOR`, `TO`, `THEN`, … |
| `OPAR CPAR` | `(` `)` | |
| `COMA SEMICOLON COLON HASH` | `,` `;` `:` `#` | |
| `PLUS MINUS MUL DIV IDIV POW` | `+` `-` `*` `/` `\` `^` | |
| `EQ LT GT LE GE NE` | `=` `<` `>` `<=` `>=` `<>` | |
| `EOL` | End of line marker (always last) | |

A few invariants worth noting:

- Numbers are converted to their tagged binary form at lex time. The
  parser and executor never see the original decimal — `10` is already
  `NUM_i000A` by the time it leaves the lexer.
- Identifiers are case-insensitive and stored uppercase. `Print`, `print`,
  and `PRINT` all become the keyword `PRINT`; `count`, `Count`, `COUNT`
  all become `VAR_UNK_COUNT`.
- The type suffix becomes part of the token *type*, not part of the name.
  `A%` is `VAR_INT_A`, not `VAR_UNK_A%`.

## The state machine

Each iteration of `:_Loop` reads one hex pair (`!buffer:~%ii%,2!`),
classifies it (`isSpace`, `isNumber`, `isLetter`, `isEol`), then dispatches
to a `:_S_<state>` label by `goto :_S_!state!`.

States:

| State | Triggered by | What it accumulates / emits |
|---|---|---|
| `Start` | very first non-space character on a line | If it's a digit, swap to `LineNumber`. Otherwise drop into `Normal`. |
| `LineNumber` | digit encountered in `Start` state | Accumulates digits; on first non-digit emits `LN__nnn`. |
| `Normal` | the default mid-line state | One-shot dispatch: emits single-character operator tokens directly, switches into a sub-state for anything that needs accumulation (identifier, number, string, comment, `&`, `<`, `>`). |
| `Id` | letter encountered in `Normal` | Accumulates letters/digits into `acc`. Ends on type suffix (`$ % ! #`) or any other character. Looks the identifier up in the keyword table; if matched, emits the keyword name; otherwise emits `VAR_UNK_<acc>`. |
| `Number1` / `Number2` / `Number3` | digit, then `.`, then `E`/`D` | Three-stage number lexer: integer part → fractional part → exponent. `ntype` tracks the inferred or forced type (`i` / `s` / `d`). Calls into the num facades to convert at exit (see "Numbers" below). |
| `Quote` | `"` in `Normal` | Accumulates raw hex pairs until the closing `"` or EOL. Emits `STR_<hex>`. |
| `Rem` | `REM` keyword or `'` | Accumulates raw hex pairs until EOL, including the space right after `REM`. Emits `REM_<hex>`. |
| `Less` / `More` | `<` or `>` in `Normal` | One-character lookahead for `<=`, `>=`, `<>`. Emits `LT` / `LE` / `NE` / `GT` / `GE`. |
| `Ampersand` | `&` in `Normal` | Looks at next char: `H` → switch to `HexLit`; `O` or digit → `OctLit`; anything else, drop back to `Normal`. |
| `HexLit` / `OctLit` | inside `&H…` / `&O…` | Accumulates hex / octal digits, emits `HEX_<hex>` / `OCT_<oct>`. |

State machine is small enough to fit in one file. The fall-through at the
bottom (`:_LoopEnd`) flushes any half-built token (Number1/Number2/Number3,
Id, Rem, Quote, HexLit, OctLit), then appends the final `EOL`.

## The hex-to-ASCII table

`_h_XX` maps a hex pair to a single uppercase character — `_h_30=0`,
`_h_31=1`, `_h_41=A`, `_h_61=A`, `_h_2E=.`. The table is partial: it only
covers what identifiers and numbers need (digits, letters in both cases,
the decimal point). State transitions classify by hex *range* (e.g.
`if !c! GEQ 41 if !c! LEQ 5A set "isLetter=T"`), and accumulation goes
through `_h_<c>` to map hex back to the literal character for putting
into `acc`. The case-folding to uppercase happens here implicitly:
`_h_61` (lowercase `a`) maps to uppercase `A`, so an identifier like
`Count` ends up in `acc` as `COUNT`.

This is the same trick used in `src/str/` but inlined into the lexer
to avoid one call per character.

## Numbers

The interesting subsystem. Inputs can be:

- bare integers: `10`, `-42` (the sign is handled by the parser, not the
  lexer)
- integer with type suffix: `10%`, `10!`, `10#`
- decimals: `3.14`, `.5`
- E-notation single: `1E2`, `1.5E-3`
- D-notation double: `1D10`, `2.5D-5`
- forced int via `%`, single via `!`, double via `#`

The state machine moves through:

```
        ┌── digit ──────► Number1 ───── .  ──► Number2
        │                     │                  │
   (Normal)                 E/D                E/D
        │                     │                  │
        └── . ────────► Number2 ──── E/D ──► Number3
```

`acc` collects the literal text (digits, decimal point, `E` / `D`, sign).
`ntype` is updated as we go:

- Number1 with no suffix and no `.` / `E` / `D` → try `int`; if it
  overflows (out of −32768..32767), fall back to `single`.
- Number2 (had a `.`) defaults to `single`.
- Number3 (had `E` or `D`) is forced to single or double respectively.
- Explicit suffix overrides: `%` → int (back to Number1's emit), `!` →
  single, `#` → double.

At the emit point (`:_S_EmitNum` / `:_FlushNum`), the lexer calls into
`%GWSRC%\num\<type>\fromDec` to convert the accumulated decimal string
to its tagged binary form, then appends `NUM_<tagged>` to the token
stream.

This is the boundary where the numerics module ([02](02-numerics.md))
plugs in. After the lexer runs, every numeric value in the token stream
is already in MBF form — bit-identical to what GW-BASIC stores in its
own internal program format.

## Identifiers, keywords, and type suffixes

When `:_S_Id` accumulates a letter run, the only thing that can
**terminate** it is a non-letter, non-digit character. There are four
suffix characters that turn the identifier into a typed variable:

| Char | Hex | Token emitted |
|---|---|---|
| `$` | 24 | `VAR_STR_<acc>` |
| `%` | 25 | `VAR_INT_<acc>` |
| `!` | 21 | `VAR_SNG_<acc>` |
| `#` | 23 | `VAR_DBL_<acc>` |

For anything else (space, operator, EOL), the lexer looks the
accumulated name up against the keyword table. If matched, it emits the
keyword as the token (e.g. `acc=PRINT` → tokens `… PRINT`). If not, it
prefixes with `VAR_UNK_` and emits.

Two minor wrinkles:

- The `$` suffix on a known keyword turns it into a different keyword
  (e.g. `LEFT$`, `MID$`). That's handled by `keyword isKeywordStr`,
  which returns success for the names that have a `$` form. On a match,
  the lexer emits `<NAME>_STR` as a single keyword token (`LEFT_STR`)
  rather than `VAR_STR_LEFT`.
- When the lexer emits the `REM` keyword, it immediately switches to the
  `Rem` state to capture the comment body. Same idea as `'`, which goes
  straight to `Rem` without an intermediate keyword token. The trailing
  comment ends up as `REM REM_<hex>` in the stream — `REM` the keyword,
  then `REM_…` the body. The unlexer prints them together as
  `REM HELLO`.

## The keyword table

`src/lexer/keyword.bat` is a flat list of ~175 GW-BASIC reserved words
with their **binary token codes** — 1-byte codes like `91` for `PRINT`,
or 2-byte codes like `FE83` for `SYSTEM`. The table is bidirectional:

| Call | What it does |
|---|---|
| `keyword init` | Loads `_k_<code>=<name>` and `_c_<name>=<code>` into env vars. Must be called once at startup. |
| `keyword isKeyword <name>` | Returns errorlevel 0 if name is a keyword. |
| `keyword isKeywordStr <name>` | Same, but for names that take a `$` suffix (`LEFT`, `MID`, `RIGHT`, etc.). |
| `keyword toCode <name>` | `__` ← binary code for the keyword. |
| `keyword fromCode <code>` | `__` ← keyword for the binary code. |

The binary codes match Microsoft's original GW-BASIC program file
format. Right now only `isKeyword` and `isKeywordStr` get called from
the lexer, but the `toCode` / `fromCode` pair is what will be used when
the loader / saver for `.BAS` binary files gets written: each tokenised
line in a GW-BASIC program file is a length byte, a line-number word,
then a sequence of bytes where keywords appear as their token codes
(single-byte `91 …`, or two-byte `FE 83`) and literals are interleaved
in a fixed format. So the table is already in place; it just isn't
fully wired up yet.

## Unlexer

`src/lexer/unlexer.bat` is the inverse: tokens → readable text. It uses
the same hex-to-character helpers as `str decode` plus the keyword
table's names, with one wrinkle: when emitting a single-precision typed
identifier (`VAR_SNG_A` → `A!`), the literal `!` has to be assembled
through a `setlocal DisableDelayedExpansion` shim to keep `cmd.exe` from
eating it. The unlexer's `print` entrypoint sidesteps the return-value
problem entirely by writing directly to stdout — see the unlexer file
for the comment about it.

## Where this is heading

Two things outside this article that connect back to the lexer:

- **`.BAS` binary loading / saving.** The byte-level format of a saved
  GW-BASIC program uses the same token codes the lexer's keyword table
  already knows. The plan is to add `loadBin` / `saveBin` actions that
  walk a `.BAS` file, emit our token stream, and store it via
  `_program add` — or, in reverse, read a stored line's tokens and
  serialise to the binary format. This is the main motivation for
  keeping `toCode` / `fromCode` available even though the live lexer
  doesn't need them.
- **Error recovery.** The lexer currently fails fast (`:_Error` echoes
  some debug and returns errorlevel 2). A real GW-BASIC would surface a
  "Syntax error" with `ERL` set. Now that the error mechanism is in
  place ([article 08, planned](README.md)), the lexer should plug into it
  and return a proper error code that propagates through the run loop.
