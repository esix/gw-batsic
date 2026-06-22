@echo off
@REM MID$(target$, start [, len]) = value : overwrite up to `len` bytes of
@REM target$ (1-based `start`) with `value`, in place (target length unchanged).
@REM Stack (bottom->top): target start len value.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _value
call %GWSRC%\stl\vec pop %_s% _len
call %GWSRC%\stl\vec pop %_s% _start
call %GWSRC%\stl\vec pop %_s% _target
call %GWSRC%\exec\_resolve !_start! _start
call :_toInt !_start! _st
call %GWSRC%\exec\_resolve !_len! _len
call :_toInt !_len! _ln
call %GWSRC%\exec\_resolve !_value! _value
call %GWSRC%\exec\_resolve !_target! _tval
set "_vhex="
if "!_value:~0,4!"=="STR_" if not "!_value!"=="STR_" set "_vhex=!_value:~4!"
set "_thex="
if "!_tval:~0,4!"=="STR_" if not "!_tval!"=="STR_" set "_thex=!_tval:~4!"
call :_hexlen "!_thex!" _tlen
call :_hexlen "!_vhex!" _vlen
@REM offset (0-based) and replace count
set /a "_so=_st-1"
if !_so! LSS 0 set "_so=0"
set "_rep=!_ln!"
if !_rep! GTR !_vlen! set "_rep=!_vlen!"
set /a "_avail=_tlen-_so"
if !_rep! GTR !_avail! set "_rep=!_avail!"
if !_rep! LSS 0 set "_rep=0"
set /a "_p1=_so*2"
set /a "_p2=(_so+_rep)*2"
set /a "_vc=_rep*2"
set "_new=!_thex:~0,%_p1%!!_vhex:~0,%_vc%!!_thex:~%_p2%!"
call %GWSRC%\exec\_vars set !_target! STR_!_new!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_hexlen
  setlocal EnableDelayedExpansion
  set "_hl=%~1" & set /a "_n=0"
:_hl_loop
  if not "!_hl!"=="" (set "_hl=!_hl:~2!" & set /a "_n+=1" & goto :_hl_loop)
  endlocal & set "%~2=%_n%" & exit /B 0

:_toInt
  set "_tiv=%~1" & set "_tit=!_tiv:~0,1!"
  if "!_tit!"=="i" call %GWSRC%\num\int toDec !_tiv!
  if "!_tit!"=="s" (call %GWSRC%\num\sng toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  if "!_tit!"=="d" (call %GWSRC%\num\dbl toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
