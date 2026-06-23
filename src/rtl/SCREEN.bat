@echo off
@REM SCREEN mode[,colorswitch[,apage[,vpage]]] : text mode 0 is accepted as a
@REM no-op (we ARE a text terminal); any graphics mode (>0) is not implementable
@REM here, so it raises error 73 ("Advanced Feature") — a program that tries to
@REM enter graphics mode fails cleanly at the SCREEN statement.  The mode is the
@REM first argument (bottom of the pushed args); pop them all, keep the mode.
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_mode="
:_loop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_done
  set "_mode=!_v!"
  goto :_loop
:_done
set "_final=!%_s%!"
if not defined _mode (endlocal & set "%~1=%_final%" & exit /B 0)
call %GWSRC%\exec\_resolve !_mode! _mode
call :_toInt !_mode! _m
if not "!_m!"=="0" (endlocal & set "%~1=%_final%" & exit /B 73)
endlocal & set "%~1=%_final%" & exit /B 0

:_toInt
  set "_tiv=%~1" & set "_tit=!_tiv:~0,1!"
  if "!_tit!"=="i" call %GWSRC%\num\int toDec !_tiv!
  if "!_tit!"=="s" (call %GWSRC%\num\sng toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  if "!_tit!"=="d" (call %GWSRC%\num\dbl toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
