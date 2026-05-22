@echo off
@REM FN_FIX: truncate toward zero.  For int already an int.  For sng/dbl,
@REM toInt truncates toward zero per existing num facade contract.
@REM Result type matches input (int stays int; sng stays sng; dbl stays dbl,
@REM with the fractional part removed).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
if "!_t!"=="i" (set "__=!_a!" & goto :_fix_push)
if "!_t!"=="s" (
  call %GWSRC%\num\sng toInt !_a!
  call %GWSRC%\num\sng fromInt !__!
  goto :_fix_push
)
if "!_t!"=="d" (
  call %GWSRC%\num\dbl toInt !_a!
  call %GWSRC%\num\dbl fromInt !__!
  goto :_fix_push
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 13

:_fix_push
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
