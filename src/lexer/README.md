# src/lexer — GW-BASIC Lexer

Tokenizes GW-BASIC source code from text (ASCII) format into an internal token stream. Binary (tokenized) format parsing is planned.

## Usage

```batch
@REM Initialize keyword tables (once at startup)
call keyword init

@REM Tokenize a hex-encoded source line
call lexer ParseTxt <hex-buffer> <result-var>
echo !result!
```

Input is a hex-encoded string (pairs of hex chars, e.g., `313020313030` for `10 100`). Output is a space-separated token stream in the named variable (or stdout if no variable given).

## Token Types

### Line Number

| Token | Example | Meaning |
|-------|---------|---------|
| `LN__nnn` | `LN__10` | Line number (decimal) |

### Numeric Literals (binary-encoded)

Numbers are converted to tagged binary during lexing — same format as `src/num` module.

| Token | Example | Meaning |
|-------|---------|---------|
| `NUM_i....` | `NUM_i0064` | Integer 100 |
| `NUM_s........` | `NUM_s83200000` | Single-precision 10.0 |
| `NUM_d................` | `NUM_d8320000000000000` | Double-precision 10.0 |
| `HEX_xxxx` | `HEX_FF` | Hex literal `&HFF` (not yet converted) |
| `OCT_oooo` | `OCT_77` | Octal literal `&O77` (not yet converted) |

Type is determined by context:
- Plain integer in -32768..32767 range → `i` (integer)
- Has `.` or `E` exponent → `s` (single)
- Has `D` exponent → `d` (double)
- Suffix `%` → force integer, `!` → force single, `#` → force double

### String Literals

| Token | Example | Meaning |
|-------|---------|---------|
| `STR_hh...` | `STR_48656C6C6F` | String `"Hello"` (hex-encoded bytes) |

Content between quotes is stored as raw hex pairs. No quote characters in the token.

### Comments

| Token | Example | Meaning |
|-------|---------|---------|
| `REM` | `REM` | REM keyword (always followed by `REM_` token) |
| `REM_hh...` | `REM_204849` | Comment text ` HI` (hex-encoded bytes) |

Both `REM` and `'` (comment shorthand) produce a `REM` keyword token followed by a `REM_` content token with hex-encoded text.

### Variables

| Token | Example | Meaning |
|-------|---------|---------|
| `VAR_UNK_name` | `VAR_UNK_A` | Untyped variable |
| `VAR_STR_name` | `VAR_STR_A` | String variable (`A$`) |
| `VAR_INT_name` | `VAR_INT_A` | Integer variable (`A%`) |
| `VAR_SNG_name` | `VAR_SNG_A` | Single variable (`A!`) |
| `VAR_DBL_name` | `VAR_DBL_A` | Double variable (`A#`) |

Variable names are uppercase ASCII. Digits are allowed after the first letter (`A1`, `XY2`).

### Keywords

Recognized GW-BASIC keywords are emitted as their name in uppercase:

| Token | Examples |
|-------|---------|
| Statements | `PRINT`, `GOTO`, `GOSUB`, `IF`, `FOR`, `NEXT`, `LET`, `DIM`, `REM`, `END`, `STOP`, `RETURN`, `INPUT`, `READ`, `DATA`, `DEF`, `ON`, `OPEN`, `CLOSE`, `WHILE`, `WEND`, ... |
| Sub-keywords | `THEN`, `TO`, `STEP`, `USING`, `OFF` |
| Operators | `AND`, `OR`, `XOR`, `NOT`, `MOD`, `EQV`, `IMP` |
| Functions | `ABS`, `INT`, `SGN`, `SQR`, `SIN`, `COS`, `TAN`, `ATN`, `LOG`, `EXP`, `RND`, `FIX`, `LEN`, `VAL`, `ASC`, `PEEK`, `POS`, `FRE`, `LOC`, `LOF`, `EOF`, `CINT`, `CSNG`, `CDBL`, ... |
| String functions | `LEFT$`, `RIGHT$`, `MID$`, `CHR$`, `STR$`, `SPACE$`, `STRING$`, `HEX$`, `OCT$`, `INKEY$`, `DATE$`, `TIME$`, `MKI$`, `MKS$`, `MKD$`, `VARPTR$` |

`?` is recognized as shorthand for `PRINT`.

### Arithmetic Operators

| Token | Character | GW-BASIC |
|-------|-----------|----------|
| `PLUS` | `+` | Addition |
| `MINUS` | `-` | Subtraction |
| `MUL` | `*` | Multiplication |
| `DIV` | `/` | Division |
| `IDIV` | `\` | Integer division |
| `POW` | `^` | Exponentiation |

### Comparison Operators

| Token | Character | Meaning |
|-------|-----------|---------|
| `EQ` | `=` | Equal (also assignment) |
| `LT` | `<` | Less than |
| `GT` | `>` | Greater than |
| `LE` | `<=` | Less or equal |
| `GE` | `>=` | Greater or equal |
| `NE` | `<>` | Not equal |

### Delimiters

| Token | Character | Meaning |
|-------|-----------|---------|
| `OPAR` | `(` | Open parenthesis |
| `CPAR` | `)` | Close parenthesis |
| `COMA` | `,` | Comma |
| `SEMICOLON` | `;` | Semicolon |
| `COLON` | `:` | Colon (statement separator) |
| `HASH` | `#` | Hash (file number prefix) |

### Control

| Token | Meaning |
|-------|---------|
| `EOL` | End of line (appended to every line) |

## Files

```
keyword.bat    Keyword token table (bidirectional: name <-> binary code)
               Call "keyword init" once at startup to load tables.
               isKeyword, isKeywordStr, toCode, fromCode

lexer.bat      ParseTxt: hex-encoded ASCII -> token stream
               (ParseBin: tokenized binary -> token stream — planned)
```

## Dependencies

- `src/num/int.bat`, `sng.bat`, `dbl.bat` — for number conversion during lexing
- `lib/byte.bat`, `lib/chr.bat`, `lib/buffer.bat` — low-level byte utilities
