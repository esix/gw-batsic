@echo off
@REM ERROR n : raise runtime error n (traps to ON ERROR handler if armed).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _c
call %GWSRC%\exec\_resolve !_c! _c
call :_toInt !_c! _cd
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B %_cd%

:_toInt
  set "_tiv=%~1" & set "_tit=!_tiv:~0,1!"
  if "!_tit!"=="i" call %GWSRC%\num\int toDec !_tiv!
  if "!_tit!"=="s" (call %GWSRC%\num\sng toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  if "!_tit!"=="d" (call %GWSRC%\num\dbl toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
