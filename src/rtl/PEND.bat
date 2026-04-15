@echo off
@REM PEND: pop value, print with newline
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
@REM Convert tagged value to printable string
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
) else if "!_a:~0,4!"=="STR_" (
  @REM Decode hex string to ASCII
  call %GWSRC%\str\str decode !_a:~4! _txt
  echo !_txt!
) else (
  echo !_a!
)
endlocal
exit /B 0
