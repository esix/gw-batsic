@echo off
@REM PEND: pop value, print with newline
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
@REM Convert tagged value to printable string.
@REM IMPORTANT: check STR_ before single-char tag prefixes — batch `if`
@REM is case-insensitive, so a literal "S" in "STR_" would match "s" (sng).
if "!_a:~0,4!"=="STR_" (
  if "!_a!"=="STR_" (
    echo(
  ) else (
    call %GWSRC%\str\str decode !_a:~4! _txt
    echo(!_txt!
  )
) else (
  set "_tp=!_a:~0,1!"
  if "!_tp!"=="i" (
    call %GWSRC%\num\int toDec !_a!
    echo  !__!
  ) else if "!_tp!"=="s" (
    call %GWSRC%\num\sng toDec !_a!
    echo  !__!
  ) else if "!_tp!"=="d" (
    call %GWSRC%\num\dbl toDec !_a!
    echo  !__!
  ) else (
    echo !_a!
  )
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
