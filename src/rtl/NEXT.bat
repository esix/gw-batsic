@echo off
@REM NEXT: continue or end a FOR loop.
@REM
@REM Stack at entry: optionally contains a VAR_ token (from "NEXT I" form).
@REM   We pop it if present but ignore the name — always operate on the
@REM   innermost FOR.  Multi-variable matching (NEXT I when inner J is open)
@REM   isn't supported yet.
@REM
@REM For-stack at entry: peek top → (var, limit, step, body-line)
@REM
@REM Algorithm:
@REM   1. cur = var's current value
@REM   2. new = cur + step  (with type promotion)
@REM   3. var = new
@REM   4. if step > 0: done = (new > limit)
@REM      if step < 0: done = (new < limit)
@REM   5. if done: pop the for-stack entry; fall through
@REM      else:    set _next_line = body-line  (jump back)
@REM
@REM Errors: 1 NEXT without FOR  (empty for-stack)

setlocal EnableDelayedExpansion
set "_s=%~1"

@REM If a VAR_ token was pushed (NEXT I form), discard it.
call %GWSRC%\stl\vec back %_s% _tk
if not "!_tk!"=="" if "!_tk:~0,4!"=="VAR_" call %GWSRC%\stl\vec pop %_s% _tk

@REM Peek the innermost FOR.
call %GWSRC%\stl\vec back _for_vars   _var
if not defined _var (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 1
)
call %GWSRC%\stl\vec back _for_limits _limit
call %GWSRC%\stl\vec back _for_steps  _step
call %GWSRC%\stl\vec back _for_lines  _line

@REM Read current var value, add step, store back.
call %GWSRC%\exec\_vars get !_var! _cur
call %GWSRC%\exec\_promote !_cur! !_step!
set "_mod="
if "!__t!"=="i" set "_mod=int"
if "!__t!"=="s" set "_mod=sng"
if "!__t!"=="d" set "_mod=dbl"
call %GWSRC%\num\!_mod! add !__a! !__b!
set "_new=!__!"
call %GWSRC%\exec\_vars set !_var! !_new!

@REM Determine step sign (positive or negative) for the termination test.
@REM Compare step against zero in its own type.
call :_stepSign !_step! _sign

@REM Compare new value with limit.
call %GWSRC%\exec\_promote !_new! !_limit!
set "_mod2="
if "!__t!"=="i" set "_mod2=int"
if "!__t!"=="s" set "_mod2=sng"
if "!__t!"=="d" set "_mod2=dbl"
call %GWSRC%\num\!_mod2! cmp !__a! !__b!
set "_c=!__!"

@REM _c is "0" / "1" / "2" — "1" means new > limit, "2" means new < limit.
set "_done=0"
if "!_sign!"=="+" if "!_c!"=="1" set "_done=1"
if "!_sign!"=="-" if "!_c!"=="2" set "_done=1"
@REM Step == 0 would loop forever; treat as "done" to be safe.
if "!_sign!"=="0" set "_done=1"

if "!_done!"=="1" goto :_next_done

@REM Continue: loop back to the line right after the FOR statement.  The
@REM for-stacks are unchanged here, so the %var% propagation is correct.
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" ^
  & set "_next_line=%_line%" ^
  & set "_for_vars=%_for_vars%" ^
  & set "_for_limits=%_for_limits%" ^
  & set "_for_steps=%_for_steps%" ^
  & set "_for_lines=%_for_lines%" ^
  & exit /B 0

:_next_done
@REM Loop ended: pop the four for-stacks, THEN propagate the post-pop values.
@REM Popping inside an if-(...) block and propagating %_for_vars% in the same
@REM block expands it at PARSE time -> the pops get silently undone, leaking
@REM the for-stack frame (breaks NEXT-without-FOR and single-line FOR..NEXT).
call %GWSRC%\stl\vec pop _for_vars   _tmp
call %GWSRC%\stl\vec pop _for_limits _tmp
call %GWSRC%\stl\vec pop _for_steps  _tmp
call %GWSRC%\stl\vec pop _for_lines  _tmp
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" ^
  & set "_for_vars=%_for_vars%" ^
  & set "_for_limits=%_for_limits%" ^
  & set "_for_steps=%_for_steps%" ^
  & set "_for_lines=%_for_lines%" ^
  & exit /B 0


@REM _stepSign VALUE retVar  → "+" / "-" / "0"
:_stepSign
  setlocal EnableDelayedExpansion
  set "_v=%~1"
  set "_t=!_v:~0,1!"
  set "_r=+"
  if "!_t!"=="i" (
    set /a "_iv=0x!_v:~1!"
    if !_iv! GTR 32767 set "_r=-"
    if "!_v:~1!"=="0000" set "_r=0"
  )
  if "!_t!"=="s" (
    @REM MBF single: exp byte is first.  Exp=0 means zero. Sign bit is high
    @REM bit of the high mantissa byte (_v:~3,1 nibble).
    if "!_v:~1,2!"=="00" (
      set "_r=0"
    ) else (
      set "_d=!_v:~3,1!"
      if "!_d!"=="8" set "_r=-"
      if "!_d!"=="9" set "_r=-"
      if "!_d!"=="A" set "_r=-"
      if "!_d!"=="B" set "_r=-"
      if "!_d!"=="C" set "_r=-"
      if "!_d!"=="D" set "_r=-"
      if "!_d!"=="E" set "_r=-"
      if "!_d!"=="F" set "_r=-"
    )
  )
  if "!_t!"=="d" (
    if "!_v:~1,2!"=="00" (
      set "_r=0"
    ) else (
      set "_d=!_v:~3,1!"
      if "!_d!"=="8" set "_r=-"
      if "!_d!"=="9" set "_r=-"
      if "!_d!"=="A" set "_r=-"
      if "!_d!"=="B" set "_r=-"
      if "!_d!"=="C" set "_r=-"
      if "!_d!"=="D" set "_r=-"
      if "!_d!"=="E" set "_r=-"
      if "!_d!"=="F" set "_r=-"
    )
  )
  endlocal & set "%~2=%_r%" & exit /B 0
