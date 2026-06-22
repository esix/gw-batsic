@echo off
@REM EOF(n): -1 (true) if file channel n is at end-of-data, else 0.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call :_toInt !_a! _n
call %GWSRC%\exec\_files atEof !_n! _r
call %GWSRC%\num\int fromDec !_r!
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_toInt
  set "_v=%~1" & set "_t=!_v:~0,1!"
  if "!_t!"=="i" call %GWSRC%\num\int toDec !_v!
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & call %GWSRC%\num\int toDec !__!)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
