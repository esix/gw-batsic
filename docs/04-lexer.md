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
format. The lexer itself only needs `isKeyword` / `isKeywordStr`, but
`toCode` / `fromCode` are actively used by the `.BAS` binary converter
in `src/file/_binary.bat` to translate between our internal token names
and the on-disk byte stream (see "Binary `.BAS` format" below).

The table holds three kinds of entry:

- **User-typed keywords** (`PRINT`, `FOR`, `LEFT$`, …) — both `_k_XX` and
  `_c_NAME` are set, so the keyword is reachable in both directions.
- **Operator tokens** at `E6`–`ED` and `F4` (`GT`, `EQ`, `LT`, `PLUS`,
  `MINUS`, `MUL`, `DIV`, `POW`, `IDIV`) — only `_k_XX` is set. These
  bytes appear in the binary format the same way keywords do, but their
  internal names aren't things a user can type as identifiers, and we
  don't want `isKeyword` to return true for `"PLUS"`. The binary
  converter has its own op-name → byte lookup for the reverse direction.
- **`_k_D9 = '`** (apostrophe shorthand for `REM`) — also reverse-only.
  Same reasoning: `'` is never an identifier, so there's no `_c_'`.

## Unlexer

`src/lexer/unlexer.bat` is the inverse: tokens → readable text. It uses
the same hex-to-character helpers as `str decode` plus the keyword
table's names, with one wrinkle: when emitting a single-precision typed
identifier (`VAR_SNG_A` → `A!`), the literal `!` has to be assembled
through a `setlocal DisableDelayedExpansion` shim to keep `cmd.exe` from
eating it. The unlexer's `print` entrypoint sidesteps the return-value
problem entirely by writing directly to stdout — see the unlexer file
for the comment about it.

## Binary `.BAS` format

GW-BASIC saves programs by default in a tokenised binary format. The
lexer doesn't read these files directly — instead, `src/file/_binary.bat`
is a **token-level converter** that sits at the file boundary: bytes on
disk in, our internal token stream out (and vice versa). Once a binary
file is loaded, every layer above it (parser, executor, REPL) is
oblivious to where the program came from.

File layout:

```
FF <line> <line> ... 00 00 1A
```

Each `<line>`:

```
<next_ptr_lo><next_ptr_hi> <num_lo><num_hi> <content...> 00
```

The `content` bytes inside a line:

| Byte(s) | Meaning |
|---|---|
| `0B xx xx` | Octal literal (2-byte LE) |
| `0C xx xx` | Hex literal (2-byte LE) |
| `0E xx xx` | Line-number reference (after `GOTO` / `THEN` / etc.) |
| `0F nn` | 1-byte unsigned int (11..255) |
| `11..1A` | Small int constants 0..9 (note: 10 uses `0F 0A`) |
| `1C xx xx` | 2-byte LE signed int (256..32767) |
| `1D <4 bytes>` | MBF single, LE mantissa + exp last, bias 129 |
| `1F <8 bytes>` | MBF double, same layout, bias 129 |
| `20..7E` | ASCII (var name chars, `$%!#`, `()[],;:`, `"`, …) |
| `81..FC` | Single-byte keyword token |
| `FD xx` / `FE xx` / `FF xx` | Two-byte keyword token |

Two things bridge directly to the lexer:

- **Keyword codes.** `_binary` looks each keyword byte up via
  `keyword fromCode`. The single-byte form is `91 → PRINT`; the two-byte
  forms (`FD`, `FE`, `FF` prefixes) cover file I/O, system, and function
  keywords respectively. This is why `keyword.bat` carries the full
  bidirectional table even though the live lexer only needs `isKeyword`.
- **MBF bias.** Our MBF uses bias 128; GW-BASIC's binary format uses
  bias 129. The converter adds 1 when writing, subtracts 1 when reading.
  Everything else about the mantissa layout (little-endian, exp last) is
  identical — see [02 — Numerics](02-numerics.md).

The converter also handles a few less obvious cases:

- **Multi-byte comparisons.** `>=` is stored as `E6 E7` (two bytes,
  `GT` followed by `EQ`); `<=` is `E8 E7`; `<>` is `E8 E6`. The reader
  peeks one byte ahead after seeing `E6` or `E8` and emits a single
  `GE` / `LE` / `NE` token rather than two.
- **Apostrophe vs REM.** `8F` introduces a comment body that runs until
  the line's terminating `00`. The two forms are distinguished by what
  follows the `8F`:
    - `REM body` is stored as `8F <body>`. The reader emits
      `REM REM_<body>` (two tokens).
    - `'body` is stored as `3A 8F D9 <body>` (GW-BASIC inserts the
      leading colon automatically). The reader strips the `D9` marker
      and emits only `REM_<body>` — no preceding `REM` keyword. This
      matches what the ASCII lexer emits for `'body`, so a `'` survives
      a binary→tokens→binary round-trip.
  The writer reconstructs the two forms by looking at whether `REM_<body>`
  is preceded by a `REM` token (explicit form) or stands alone
  (apostrophe form).
- **Line-number references.** After certain keywords (`GOTO`, `GOSUB`,
  `THEN`, `ELSE`, `RESUME`, `RESTORE`, `RUN`, `LIST`, `DELETE`, `EDIT`,
  `AUTO`, `RENUM`, `RETURN`), integer arguments are stored with the
  `0E xx xx` marker rather than the generic `0F` / `1C` integer
  encoding. The marker is what `RENUM` walks to find every reference
  that needs updating. The writer arms a "line-ref mode" flag when it
  emits any of those keywords; subsequent `NUM_i` tokens go out as
  `0E xx xx` until the mode is cleared (any non-integer, non-`MINUS`,
  non-`COMA` token clears it — so `LIST 10-20` and `ON X GOTO 10,20,30`
  both produce a series of `0E` references).
- **Cosmetic `0x20` spaces.** GW-BASIC scatters single spaces into the
  binary form for readability when re-listed. The reader treats them as
  separators and drops them.

The reader/writer use `certutil -encodehex … 12` (the "no-offset, no
ASCII column" format) and `-decodehex` for file I/O, then walk the
hex pairs the same way the lexer's main loop walks an input line.

## Where this is heading

- **Error recovery.** The lexer currently fails fast (`:_Error` echoes
  some debug and returns errorlevel 2). A real GW-BASIC would surface a
  "Syntax error" with `ERL` set. Now that the error mechanism is in
  place ([article 08, planned](README.md)), the lexer should plug into it
  and return a proper error code that propagates through the run loop.
- **Protected / encrypted programs.** GW-BASIC also supports `SAVE
  "name",P` (protected, header byte `FE`) which XOR-encrypts the
  tokenised body. We detect the binary format by the `FF` header byte
  only, so protected files are currently rejected. The converter would
  need an unscramble pass before the byte loop.
