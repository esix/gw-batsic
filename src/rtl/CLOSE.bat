@echo off
@REM CLOSE: pop channel numbers down to CLOSE_MRK and close each handle.
@REM Bare CLOSE (no channels) closes every open file.
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_any="
:_cl_loop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_cl_done
  if "!_v!"=="CLOSE_MRK" goto :_cl_done
  set "_any=1"
  call %GWSRC%\exec\_resolve !_v! _v
  call :_toInt !_v! _n
  call %GWSRC%\exec\_files close !_n!
  goto :_cl_loop
:_cl_done
if not defined _any call %GWSRC%\exec\_files closeall
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_toInt
  set "_v=%~1" & set "_t=!_v:~0,1!"
  if "!_t!"=="i" call %GWSRC%\num\int toDec !_v!
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & call %GWSRC%\num\int toDec !__!)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
