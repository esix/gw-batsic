# Strings & hex encoding

`src/str/` exists to solve one problem: getting arbitrary user-typed text
through `cmd.exe` without it being mangled or interpreted. The answer the
project lands on is to convert text to a hex string at the boundary and
keep it that way until the consumer explicitly decodes it.

## What batch does to your text

Type `PRINT "A > B"` at a real GW-BASIC prompt and it just works. Type it
at a batch script and you've got problems before anything else runs:

- `>` is output redirection. `echo PRINT "A > B"` redirects everything
  after `>` into a file named `B"`.
- `<` is input redirection.
- `|` is a pipe.
- `&` is a command separator.
- `%var%` expands at parse time, eating any literal `%` next to a name.
- `!var!` expands at execution time when delayed expansion is enabled.
- `^` is the escape character; a stray `^` at end of line continues to
  the next line.
- `(` and `)` group inside `if` / `for`; an unbalanced `(` inside a
  parenthesised block breaks parsing.
- `"` quoting is its own dialect; `""` inside an already-quoted argument
  is two literal quotes in some contexts, a single quote in others.

None of those are escapable without context. `echo ^>` works at the
command line; `echo ^^>` works inside a parenthesised block; neither
helps once the text has already entered an env var and we're trying to
pass it onward through `call`, `for /f`, or `set "x=%var%"`.

The hex string `48` is just two characters, `4` and `8`, in
`[0-9A-F]`. No metacharacter ever appears in a hex-encoded payload, so
every subsequent step can treat the value as opaque ASCII text — `set`
it, `call` it, write it to a file, read it back, compare it for
equality, concatenate it. The decoding moment is pushed all the way to
the consumer that needs the original characters back: the display path
(`PRINT`), the unlexer (`LIST`), the comment / string-literal token
contents inside the lexer.

## The `str` module

`src/str/str.bat` is a small facade with five operations:

| Call | What it does |
|---|---|
| `str encode "text" retVar` | Text → hex pairs. `HELLO` → `48454C4C4F`. |
| `str decode hex retVar` | Hex pairs → text. `48454C4C4F` → `HELLO`. |
| `str ch2hex ch retVar` | One character → one hex pair. |
| `str hex2ch hex retVar` | One hex pair → one character. |
| `str input "prompt" retVar` | Prompt the user, return what they typed as hex. |

All outputs are uppercase hex (`A`-`F`, not `a`-`f`). Lookup tables sit at
the top of `str.bat` and load on every script entry:

- `_c2h_X` — character → hex pair, for characters that can be used in a
  batch variable name. Used by `encode` and `ch2hex`.
- `_h2c_XX` — hex pair → character. Used by `decode` and `hex2ch`.

The two tables aren't symmetric, and that asymmetry is interesting.

## The case-insensitivity wrinkle

Batch variable names are case-insensitive. `set "_c2h_A=41"` and
`set "_c2h_a=61"` end up writing to the **same** variable; the second
overwrites the first. So a forward-lookup table indexed by character
can't tell `A` from `a`.

Two consequences:

- The `_c2h_` table only has entries for **uppercase letters**. They map
  to the uppercase hex (`A` → `41`). Lowercase letters fall through.
- `encode` and `ch2hex` handle letters with a separate code path: if the
  character looks up to nothing, scan the alphabet `ABCDEFGHIJKLMNOPQRSTUVWXYZ`,
  find where it matches (case-insensitively, since `if "!_uabc:~%%j,1!"=="!_ch!"`
  is itself case-insensitive), and synthesise the hex from the ASCII code
  via `set /a`. The fallback is `3F` (a literal `?`) for anything not
  recognised — symbols outside the table land here.

This means the **encode side is case-insensitive**: `encode "hello"` and
`encode "HELLO"` both produce `48454C4C4F`. That suits GW-BASIC, which
upper-cases identifiers and keywords anyway. When the project does need
to preserve case (string literals inside quotes), it uses `str input`
instead — see below — which goes through `certutil` and preserves every
byte exactly.

The reverse direction is fine: `_h2c_41` and `_h2c_61` are distinct env
var names, so the decode table maps `41` → `A` and `61` → `a` correctly.

## The input problem

Reading a line from the keyboard is the worst case. `set /p` is the only
builtin that prompts, and:

- Inside `set /p "VAR=PROMPT"`, the value the user typed is taken
  literally — quotes, `%`, `&`, `<`, `>` are all stored verbatim in the
  env var.
- The instant the script tries to **use** that env var — even
  `echo !VAR!` — the special characters reassert themselves.

Practically: if the user types `PRINT "A > B"`, `set /p` happily stores
that, and then `echo !VAR!` does redirection.

`str input` works around it with two steps:

1. `cmd /V:ON /C >"%_tf%" echo(!_in!`

   Spawn a child `cmd.exe` with delayed expansion on. The child sees the
   `!_in!` text passed in via its environment (already stored by the
   parent's `set /p`) and writes it to a temp file. The `echo(` form
   (`echo` followed by `(` with no space) is the safest variant — it
   prints the rest of the line literally without interpreting `off` /
   `on` and tolerates an empty argument. Redirection (`>`) happens before
   the inner `echo` runs, so any user-typed `>` in `!_in!` is harmless by
   the time it reaches `echo`.

2. `certutil -encodehex "%_tf%" "%_hf%" 12`

   `certutil` is a Windows-shipped utility (intended for certificate
   management) that has, as a side feature, a hex-dump mode. Format `12`
   asks for **raw hex with no offset column, no ASCII gutter, no spaces**
   — exactly the format the rest of the project wants. The output goes
   to a second temp file.

Then `set /p "_r=" < "%_hf%"` reads the first line of that file back. A
trailing `0d0a` (CR LF from the file write) is stripped. Some versions of
`certutil` emit lowercase hex; six `set "_r=!_r:a=A!"`-style passes lift
it to uppercase so the rest of the project sees a consistent dialect.

## What's still hard

`%` survives the round trip badly. The user-side `set /p` stores `%`
fine; the trouble is reading the variable back. `set /p` itself uses
delayed-style expansion of its own RHS, but everywhere else `%var%` and
`!var!` interpret `%` as the start of a name reference. `cmd /V:ON /C`
helps with `!` but doesn't fully escape `%`. In practice, a user line
containing a literal `%` (outside of a string literal) is a known limit;
inside string literals it usually round-trips correctly because the lexer
captures the bytes between `"` and `"` directly from the hex.

The `?` fallback in `encode` also flattens any non-tabulated character to
a literal `?`. Real GW-BASIC supports the OEM 8-bit code page for string
literals — we currently round-trip 7-bit ASCII faithfully and replace
everything else with `?`. Extending the tables is mechanical; it just
hasn't been needed yet.

## Where hex flows through the rest of the project

- **Lexer input.** The REPL calls `str input "> " _hex`. The lexer's
  `ParseTxt` walks the hex pair by pair: `20` is whitespace, `2A`-`5A`
  letters and digits, etc. It never sees raw characters from the user.
- **String and comment tokens.** When the lexer enters the Quote or Rem
  state, it accumulates the raw hex pairs of the body directly into the
  token: `STR_48454C4C4F` is `"HELLO"`. Decoding happens later, at
  display time inside the unlexer (and at runtime inside the `PRINT`
  RTL).
- **`LIST`.** The unlexer's `print` goes the other way: tokens →
  readable text. String and REM bodies get pushed through `str decode`
  to recover the original characters before they hit `echo`.
- **`certutil` is invoked once per typed line.** It's not the fastest
  thing on the planet, but for an interactive REPL it's fine, and it's
  the only Windows-shipped tool we found that emits clean hex without
  external dependencies.

The hex convention is the part of the project most directly forced by
the implementation language. Without it, every other module would have
to defend itself against batch's metacharacters; with it, modules can
treat strings as opaque blobs and only worry about characters at the
edges where it actually matters.
