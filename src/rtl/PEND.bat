@echo off
@REM PEND: pop value, print with newline.  Resets _print_col so the next
@REM PRINT starts at column 0.
@REM
@REM GW-BASIC convention: numeric output gets a leading space placeholder for
@REM the sign — " 42" for positive, "-42" for negative (sign is in place).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
@REM Bare `PRINT` (empty stack) just emits a blank line.
if not defined _a goto :_pend_blank
call %GWSRC%\exec\_resolve !_a! _a
@REM Check STR_ before single-char tag prefixes (batch `if` is case-insensitive).
if "!_a:~0,4!"=="STR_" (
  if "!_a!"=="STR_" (
    echo(
  ) else (
    @REM Decode + print in one shot — a cross-scope `set` would eat `!`
    @REM and `echo(` would mangle `=`, `<`, `>`, `&`, `|`.
    call %GWSRC%\str\str decodePrint !_a:~4!
  )
) else (
  set "_tp=!_a:~0,1!"
  set "_d="
  if "!_tp!"=="i" (call %GWSRC%\num\int toDec !_a! & set "_d=!__!")
  if "!_tp!"=="s" (call %GWSRC%\num\sng toDec !_a! & set "_d=!__!")
  if "!_tp!"=="d" (call %GWSRC%\num\dbl toDec !_a! & set "_d=!__!")
  if defined _d (
    if "!_d:~0,1!"=="-" (echo(!_d!) else (echo  !_d!)
  ) else (
    echo(!_a!
  )
)
goto :_pend_after
:_pend_blank
echo(
:_pend_after
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_print_col=0" & exit /B 0
