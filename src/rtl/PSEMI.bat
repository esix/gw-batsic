@echo off
@REM PSEMI: pop value, print without newline (semicolon separator)
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
@REM Check STR_ before single-char tag prefixes (batch `if` is case-insensitive).
if "!_a:~0,4!"=="STR_" (
  if "!_a!"=="STR_" (
    rem empty string — nothing to print
  ) else (
    call %GWSRC%\str\str decode !_a:~4! _txt
    <nul set /p "=!_txt!"
  )
) else (
  set "_tp=!_a:~0,1!"
  if "!_tp!"=="i" (
    call %GWSRC%\num\int toDec !_a!
    <nul set /p "= !__!"
  ) else if "!_tp!"=="s" (
    call %GWSRC%\num\sng toDec !_a!
    <nul set /p "= !__!"
  ) else if "!_tp!"=="d" (
    call %GWSRC%\num\dbl toDec !_a!
    <nul set /p "= !__!"
  ) else (
    <nul set /p "=!_a!"
  )
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
