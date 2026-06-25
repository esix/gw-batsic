# Built-in functions & the RTL handler pattern

Every statement, operator, and built-in function in this interpreter is one
small `.bat` file under `src/rtl/`. There is no giant `switch` in the
executor and no per-function special-casing in the run loop. The executor
walks a postfix token stream, and for any token that isn't a literal value it
just calls `src/rtl/<TOKEN>.bat`. That file pops its operands off a shared
stack, does its work, and pushes its result back. `PRINT` is `PEND.bat`,
`ABS()` is `FN_ABS.bat`, `+` is `ADD.bat`, `MID$(...)=` is `MID_SET.bat`,
the assignment `=` is `ASSIGN.bat`. ~196 of these handlers make up the whole
runtime semantics of the language.

This uniformity is the point. Adding a built-in means writing one file and
(usually) one grammar rule that emits its `@action` marker — nothing in the
executor changes. The cost is that all the awkwardness of `cmd.exe` (the
stack lives in an env var, values are tagged hex strings, and `setlocal`
walls each handler off from per-line state) shows up in *every* handler in
the same recurring shapes. This doc is about those shapes: the calling
convention, the tagged-value tokens the stack carries, how the run loop in
`exec.bat` drives it all, and the genuinely nasty parts.

## The shared stack and tagged values

The executor keeps a single operand stack in the env var `_stk`, managed
through the vector helper `src/stl/vec.bat`: a vector is just a
space-separated string in a named env var, with `push` / `pop` / `front` /
`size` operations that take the *variable name* (not its value) as their
first argument. The whole stack machine is `vec push _stk …` on the way in
and `vec pop _stk …` on the way out.

Values on the stack are **tagged strings** so a handler can tell types apart
by looking at the first character (or first four). This is the same on-stack
form the numerics layer ([02 — Numerics](02-numerics.md)) and the lexer
([04 — Lexer](04-lexer.md)) produce:

| Tag | Meaning | Width | Example |
|---|---|---|---|
| `i<hex>` | signed 16-bit integer | 4 hex chars | `i000A` is `10`, `iFFFF` is `-1` |
| `s<hex>` | MBF single | 8 hex chars | `s83200000` is `10.0` |
| `d<hex>` | MBF double | 16 hex chars | `d8648000000000000` is `100.0` |
| `STR_<hex>` | string, body in hex pairs | variable | `STR_48454C4C4F` is `"HELLO"`, `STR_` is `""` |
| `VAR_…_<NAME>` | an *unresolved* variable reference | — | `VAR_UNK_A`, `VAR_INT_COUNT`, `VAR_STR_S` |
| `AREF:<NAME>:<idx>` | an array-element L-value | — | `AREF:VAR_SNG_A:3` |

The numeric tags are the same hex strings the `int` / `sng` / `dbl` facades
in `src/num/` consume and produce, so a handler that needs to add two numbers
just hands the tagged values straight to `num\<t> add`. No unpacking happens
at the handler level.

## The `:run` stack machine

`exec.bat`'s `:run` label is the engine. It takes one line's postfix stream
and loops token by token in `:_run_loop`:

```bat
:_run_loop
  for /f "tokens=1*" %%a in ("!_postfix!") do (set "_tok=%%a" & set "_postfix=%%b")
  set "_tp=!_tok:~0,4!"
  if "!_tp!"=="NUM_" (call %GWSRC%\stl\vec push _stk !_tok:~4! & goto :_run_loop)
  if "!_tp!"=="VAR_" (call %GWSRC%\stl\vec push _stk !_tok!   & goto :_run_loop)
  if "!_tp!"=="STR_" (call %GWSRC%\stl\vec push _stk !_tok!   & goto :_run_loop)
  ...
  if exist "%GWSRC%\rtl\!_tok!.bat" (
    call %GWSRC%\rtl\!_tok!.bat _stk
    set "_err=!ERRORLEVEL!"
    goto :_run_loop
  )
  echo RTL: unknown action !_tok! 1>&2
  set "_err=73"
```

The classification is purely lexical: `NUM_<tagged>` strips the prefix and
pushes the bare tagged value (`NUM_i000A` → `i000A`); `VAR_<…>` pushes the
token **raw and unresolved** (see below); `STR_<hex>` pushes as-is; `REM_<hex>`
is ignored. A handful of control-flow markers (`IF`, `ELSE`, `ENDIF`,
`IF_GOTO`, `FOR`, `NEXT`, `DEFFN_CAP`) are handled inline because they need to
skip or re-run parts of the token stream, which a plain "call a handler"
can't do. **Anything else** is an action: if `src/rtl/<TOK>.bat` exists,
`:run` calls it with the stack-variable name `_stk` and captures its exit
code into `_err`; if the file doesn't exist, the action is unimplemented and
`:run` raises code **73** ("Advanced Feature").

Every handler is `call`ed with exactly one argument — the *name* `_stk` —
and is expected to mutate that variable in place. The handler's exit code is
its GW-BASIC error code: `0` for success, `13` for Type mismatch, `5` for
Illegal function call, `6` for Overflow, etc. `:_run_loop` stops as soon as
`_err` is non-zero.

There is a second, smaller copy of this loop at `:evalExpr`. It runs a
**pure-expression** postfix stream (values plus operator/function actions, no
control flow) on a private stack `_xstk` and returns the single result. It
exists so `CALL_FN.bat` can evaluate a stored `DEF FN` body without going
through the line-based program loop.

## VAR_ is pushed raw, resolved lazily

The run loop deliberately does **not** look up variable values. A `VAR_`
token is pushed onto the stack verbatim, and it stays a `VAR_…_NAME` token
until some handler actually needs its value. Resolution is the handler's job,
via `src/exec/_resolve.bat`:

```bat
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
```

`_resolve value retVar` is a pass-through for anything that isn't a `VAR_`
token, and a variable read for anything that is. That's why nearly every
handler's first few lines are "pop, then resolve" — `FN_ABS`, `ADD`,
`FN_RIGHT`, `POW`, `MID_SET` and the rest all open the same way.

Lazy resolution buys two things. First, assignment targets stay symbolic:
`ASSIGN.bat` pops the *value* (and resolves it) but pops the *variable*
unresolved, so it knows where to store. Second, it's the single choke point
for the **FIELD live-window** hook. `_resolve` checks, only if
`%GWTEMP%\fields.dat` exists, whether the variable name is a registered
random-file field; if so it returns the current slice of that handle's record
buffer instead of an ordinary stored value:

```bat
if not "!_v:~0,4!"=="VAR_" goto :_res_pass
if not exist "%GWTEMP%\fields.dat" goto :_res_var
call %GWSRC%\exec\_files fget !_v! _ff
if errorlevel 1 goto :_res_var
call %GWSRC%\exec\_files bufget !_ffn! _fbuf
set /a "_p=_ffoff*2"
set /a "_len=_ffwidth*2"
set "_r=STR_!_fbuf:~%_p%,%_len%!"
```

`_resolve` runs on *every* variable read, so the `if exist` on the first line
is the hot-path guard: non-FIELD programs pay one file-existence check and
fall straight through to `_vars get`.

The actual storage is in `src/exec/_vars.bat` (`vars.dat`, one
`VARNAME=taggedvalue` per line). `_vars` also owns the type rules: a
`VAR_UNK_<NAME>` token has no suffix, so `typeof` consults the 26-character
`_deftypes` table (one slot per letter A–Z, default all `s`) to decide
whether the name is `i` / `s` / `d` / `t`, and `get`/`set` canonicalise
`VAR_UNK_A` into `VAR_INT_A` / … / `VAR_STR_A` accordingly. An unset variable
reads back as the type's zero (`i0000`, `s00000000`, `d…0`, or `STR_`).

## `@action` markers come from the grammar

The token names the executor dispatches on are emitted by the parser as
**postfix action markers**. In `src/parser/bnf.txt` every semantic action is
written `@NAME`, and the parser appends `NAME` to the postfix stream at the
point the rule reduces. So `:run` calling `rtl/PEND.bat` is the runtime
half of the grammar rule that emitted `@PEND`. A few representative rules:

```
AssignTail    ::= EQ Expr @ASSIGN
ForStmt       ::= FOR VAR EQ Expr TO Expr StepClause @FOR
ReadStmt      ::= READ @READ_MARK VarList @READ
MidStmt       ::= MID$ OPAR LValue COMA Expr MidSetLen CPAR EQ Expr @MID_SET
PrintBody     ::= @PEND
LVIndex       ::= @ARR_START OPAR ExprList CPAR @AREF
```

Two grammar idioms show up repeatedly and explain a lot of the handlers:

- **`_MARK` sentinels.** Variadic constructs (`READ`, `INPUT`,
  `WRITE`, `LOCATE`, `COLOR`, `PRINT USING`, `CLOSE`, `FIELD`, `CLEAR`) push
  a sentinel token before their value list so the handler knows where the
  list starts when it pops the stack. `@PU_MARK` is `PU_MARK.bat`, which is
  the entire file:

  ```bat
  call %GWSRC%\stl\vec push %~1 PU_MARK
  exit /B 0
  ```

  and the consuming handler pops values until it hits that sentinel.

  Plain `PRINT` is the exception: it is item-streaming, not list-popping, so
  it needs no start-of-list sentinel. Each `PrintItem` is emitted to a
  per-item handler (`@PEND` / `@PSEMI` / `@PTAB` / `@PZONE`) that pops a
  single value as it goes. (`PRINT USING` is the variant that *does* use a
  sentinel — `@PU_MARK` above.)

- **L-value packing.** A scalar assignment target rides the stack as a plain
  `VAR_` token, but an array element can't — its subscripts are themselves
  expressions that must be evaluated first. `@AREF` (in `AREF.bat`) pops the
  `ARR_MRK` sentinel, the evaluated subscripts, and the array name, and packs
  them into one `AREF:VAR_…:<idx>` token so the target stays a single stack
  item that `@READ` / `@INPUT` / `@ASSIGN_ARR` can decode and store into.

## How a handler is built — three examples

**A unary numeric function.** `FN_ABS.bat` pops one operand, resolves it,
branches on the type tag, and pushes the result:

```bat
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
if "!_t!"=="i" ( ... call %GWSRC%\num\int neg !_a! ... )
if "!_t!"=="s" (call %GWSRC%\num\sng abs !_a! & goto :_abs_push)
if "!_t!"=="d" (call %GWSRC%\num\dbl abs !_a! & goto :_abs_push)
endlocal & set "%~1=%_final%" & exit /B 13
```

If the operand has no recognised numeric tag it falls through to the last
line and returns **13** (Type mismatch). The work is delegated entirely to
the `num` facades; the handler is just stack plumbing plus a type switch.

**A binary operator.** `ADD.bat` pops `_b` then `_a` — note the order: the
**second** operand is on top of the stack, so it's popped first. It checks
for the string-concatenation case first (two `STR_` operands concatenate the
hex bodies directly, `STR_!_a:~4!!_b:~4!`; a string/number mix returns 13),
and for numbers it calls `src/exec/_promote.bat` to lift a mixed pair to a
common type (`__t`, `__a`, `__b`) before dispatching:

```bat
call %GWSRC%\exec\_promote !_a! !_b!
call %GWSRC%\num\!_mod! add !__a! !__b!
call %GWSRC%\stl\vec push %_s% !__!
```

**A statement that writes back.** `ASSIGN.bat` is the `LET` engine. It pops
the value (resolving it) and the target (left *unresolved*, so it knows where
to store), converts the value to the target's declared type — `sng`/`dbl` →
int truncates via `num\… toInt`, int → float promotes — then runs
`vars set !_var! !_val!`. Just before storing it does
`if exist "%GWTEMP%\fields.dat" call %GWSRC%\exec\_files fdel !_var!`: that's
the FIELD detach, where a plain assignment to a variable that was named in a
`FIELD` statement unbinds it from the record buffer, matching GW-BASIC
semantics. `MID_SET.bat` (the `MID$(t$,n)=v$` statement) is the most
arithmetic of the L-value handlers: it pops four operands (value, len, start,
target), resolves each, and splices the value's hex bytes into the target's
hex in place with `:~` slicing, leaving the target's length unchanged.

## Problems & gotchas

### Returning a mutated stack out of `setlocal`

Every handler runs `setlocal EnableDelayedExpansion` so it can use `!…!`
delayed expansion. But `_stk` lives in the *caller's* scope, and `endlocal`
would throw away any change made inside. The idiom that threads the new stack
value back out is everywhere:

```bat
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
```

`_s` holds the stack-variable *name* (`_stk`), so `!%_s%!` reads the current
stack contents; `%_final%` is then substituted **at parse time**, before
`endlocal` runs, so the inner value survives as a literal and the post-`endlocal`
`set` lands it back in the caller's `_stk`. This is the same
`endlocal & set "__=%result%"` trick the numerics layer uses
([02 — Numerics](02-numerics.md), "Endlocal propagation") — here it carries
the whole stack instead of a single result.

### The parse-time `%var%` trap (the one that keeps biting)

`%_final%` being expanded at *parse* time is exactly what you want on the
flat `endlocal &` line. It is exactly what you **don't** want inside a
parenthesised block. `cmd.exe` parses an entire `( … )` block in one pass and
substitutes every `%var%` in it *before executing any line in the block*. So
this, inside an `if (…)`, captures a **stale** `_final`:

```bat
if !_take! GEQ !_len! (
  call %GWSRC%\stl\vec push %_s% STR_!_h!
  set "_final=%_final%"      @REM ← BROKEN: %_final% already expanded
)
```

The push updates `_stk`, but `%_final%` was already substituted with whatever
`_final` held when the block was *entered*, so the result is lost. The fix is
to `goto` a label at the top level and do the propagation there, after the
block, where `set "_final=!%_s%!"` reads the freshly-updated stack. The
comment in `FN_RIGHT.bat`'s whole-string branch spells it out verbatim:

```bat
if !_take! GEQ !_len! (
  @REM Whole string. Propagation happens after the block: %_final% inside
  @REM parens would expand at parse time, before set "_final=..." runs.
  call %GWSRC%\stl\vec push %_s% STR_!_h!
  goto :_rl_ret
)
```

The same bug hit the power-of-zero
path in `POW.bat` (whose `:_pow_zero` branch is split out to the top level
specifically "so `%_final%` gets parse-time substituted with the value set
right above the endlocal-line") and `FN_RND.bat`, plus roughly two dozen
error-return paths. The rule for a handler: never read `%_final%` inside a
`( … )` block — either `goto` a label at the top level first, or build the
return value with delayed `!…!` expansion.

### Per-line state lives behind `setlocal`

`:run` itself opens `setlocal EnableDelayedExpansion`. That wall is great for
isolation but it means **nothing a handler sets survives to the next program
line** unless it is hand-carried across the `endlocal` at `:_run_end`:

```bat
:_run_end
  ...
  endlocal ^
    & set "_next_line=%_next_line%" ^
    & set "_print_col=%_print_col%" ^
    & set "_data_ptr=%_data_ptr%" ^
    & set "_deftypes=%_deftypes%" ^
    & set "_option_base=%_option_base%" ^
    & set "_on_error_line=%_on_error_line%" ^
    & ... ^
    & exit /B %_err%
```

Every cross-line piece of runtime state has to appear in that propagation
list: the `DEF`-type table (`_deftypes`), `ON ERROR` state
(`_on_error_line`, `_gw_err`, `_gw_erl`, `_resume_advance`), `OPTION BASE`
(`_option_base`), the `CHAIN` flags (`_chain_keep`, `_chain_merge`,
`_chain_del`), `RUN` retargeting (`_run_file`, `_run_line`), the PRINT column
(`_print_col`), the FOR/GOSUB/WHILE control stacks, and the READ/DATA pointer
(`_data_ptr`). Forget to add a new var here and it silently resets to empty at
the start of every line — the symptom is "my state works within a line but
evaporates between lines." (Variable and array storage dodge this entirely
because they live in files under `%GWTEMP%`, not env vars, so `DEFINT N` only
needs `_deftypes` carried, not the variables themselves.)

### Exit code is a contract, and 73 is the default

A handler's exit code *is* the GW-BASIC error number, and `:run` halts the
line on the first non-zero. Codes 99 / 98 / 97 are not errors — they're the
flow-control signals for END/STOP, RUN-restart, and SYSTEM, and `:_run_end`
explicitly skips recording `ERR`/`ERL` for them. If a token has no matching
`rtl/<TOK>.bat` file, `:run` falls through to code **73** — which is how an
unimplemented or graphics-only statement surfaces as "Advanced Feature"
rather than crashing the interpreter.

## How it is tested

Handlers are tested at the postfix level, not through the lexer/parser, so a
test can name the exact `@action` it's exercising without fighting `cmd.exe`'s
argument quoting (a `"` in a source line gets mangled by `call`'s arg parser
before it ever reaches the executor). The string- and expression-level RTL
suites live in `src/exec/strings.test.bat` and `src/exec/exec.test.bat`; each
case hands a literal postfix stream to a `:_rexec` helper and asserts the
printed output:

```bat
call %test% "str.concat"
  call :_rexec "STR_4142 STR_43 ADD PEND" "ABC"

call %test% "str.fn.len"
  call :_rexec "STR_48454C4C4F FN_LEN PEND" " 5"
```

`STR_4142 STR_43 ADD PEND` is "AB", "C", then the `ADD` and `PEND` handlers —
exactly the token stream `:run` would receive for `PRINT "AB"+"C"`, with the
leading-space sign convention visible in the expected `" 5"`. The
numerics-facing handlers lean on the `src/num/*.test.bat` suites for the
arithmetic itself, and file/array handlers on `src/exec/_arrays.test.bat`,
`src/exec/arrays.test.bat`, `src/exec/errors.test.bat`, and
`src/rtl/fileops.test.bat`. Run everything with `test.bat` at the repo root
(or `test.bat exec` to scope it to the executor and its handlers).
