@echo off
@REM CHAIN_DEL: capture a MERGE "DELETE lo-hi" line range (pop hi then lo).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _hi
call %GWSRC%\stl\vec pop %_s% _lo
call %GWSRC%\exec\_resolve !_hi! _hi & call :_toInt !_hi! _hi
call %GWSRC%\exec\_resolve !_lo! _lo & call :_toInt !_lo! _lo
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_chain_del=%_lo% %_hi%" & exit /B 0

:_toInt
  set "_tiv=%~1" & set "_tit=!_tiv:~0,1!"
  if "!_tit!"=="i" call %GWSRC%\num\int toDec !_tiv!
  if "!_tit!"=="s" (call %GWSRC%\num\sng toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  if "!_tit!"=="d" (call %GWSRC%\num\dbl toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
