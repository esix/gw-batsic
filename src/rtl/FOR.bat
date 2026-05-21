@echo off
@REM FOR: initialize a counted loop.
@REM
@REM Stack at entry (top last): ... VAR init limit step
@REM   - VAR is the loop variable token (e.g. VAR_UNK_I)
@REM   - init, limit, step are tagged numeric values
@REM
@REM Side effects:
@REM   - Assigns init to VAR (via _vars set, which converts type as needed)
@REM   - Pushes (var, limit, step, body-line) onto the four parallel for-stacks
@REM     (_for_vars / _for_limits / _for_steps / _for_lines)
@REM   - body-line = _next_line at entry, i.e. the line after this FOR statement
@REM
@REM Errors: 26 FOR without NEXT — not detected here; surfaces at end-of-program.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _step
call %GWSRC%\stl\vec pop %_s% _limit
call %GWSRC%\stl\vec pop %_s% _init
call %GWSRC%\stl\vec pop %_s% _var
call %GWSRC%\exec\_resolve !_init! _init
call %GWSRC%\exec\_resolve !_limit! _limit
call %GWSRC%\exec\_resolve !_step! _step
call %GWSRC%\exec\_vars set !_var! !_init!
@REM Push onto the four parallel for-stacks.
call %GWSRC%\stl\vec push _for_vars   !_var!
call %GWSRC%\stl\vec push _for_limits !_limit!
call %GWSRC%\stl\vec push _for_steps  !_step!
call %GWSRC%\stl\vec push _for_lines  !_next_line!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" ^
  & set "_for_vars=%_for_vars%" ^
  & set "_for_limits=%_for_limits%" ^
  & set "_for_steps=%_for_steps%" ^
  & set "_for_lines=%_for_lines%" ^
  & exit /B 0
