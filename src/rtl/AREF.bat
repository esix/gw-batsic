@echo off
@REM AREF: build an array-element L-VALUE token for READ / INPUT targets.
@REM Stack: ... VAR_xxx_NAME ARR_MRK i1 [i2 ...] -> ... AREF:VAR_xxx_NAME:i1[:i2]
@REM (a single token so the target list stays one-item-per-target).  Unlike
@REM AIDX it does NOT read the element value; @READ/@INPUT decode it and store.
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_ord="
:_loop
  call %GWSRC%\stl\vec pop %_s% _v
  if "!_v!"=="ARR_MRK" goto :_done
  call %GWSRC%\exec\_resolve !_v! _v
  call :_toInt !_v! _d
  if "!_ord!"=="" (set "_ord=!_d!") else (set "_ord=!_d! !_ord!")
  goto :_loop
:_done
call %GWSRC%\stl\vec pop %_s% _name
set "_idx="
for %%i in (!_ord!) do (if defined _idx (set "_idx=!_idx!:%%i") else (set "_idx=%%i"))
call %GWSRC%\stl\vec push %_s% AREF:!_name!:!_idx!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_toInt
  set "_vv=%~1"
  set "_tp=!_vv:~0,1!"
  if "!_tp!"=="i" call %GWSRC%\num\int toDec !_vv!
  if "!_tp!"=="s" (call %GWSRC%\num\sng toInt !_vv! & call %GWSRC%\num\int toDec !__!)
  if "!_tp!"=="d" (call %GWSRC%\num\dbl toInt !_vv! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
