# PRINT, PRINT USING, and WRITE formatting

The console-output family is where GW-BASIC's screen-layout conventions
collide head-on with `cmd.exe`'s refusal to emit a leading space. `PRINT`,
its file-channel cousin `PRINT #`, the formatted `PRINT USING`, and the
CSV-shaped `WRITE` all reduce to a single stack-machine pattern: the parser
pushes the items, then drops *separator actions* into the postfix stream,
and each separator action pops the one pending item, renders it to the
right textual form, and emits it — with or without a trailing newline,
with or without zone padding.

The interesting work is almost entirely in two places: the GW-BASIC
numeric **sign-space convention** (every number carries a leading space for
its sign, positive or negative) and the **14-column print zones** that the
comma separator pads to. Both depend on one piece of cursor state,
`_print_col`, threaded through every separator handler. This doc walks the
members, then tells the war stories of getting leading whitespace to
survive `cmd.exe`'s output plumbing.

## Calling convention recap

These are ordinary RTL action handlers — one `.bat` per postfix token in
`src/rtl/`, dispatched by the executor when it hits an `@NAME` action. (See
[07 — Executor & RTL](README.md#implemented-features) for the dispatch loop
and the `endlocal &`-propagation idiom; the postfix-output mechanism is in
[05 — Parser](05-parser.md).) Every handler receives the name of the eval
stack as `%~1`, pops what it needs with `vec pop`, does its work, and
returns the (now shorter) stack through the standard

```
endlocal & set "%~1=%_final%" & set "_print_col=%_print_col%" & exit /B 0
```

idiom so that the mutated stack *and* the updated cursor column survive the
`setlocal` scope. Numbers on the stack are tagged values (`i`/`s`/`d`
prefix, see [02 — Numerics](02-numerics.md)); strings are `STR_<hex>`.
Before rendering, every handler calls `%GWSRC%\exec\_resolve` to turn a bare
`VAR_` token into its current value — skipping that resolve was the cause
of one of the bugs below.

The grammar (`src/parser/bnf.txt`) decides *which* separator fires:

| Postfix action | Emitted when | File |
|---|---|---|
| `@PEND` | list ends with no separator — prints item **and a newline** | `PEND.bat` |
| `@PEND_NONL` | bare `PRINT;` (empty body, semicolon) — pure no-op | `PEND_NONL.bat` |
| `@PSEMI` | `;` between items — print item, no newline, no padding | `PSEMI.bat` |
| `@PSEMI_END` | trailing `;` — same as `@PSEMI` (delegates to it) | `PSEMI_END.bat` |
| `@PTAB` | `,` between items — print item, pad to next 14-col zone | `PTAB.bat` |
| `@PTAB_END` | trailing `,` — same as `@PTAB` (delegates to it) | `PTAB_END.bat` |
| `@PZONE` | a `,` with **no** pending item (`PRINT ,X`, `PRINT A,,B`) | `PZONE.bat` |
| `@FN_TAB` / `@FN_SPC` | `TAB(n)` / `SPC(n)` inside the list | `FN_TAB.bat` / `FN_SPC.bat` |
| `@PU_MARK` … `@PRINT_USING` … `@PU_NL` | `PRINT USING fmt$; v1; v2 …` | `PU_MARK.bat`, `PRINT_USING.bat`, `PU_NL.bat` |
| `@WRITE_MARK` … `@WRITE` | `WRITE v1, v2 …` | `WRITE_MARK.bat`, `WRITE.bat` |

### Juxtaposition is an implicit semicolon

GW-BASIC lets adjacent print items run together with no separator
(`PRINT "X"N"Y"`). The grammar encodes this in `PrintAfter`:

```
PrintAfter    ::= @PEND
PrintAfter    ::= SEMICOLON PrintSemi
PrintAfter    ::= COMA PrintComa
PrintAfter    ::= @PSEMI PrintItem PrintAfter
```

The last production fires on any token that can *start* a new item, so
juxtaposed items behave exactly like a `;` — they get `@PSEMI` between
them. Tokens that can *continue* the current expression (notably `MINUS`)
are grabbed by the expression parser first, so `PRINT A -5` is still a
subtraction, not two items. The grammar comment flags this as two
deliberate FIRST/FOLLOW conflicts resolved in GW-BASIC's favour.

## The sign-space convention and `_print_col`

In GW-BASIC every numeric value prints with a **leading space reserved for
the sign**: `42` displays as `" 42"`, `-42` as `"-42"`, the sign sitting in
that reserved column. `PEND` (the final, newline-terminating value) renders
exactly that:

```bat
if defined _d (
  if defined _print_path (
    if "!_d:~0,1!"=="-" (call %GWSRC%\exec\_pemit "!_d!") else (call %GWSRC%\exec\_pemit " !_d!")
  ) else (
    if "!_d:~0,1!"=="-" (echo(!_d!) else (echo  !_d!)
  )
)
```

For mid-list values, though, a *trailing* space is also needed, otherwise
`PRINT 1;2;3` would print `" 1 2 3"` with the sign-spaces only — values
would visually abut. So `PSEMI` builds the rendered text as
`" <digits> "` (or `"-<digits> "` for negatives):

```bat
@REM GW numeric form: a leading space for non-negative (the sign position),
@REM the `-` for negative, and ALWAYS a trailing space so consecutive numbers
@REM separate (PRINT 1;2;3 -> " 1  2  3", PRINT -1;2 -> "-1  2").  This is the
@REM mid-list form; @PEND drops the trailing space on the final value.
if defined _d if "!_d:~0,1!"=="-" (set "_txt=!_d! ") else (set "_txt= !_d! ")
```

The asymmetry is deliberate: mid-list numbers carry a trailing space, but
the **final** value (`PEND`) keeps leading-space-only — so the very last
number on a line omits the true GW trailing space. `PRINT 1;2;3` therefore
yields `" 1  2  3"` and `PRINT -1;2;-3` yields `"-1  2 -3"`.

`_print_col` is the 0-based cursor column, advanced by the printed length
of each item and reset to `0` by anything that emits a newline (`PEND`,
`PU_NL`, `WRITE`, and `FN_TAB` when it wraps). The separators that care
about layout — `PTAB`, `PZONE`, `FN_TAB` — read it to compute padding.
String length is taken from the hex (two hex chars per byte) rather than
the decoded text, because delayed expansion can silently eat `!`
characters out of the decoded form (`set /a "_added/=2"`).

### Comma zones

A comma pads to the next 14-column tab stop. `PTAB` prints its item, bumps
`_print_col`, then pads to the next multiple of 14:

```bat
set /a "_pad=14 - (_print_col %% 14)"
if !_pad! GTR 0 if !_pad! LSS 14 (
  set "_hx="
  for /L %%i in (1,1,!_pad!) do set "_hx=!_hx!20"
  call %GWSRC%\str\str decodePrint !_hx! NONL
  set /a "_print_col+=_pad"
)
```

The spaces are built as a hex string of `20` bytes and pushed through
`str decodePrint` rather than echoed — because, as the next section
explains, that is the only reliable way to get leading/standalone spaces
onto the console. `PZONE` is the no-pending-item variant (`PRINT ,X`): it
pads a full zone even when the cursor sits exactly on a boundary, since
there is no value to print first.

### `TAB(` and `SPC(`

`TAB(n)` moves to column `n` (1-based, so target index `n-1`); if the
cursor is already past the target it advances to a new line first, matching
GW-BASIC. `SPC(n)` simply emits `n` spaces inline. Both are `PrintItem`s,
not separators, so after padding they push an **empty `STR_` sentinel** so
the following `@PSEMI`/`@PTAB`/`@PEND` has something to pop:

```bat
@REM Push empty STR_ sentinel so following PSEMI / PTAB has a value to pop.
call %GWSRC%\stl\vec push %_s% STR_
```

That sentinel is why `PRINT TAB(10); 42` works: `FN_TAB` pads to column 9
and leaves `STR_`; `PSEMI` pops the empty sentinel (prints nothing); `PEND`
prints `" 42"` — result `"          42"`. `SPC(n)` with negative `n` returns
error `5` (Illegal function call); a non-numeric argument returns `13`.

## PRINT USING

`PRINT USING fmt$; v1; v2 …` lays values out against a format string.
The grammar factors `USING` through `PrintWhat` so it does not clash with
`PrintBody`'s FIRST set, and emits the postfix
`<fmt> @PU_MARK <v1> <v2> … @PRINT_USING [@PU_NL]`. `PU_MARK` just pushes
the `PU_MARK` sentinel that delimits the value list; `PU_NL` emits the final
newline (and resets `_print_col`) when the value list did *not* end in a
`;` or `,`. The actual rendering is `PRINT_USING.bat`.

The renderer pops values down to `PU_MARK`, resolving each (the fix in the
war stories), reverses them back into source order, pops the format, and
then **walks the format in hex pairs**, consuming pairs off the front of
`_fhex` so every substring uses a constant `~0,2` offset. It *restarts*
the format from the top while values remain (`:_passEnd` →
`if defined _vals … goto :_restart`), which is how `"##";5;10` reuses the
field for the second value and produces `" 510"`.

It dispatches on the leading hex pair:

| Hex | Format char | Field |
|---|---|---|
| `23` | `#` | numeric digit position |
| `2E` | `.` | decimal point |
| `2C` | `,` | thousands grouping |
| `2424` | `$$` | floating dollar sign |
| `2A2A` | `**` | asterisk fill |
| `5C … 5C` | `\ \` | string field, width = inner gap + 2 |
| `21` | `!` | first character of a string |
| `26` | `&` | whole string, unmodified |
| `5F` | `_` | escape: next byte is a literal |

Numeric fields measure their width by counting `#`/`.`/`,`/fill markers,
round the fraction to the number of post-point `#`s (`:_round`, with
carry into the integer part via `:_incDec`), optionally insert commas
(`:_commas`), prefix `$` and the minus sign, then right-justify into the
field width with spaces or `*`. If the rendered body overflows the field,
GW-BASIC prints a leading `%` — the renderer prepends `%` via
`:_t2h "%%!_body!"`. String fields left-justify and pad with `20`
(`:_strFit`). Literal bytes between fields pass straight through
untouched, and the whole assembled output hex is emitted once via
`str decodePrint … NONL`.

`PRINT USING` after a printed item is supported: `PrintAfter` has a
`USING` production, so `PRINT TAB(44) USING fmt;v` (or
`PRINT #1,TAB(4) USING "##";7` to a file) works — the TAB item prints
first, then the USING list renders.

**Not implemented**: the exponential `^^^^` field and the trailing-sign
forms (`+`/`-` *after* a number). The header comment says so plainly.

## WRITE

`WRITE` produces machine-readable CSV: values comma-separated, strings
double-quoted, numbers with **no** leading sign-space, followed by a CRLF.
`WRITE_MARK` pushes the `WRITE_MRK` sentinel below the value list; `WRITE`
pops back to it, then emits each value through `:_emitVal`, separating with
a literal `,` (hex `2C`) and quoting strings with `"` (hex `22`):

```bat
for %%v in (!_vals!) do (
  if not "!_first!"=="1" call %GWSRC%\str\str decodePrint 2C NONL
  set "_first="
  call :_emitVal %%v
)
call %GWSRC%\exec\_pemit "" NL
```

So `WRITE #1,"AB",5,"CD"` writes `"AB",5,"CD"`. Numbers go out *without*
the sign-space (CSV is for re-reading by `INPUT #`, not display), which is
the one place numeric output deliberately diverges from the `PRINT`
convention. The same handler drives both console `WRITE` and file
`WRITE #n` — `WriteHead`'s `@PFILE_SET` sets `_print_path` so the shared
print plumbing appends to the channel; `WRITE` clears the sink on exit.

## Problems & gotchas

### `<nul set /p` strips leading spaces — numbers jammed

The original no-newline console path used `<nul set /p "=text"`, which
**strips leading whitespace from its prompt**. That silently destroyed the
sign-space convention: every separator-emitted number lost its leading
space, so `PRINT 1;2;3` printed `"12 3"` instead of `" 1  2  3"` — the
interior values collapsed into each other. The fix, visible in `PSEMI` and
`PTAB`, is to route numbers through `str decodePrint` exactly like strings
(decode-hex via `certutil` then `type`, where leading spaces survive), and
to give mid-list numbers a leading sign-space (or `-`) *plus* a trailing
space so consecutive values can never abut:

```bat
@REM Numeric: `_txt` is ` <digits>` (leading sign-space) or `-<digits>`.  The
@REM console no-newline print must NOT use `set /p`, which strips the leading
@REM space — that jams consecutive numbers (PRINT 1;2;3 -> "12 3" not " 1 2 3").
@REM Route through decodePrint (leading spaces survive), like the string path.
if defined _txt (
  if defined _print_path (
    call %GWSRC%\exec\_pemit "!_txt!" NONL
  ) else (
    call %GWSRC%\str\str encode "!_txt!" _nhex
    call %GWSRC%\str\str decodePrint !_nhex! NONL
  )
)
```

The `decodePrint` comment in `src/str/str.bat` documents the full menagerie
of why neither `echo`, `echo(`, nor `<nul set /p` is usable: `echo` mangles
`= < > & |`, `set /p` refuses prompts that start with `=` and strips
leading whitespace, and a cross-scope `set` eats `!` under delayed
expansion. `certutil -decodehex` then `type` is the only mechanism that
handles every printable byte. Three regression tests had baked in the old
**jammed** output and were corrected to the GW-faithful spacing — they now
assert `" 1  2  3"`, `"-1  2 -3"`, and the zone-padded `" 1             2"`
(see `print.semicolon.numbers.separate`, `print.semicolon.negative.signs`,
`print.tab.padding`).

### PRINT USING rendered bare variables as 0

`PRINT_USING.bat` originally popped its value list *without resolving* each
entry, so a bare variable arrived as its raw `VAR_` token, which
`_renderNum`/`_strBody` treated as `0` (or empty). Literals and
pre-evaluated expressions happened to work, so **no test caught it** — it
only surfaced through file-channel usage. The fix is a `_resolve` on every
popped value:

```bat
@REM Resolve each value: a bare variable reaches here as its VAR_ token, which
@REM _renderNum/_strBody would otherwise treat as 0 (or empty).  Literals and
@REM pre-evaluated expressions pass through _resolve unchanged.
call %GWSRC%\exec\_resolve !_v! _v
```

The regression test `fileops.printusing.variable.value` now pins
`PRINT #1,USING "###";X` with `X=42` to `" 42"` precisely so this can't
regress.

### Format-walking must use delayed expansion, not `%var%`

The renderer consumes pairs off the **front** of `_fhex` so every read is a
constant `!_fhex:~0,2!`. Doing this with `%var%` substring offsets would
expand at parse time and break inside the `if`-blocks — the same
parenthesised-block `%var%` hazard called out in
[07 — Built-in functions & the RTL handler pattern](07-builtin-handlers.md).
The integer/fraction split in
`:_renderNum` also avoids `for /f`, which would skip an empty leading token
for values below 1 like `.09999999`.

### Helper-label var collisions

Several handlers define a local `:_len` (and `PRINT_USING` adds `:_t2h`,
`:_incDec`, `:_commas`, `:_strFit`). These wrap their own
`setlocal`/`endlocal` so they don't clobber the caller's `_n`, `_v`, etc. —
the project has been bitten before by helper labels *without* `setlocal`
reusing caller variable names.

## How it is tested

- `src/exec/exec.test.bat` — the "PRINT formatting" block (`print.tab.padding`,
  `print.semicolon.numbers.separate`, `print.semicolon.negative.signs`,
  `print.tab.function`, `print.spc.function`) covers the sign-space,
  zone-padding, jamming, `TAB(`/`SPC(` cases. Its header comment notes the
  `set /p`-strips-leading-space caveat for the inline path.
- `src/exec/strings.test.bat` — `print.using` exercises numeric fields
  (`"###";42` → `" 42"`), format reuse (`"##";5;10` → `" 510"`), string
  fields (`"\  \";"HELLO"` → `"HELL"`), and literal text around a field
  (`"X#Y";7` → `"X7Y"`).
- `src/rtl/fileops.test.bat` — `fileops.printusing.variable.value`,
  `fileops.printusing.string.variable`, `fileops.printusing.after.tab.item`,
  and the `WRITE #` CSV cases (`fileops.write.file.csv` asserting the output
  contains `,5,`) cover the resolve fix, the after-item USING, and `WRITE`
  quoting end-to-end through the file sink.
- `src/parser/parse.test.bat` — confirms `PRINT USING` and `LPRINT USING`
  emit the expected `… PU_MARK … PRINT_USING [PU_NL]` postfix shape.
