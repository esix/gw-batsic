# Error trapping: ON ERROR, RESUME, ERR/ERL, and flow codes

GW-BASIC lets a program catch its own runtime errors: `ON ERROR GOTO 1000`
arms a handler, and when any later statement fails — division by zero, a
missing file, a bad subscript — control jumps to line `1000` instead of
halting, with `ERR` holding the error code and `ERL` the line that failed.
The handler inspects them, fixes things up, and ends with `RESUME` to
re-run the failed statement, `RESUME NEXT` to skip it, or `RESUME <line>`
to continue elsewhere. A program can also *raise* a code itself with
`ERROR n` — handy for signalling application errors and for testing a
handler.

All of this rides on top of one mechanism the executor already needs for
ordinary control flow: **exit codes as signals**. The run loop reads the
`errorlevel` of each statement. A handful of those codes — 97, 98, 99 —
are reserved as *flow codes*: they mean "halt gracefully", not "an error
happened". Everything else non-zero is a genuine GW-BASIC error code that
the trap machinery may catch. This page covers both halves: the trapping
statements and the flow-code protocol underneath them.

## Recap: the RTL calling convention

Every statement, operator and function is one file in `src/rtl/`. The
executor's `:_run_loop` (in `src/exec/exec.bat`) walks a postfix token
stream; `NUM_`/`VAR_`/`STR_` tokens are pushed onto the working stack
`_stk`, and any other token names an RTL handler that is called with the
stack variable as its only argument:

```
call %GWSRC%\rtl\!_tok!.bat _stk
set "_err=!ERRORLEVEL!"
```

The handler pops its operands off `_stk` (via `stl\vec pop`), does its
work, and either pushes a result back or sets some run-state env var. Its
`errorlevel` is the GW-BASIC error code — `0` for success. If there is no
`.bat` for a token, the executor sets `_err=73` ("Advanced Feature"). The
full convention — stack discipline and the `endlocal & set` propagation
idiom that carries results out of each handler's `setlocal` — is the
subject of [07 — Built-in functions & the RTL handler pattern](07-builtin-handlers.md). The error-trapping
handlers are ordinary RTLs that play three extra tricks: they read/write
the shared error-state vars, they exploit the exit code as a signal, and
one of them (`ERROR`) deliberately returns a *non-zero* code.

## Flow codes: 97 / 98 / 99

A statement that wants the run loop to stop — not because of an error, but
because the program said so — returns a reserved exit code. There are
three:

| Code | Meaning | Raised by |
|---|---|---|
| `97` | `SYSTEM` — leave the interpreter entirely | `SYSTEM.bat` |
| `98` | `RUN` / `CHAIN` restart — reload and/or jump | `RUN.bat`, `CHAIN.bat` |
| `99` | `END` / `STOP` graceful halt (also `LIST`, `NEW`) | `END.bat`, `STOP.bat`, `LIST.bat`, `NEW.bat` |

The line-level run loop, `:_runProg_loop`, calls `:run` for one line and
then switches on the result:

```
call :run "!_postfix!"
set "_e=!ERRORLEVEL!"
if !_e! equ 98 goto :_runProg_restart
if !_e! equ 97 (
  set "_sys_exit=1"
  set "_err_code=0"
  goto :_runProg_done
)
if !_e! neq 0 goto :_runProg_err
goto :_runProg_loop
```

So `97` sets `_sys_exit` (which `runOnce` / the REPL check to actually
leave); `98` jumps to `:_runProg_restart`, which loads `_run_file` if set,
reinitialises, and resumes; everything else non-zero falls into
`:_runProg_err`, where `99` is recognised as a clean halt:

```
:_runProg_err
  if !_e! equ 99 (set "_err_code=0" & goto :_runProg_done)
```

Because these three codes are not errors, they must never leak into `ERR`.
The `:_run_end` epilogue captures `_err_code`/`_err_line` only for codes
that are non-zero *and* none of the three flow codes:

```
:_run_end
  if !_err! neq 0 if !_err! neq 99 if !_err! neq 98 if !_err! neq 97 (
    set "_err_code=!_err!"
    set "_err_line=!_cur_line!"
  )
```

That single guard is why `STOP` halts with `Break` but leaves `ERR` at `0`
(see the `err.stop.is.not.an.error` test), and why `LIST` — which also
returns `99` to stop the program after dumping the listing — doesn't look
like a failure.

## ON ERROR GOTO: arming and disarming

`ON_ERROR.bat` is reached for `ON ERROR GOTO <line>` (grammar rule
`OnTail ::= ERROR GOTO NUM @ON_ERROR`). It pops the target line off the
stack, resolves and integer-converts it, and stashes it in
`_on_error_line`:

```
call %GWSRC%\stl\vec pop %_s% _ln
call %GWSRC%\exec\_resolve !_ln! _ln
call :_toInt !_ln! _l
...
endlocal & set "%~1=%_final%" & set "_on_error_line=%_l%" & exit /B 0
```

`ON ERROR GOTO 0` is the GW-BASIC idiom for *disarming* the handler, and
it falls out for free: `0` is a perfectly valid value to store in
`_on_error_line`, and the trap site treats both an unset var (the
`_runInit` default) and a literal `0` as "no handler":

```
if not defined _on_error_line goto :_runProg_done
if "!_on_error_line!"=="0" goto :_runProg_done
```

## The trap: error → handler jump

When a statement returns a real error code, `:_runProg_loop` routes to
`:_runProg_err`. Past the `99` check, if a handler is armed, the trap
fires:

```
if not defined _on_error_line goto :_runProg_done
if "!_on_error_line!"=="0" goto :_runProg_done
set "_gw_err=!_e!"
set "_gw_erl=!_cur_line!"
set "_next_line=!_on_error_line!"
set "_err_code=0"
goto :_runProg_loop
```

The trapped code goes into `_gw_err`, the failing line into `_gw_erl`, the
next line to execute becomes the handler line, and `_err_code` is cleared
so the run does *not* print a message or abort — the program is expected to
handle it. The loop then continues into the handler.

`ERR` and `ERL` simply read those two vars. They are dedicated builtins
(`BuiltinCall ::= ERR @FN_ERR` / `ERL @FN_ERL`), not pseudo-variables —
`FN_ERR.bat` and `FN_ERL.bat` push the current value onto the stack:

```
@REM FN_ERR.bat
set "_e=!_gw_err!"
if not defined _e set "_e=0"
call %GWSRC%\num\int fromDec !_e!
call %GWSRC%\stl\vec push %_s% !__!
```

`FN_ERL.bat` is identical but reads `_gw_erl`. Both default to `0` when
unset, so `PRINT ERR` before any error prints `0`.

## RESUME, RESUME NEXT, RESUME line

Once the handler has done its work it hands control back with one of three
`RESUME` forms. The grammar is small:

```
ResumeStmt    ::= RESUME ResumeTarget
ResumeTarget  ::= NEXT @RESUME_NEXT
ResumeTarget  ::= NUM @RESUME_LINE
ResumeTarget  ::= @RESUME
```

**Bare `RESUME`** re-runs the statement that errored. `RESUME.bat` sets
`_next_line` straight back to `_gw_erl` — the line the error came from:

```
endlocal & set "%~1=%_final%" & set "_next_line=%_gw_erl%" & exit /B 0
```

**`RESUME <line>`** continues at an explicit line. `RESUME_LINE.bat` pops,
resolves and int-converts the line number, then sets `_next_line`:

```
call %GWSRC%\stl\vec pop %_s% _ln
call %GWSRC%\exec\_resolve !_ln! _ln
call :_toInt !_ln! _l
...
endlocal & set "%~1=%_final%" & set "_next_line=%_l%" & exit /B 0
```

**`RESUME NEXT`** is the subtle one. It should continue at the statement
*after* the one that failed — but the run loop is line-based, and the
handler only knows `_gw_erl`, the failing *line* number. `RESUME_NEXT.bat`
can't compute the successor itself (it has no view of the program), so it
points `_next_line` back at the failing line and raises a flag:

```
endlocal & set "%~1=%_final%" & set "_next_line=%_gw_erl%" & set "_resume_advance=1" & exit /B 0
```

The advance happens at the top of `:_runProg_loop`, the one place that
holds the pre-parsed `_pnext_<KEY>` cache mapping each line to its natural
successor:

```
if defined _resume_advance (
  set "_resume_advance="
  set "_rpad=00000!_next_line!"
  set "_rpad=!_rpad:~-5!"
  for %%k in (!_rpad!) do set "_next_line=!_pnext_%%k!"
  if not defined _next_line goto :_runProg_done
)
```

It zero-pads `_next_line` to the 5-digit cache key, looks up
`_pnext_<KEY>` (the next line number), and if there is none — the failing
line was the last — the program ends. This is "next *statement*"
approximated as "next *line*" (see "Problems & gotchas").

## ERROR n: raising a code

`ERROR n` lets a program raise an arbitrary error code, which then traps
to the armed handler exactly like a real failure. `ERROR.bat` pops and
int-converts the operand, and — uniquely among these handlers —
*returns it as the exit code*:

```
call %GWSRC%\stl\vec pop %_s% _c
call %GWSRC%\exec\_resolve !_c! _c
call :_toInt !_c! _cd
...
endlocal & set "%~1=%_final%" & exit /B %_cd%
```

That `exit /B %_cd%` is the whole trick: returning a non-zero code makes
the engine treat the statement as if it had failed with that code. An
armed handler then sees it in `ERR`; with no handler armed it halts with
that code's canonical message. It also doubles as a test tool — a program
can raise a specific code to drive a handler down a known path. The one
caveat: `ERROR 99` (or 97/98) collides with a flow code and halts cleanly
rather than trapping — those three values are spoken for.

## Threading the state through `setlocal`

Every line runs inside its own `setlocal EnableDelayedExpansion` in
`:run`, so each line's error-state changes would normally evaporate at the
matching `endlocal`. The `:_run_end` epilogue carries the whole control-
flow-and-error bundle back to the caller explicitly, alongside the gosub
and for-loop stacks:

```
endlocal ^
  & set "_next_line=%_next_line%" ^
  ...
  & set "_on_error_line=%_on_error_line%" ^
  & set "_gw_err=%_gw_err%" ^
  & set "_gw_erl=%_gw_erl%" ^
  & set "_resume_advance=%_resume_advance%" ^
  ...
  & exit /B %_err%
```

The mirror image is `:_runInit`, which (re)initialises all of it at
program start and on every `RUN` restart:

```
set "_on_error_line="
set "_gw_err=0"
set "_gw_erl=0"
set "_resume_advance="
```

`runOnce` and the REPL's `:_start` set the same defaults before the first
run. Miss one and the symptoms are nasty: a stale `_on_error_line` would
trap errors in a fresh program that never armed a handler; a stale
`_resume_advance` would silently skip the first line of the next run. The
state is small but every entry path has to agree on it.

## Problems & gotchas

**`RESUME NEXT` is line-granular, not statement-granular.** GW-BASIC
resumes at the next *statement*, which on a packed line (`A=1 : B=2 : C=3`)
means the next colon-separated piece. Our run loop only addresses whole
lines, so the advance via `_pnext_<KEY>` moves to the next *line*. For the
common one-statement-per-line vintage code this is indistinguishable; for a
packed line it skips the rest of the line. Getting even the line-level
version right was the fiddly part: the failing-line successor only exists
in the `_pnext_` cache, which lives in `:_runProg_loop`'s scope — so the
advance had to be deferred there via the `_resume_advance` flag rather than
computed in `RESUME_NEXT.bat`.

**Bare `RESUME` needed an epsilon grammar rule.** `RESUME` with no
argument has nothing after it to drive an `@action` marker, but the parser
needs *some* production for `ResumeTarget` to reduce to so the `@RESUME`
handler emits. The fix is the epsilon-with-action pattern,
`ResumeTarget ::= @RESUME` — an empty right-hand side whose only content is
the action marker. The LL(1) table routes the `$`, `COLON` and `ELSE`
lookaheads (everything that legitimately follows a bare `RESUME`) to that
rule, while `NEXT` and `NUM` select the other two forms.

**Flow codes are exit codes, so the "is it an error?" test is a list of
exclusions.** There is no separate channel: 99 looks like errorlevel 99
and a hypothetical real error 99 would be ambiguous. The engine resolves
this by reserving 97/98/99 and excluding them at every place an error
might be recorded — `:_run_end`'s capture guard and `:_runProg_err`'s
`equ 99` check. A new statement that wants to signal a non-error halt has
to pick from these three; it can't invent a fourth without teaching both
sites about it.

**Disarming reuses the "0 means off" convention.** There is no separate
"armed" boolean. `ON ERROR GOTO 0` writes `0` into `_on_error_line`, and
both an unset var and a literal `0` read as "no handler" at the trap site.
That keeps `ON_ERROR.bat` trivial (no disarm special case) at the cost of
one extra string compare in the hot path.

**ERR/ERL are builtins, not pseudo-vars.** A leftover comment in the REPL
init (`@REM Error state: ERR / ERL accessible via _resolve's pseudo-vars`)
suggests they resolve like variables; they do not. They are real
`BuiltinCall` productions backed by `FN_ERR.bat`/`FN_ERL.bat`, which read
`_gw_err`/`_gw_erl` directly — and a variable *named* `ERR` is impossible
anyway, since `ERR`/`ERL` are reserved terminals in the grammar.

## How it is tested

`src/exec/errors.test.bat` is the regression suite for the surrounding
error machinery. Each case stores a program with `_addLine`, runs it via
`exec runProgram`, and checks `_err_code`/`_err_line` against the expected
GW-BASIC code and failing line — e.g. `10 PRINT 1 / 0` → `:_progErr 11 10`
(Division by zero, line 10), and the flow-code cases `10 END` / `10 STOP` →
`:_progErr 0 0`, proving the graceful-halt codes never surface as errors.
`err.line.reported.is.failing.line` confirms `ERL` points at the failing
statement, and `err.unknown.rtl.is.advanced.feature` pins the
unimplemented-token path to code `73`. Two end-to-end cases
(`:_progStdoutEndsWith`) capture stdout to verify the `"<Message> in
<line>"` format from `:_printErr` / `src/gwerror.bat`.
