@echo off
@REM RESUME line : continue at a specific line.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _ln
call %GWSRC%\exec\_resolve !_ln! _ln
call :_toInt !_ln! _l
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_next_line=%_l%" & exit /B 0

:_toInt
  set "_tiv=%~1" & set "_tit=!_tiv:~0,1!"
  if "!_tit!"=="i" call %GWSRC%\num\int toDec !_tiv!
  if "!_tit!"=="s" (call %GWSRC%\num\sng toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  if "!_tit!"=="d" (call %GWSRC%\num\dbl toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
