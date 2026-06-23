@echo off
@REM CHAIN file[,line] : load/overlay another program, PRESERVING variables
@REM (flow code 98 with _chain_keep set so _runInit skips clearing vars/arrays).
@REM Stack: filename line-or-CHAIN_NIL.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _ln
set "_chln="
if not "!_ln!"=="CHAIN_NIL" (
  call %GWSRC%\exec\_resolve !_ln! _ln
  call :_toInt !_ln! _chln
)
call %GWSRC%\stl\vec pop %_s% _fn
call %GWSRC%\exec\_resolve !_fn! _fn
if not "!_fn:~0,4!"=="STR_" goto :_ch_err
set "_path="
if not "!_fn!"=="STR_" call %GWSRC%\str\str decode !_fn:~4! _path
if not defined _path goto :_ch_err
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_run_file=%_path%" & set "_run_line=%_chln%" & set "_chain_keep=1" & exit /B 98
:_ch_err
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 64

:_toInt
  set "_tiv=%~1" & set "_tit=!_tiv:~0,1!"
  if "!_tit!"=="i" call %GWSRC%\num\int toDec !_tiv!
  if "!_tit!"=="s" (call %GWSRC%\num\sng toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  if "!_tit!"=="d" (call %GWSRC%\num\dbl toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
