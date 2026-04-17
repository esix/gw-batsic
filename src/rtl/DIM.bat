@echo off
@REM DIM: pop bounds (until ARR_MRK), then pop target VAR; declare array.
@REM Stack: ... VAR_UNK_A ARR_MRK b1 [b2 [b3]] → ...
setlocal EnableDelayedExpansion
set "_s=%~1"
@REM Collect bounds in reverse pop order; reverse them into _bnds
set "_rev="
:_dim_loop
  call %GWSRC%\stl\vec pop %_s% _v
  if "!_v!"=="ARR_MRK" goto :_dim_done
  @REM Resolve and convert to decimal integer
  call %GWSRC%\exec\_resolve !_v! _v
  call :_toInt !_v! _d
  if "!_rev!"=="" (set "_rev=!_d!") else (set "_rev=!_d! !_rev!")
  goto :_dim_loop
:_dim_done
call %GWSRC%\stl\vec pop %_s% _name
@REM Coerce to ARR_ namespace: VAR_UNK_A → ARR_UNK_A etc.
if "!_name:~0,4!"=="VAR_" set "_name=ARR_!_name:~4!"
call %GWSRC%\exec\_arrays dim !_name! !_rev!
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
