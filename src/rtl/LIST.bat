@echo off
@REM LIST [lo-hi] : list program lines lo..hi (LIST_MIN=0, LIST_MAX=end), then
@REM halt — GW-BASIC returns to command level after a LIST (flow code 99).
@REM Stack (bottom->top): start end.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _end
call %GWSRC%\stl\vec pop %_s% _start
call :_lnum "!_start!" _lo
call :_lnum "!_end!" _hi
call %GWSRC%\exec\_program listRange !_lo! !_hi!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 99

:_lnum
  set "_lv=%~1"
  if "!_lv!"=="LIST_MIN" (set "%~2=0" & exit /B 0)
  if "!_lv!"=="LIST_MAX" (set "%~2=99999" & exit /B 0)
  call %GWSRC%\exec\_resolve !_lv! _lv
  set "_lt=!_lv:~0,1!"
  if "!_lt!"=="i" call %GWSRC%\num\int toDec !_lv!
  if "!_lt!"=="s" (call %GWSRC%\num\sng toInt !_lv! & call %GWSRC%\num\int toDec !__!)
  if "!_lt!"=="d" (call %GWSRC%\num\dbl toInt !_lv! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
