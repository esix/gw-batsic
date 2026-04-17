@echo off
@REM AIDX: pop indices (until ARR_MRK), pop target VAR, fetch array element,
@REM push value. Stack: ... VAR_UNK_A ARR_MRK i1 [i2 [i3]] → ... element
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_rev="
:_aidx_loop
  call %GWSRC%\stl\vec pop %_s% _v
  if "!_v!"=="ARR_MRK" goto :_aidx_done
  call %GWSRC%\exec\_resolve !_v! _v
  call :_toInt !_v! _d
  if "!_rev!"=="" (set "_rev=!_d!") else (set "_rev=!_d! !_rev!")
  goto :_aidx_loop
:_aidx_done
call %GWSRC%\stl\vec pop %_s% _name
if "!_name:~0,4!"=="VAR_" set "_name=ARR_!_name:~4!"
call %GWSRC%\exec\_arrays get !_name! !_rev! __
set "_err=%ERRORLEVEL%"
if !_err! neq 0 goto :_aidx_err
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
:_aidx_err
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B %_err%

:_toInt VALUE retVar
  set "_vv=%~1"
  set "_tp=!_vv:~0,1!"
  if "!_tp!"=="i" call %GWSRC%\num\int toDec !_vv!
  if "!_tp!"=="s" (call %GWSRC%\num\sng toInt !_vv! & call %GWSRC%\num\int toDec !__!)
  if "!_tp!"=="d" (call %GWSRC%\num\dbl toInt !_vv! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
