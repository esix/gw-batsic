@echo off
@REM ASSIGN_ARR: pop value, pop indices (until ARR_MRK), pop VAR, store element.
@REM Stack: ... VAR_UNK_A ARR_MRK i1 [i2 [i3]] value → ...
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _val
call %GWSRC%\exec\_resolve !_val! _val
set "_rev="
:_asn_loop
  call %GWSRC%\stl\vec pop %_s% _v
  if "!_v!"=="ARR_MRK" goto :_asn_done
  call %GWSRC%\exec\_resolve !_v! _v
  call :_toInt !_v! _d
  if "!_rev!"=="" (set "_rev=!_d!") else (set "_rev=!_d! !_rev!")
  goto :_asn_loop
:_asn_done
call %GWSRC%\stl\vec pop %_s% _name
if "!_name:~0,4!"=="VAR_" set "_name=ARR_!_name:~4!"
@REM Promote value to array's type if needed
call %GWSRC%\exec\_arrays typeof !_name! _tp
set "_vtp=!_val:~0,1!"
if "!_tp!"=="i" if "!_vtp!" neq "i" (
  if "!_vtp!"=="s" (call %GWSRC%\num\sng toInt !_val! & set "_val=!__!")
  if "!_vtp!"=="d" (call %GWSRC%\num\dbl toInt !_val! & set "_val=!__!")
)
if "!_tp!"=="s" if "!_vtp!"=="i" (call %GWSRC%\num\sng fromInt !_val! & set "_val=!__!")
if "!_tp!"=="d" if "!_vtp!"=="i" (call %GWSRC%\num\dbl fromInt !_val! & set "_val=!__!")
call %GWSRC%\exec\_arrays set !_name! !_rev! !_val!
set "_err=%ERRORLEVEL%"
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
