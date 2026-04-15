@echo off
@REM PSEMI: pop value, print without newline (semicolon separator)
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_tp=!_a:~0,1!"
if "!_tp!"=="i" (
  call %GWSRC%\num\int toDec !_a!
  <nul set /p "= !__!"
) else if "!_tp!"=="s" (
  call %GWSRC%\num\sng toDec !_a!
  <nul set /p "= !__!"
) else if "!_a:~0,4!"=="STR_" (
  call %GWSRC%\str\str decode !_a:~4! _txt
  <nul set /p "=!_txt!"
) else (
  <nul set /p "=!_a!"
)
endlocal
exit /B 0
