@echo off
@REM INSTR([n,] x$, y$) : 1-based position of y$ within x$ at/after n (default
@REM 1); 0 if not found.  Stack (bottom->top): a b (c|INSTR_NIL).
@REM   INSTR_NIL -> 2-arg: x$=a, y$=b, n=1.   else 3-arg: n=a, x$=b, y$=c.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _c
call %GWSRC%\stl\vec pop %_s% _b
call %GWSRC%\stl\vec pop %_s% _a
if "!_c!"=="INSTR_NIL" (
  set "_n=1" & set "_x=!_a!" & set "_y=!_b!"
) else (
  call %GWSRC%\exec\_resolve !_a! _a & call :_toInt !_a! _n
  set "_x=!_b!" & set "_y=!_c!"
)
call %GWSRC%\exec\_resolve !_x! _x
call %GWSRC%\exec\_resolve !_y! _y
@REM hex bodies (empty STR_ -> empty)
set "_xh=" & set "_yh="
if "!_x:~0,4!"=="STR_" if not "!_x!"=="STR_" set "_xh=!_x:~4!"
if "!_y:~0,4!"=="STR_" if not "!_y!"=="STR_" set "_yh=!_y:~4!"
call :_hexlen "!_xh!" _lx
call :_hexlen "!_yh!" _ly
if !_n! LSS 1 set "_n=1"
set "_pos=0"
@REM GW: empty search string returns n (when within the string), else handle bounds.
if !_ly! EQU 0 (set "_pos=!_n!" & goto :_emit)
if !_n! GTR !_lx! goto :_emit
set /a "_last=_lx-_ly+1"
set "_i=!_n!"
:_scan
  if !_i! GTR !_last! goto :_emit
  set /a "_off=(_i-1)*2"
  set /a "_w=_ly*2"
  for /f %%o in ("!_off!") do for /f %%w in ("!_w!") do set "_seg=!_xh:~%%o,%%w!"
  if /I "!_seg!"=="!_yh!" (set "_pos=!_i!" & goto :_emit)
  set /a "_i+=1"
  goto :_scan
:_emit
call %GWSRC%\num\int fromDec !_pos!
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_hexlen
  setlocal EnableDelayedExpansion
  set "_hl=%~1" & set /a "_hn=0"
:_hll
  if not "!_hl!"=="" (set "_hl=!_hl:~2!" & set /a "_hn+=1" & goto :_hll)
  endlocal & set "%~2=%_hn%" & exit /B 0

:_toInt
  set "_tiv=%~1" & set "_tit=!_tiv:~0,1!"
  if "!_tit!"=="i" call %GWSRC%\num\int toDec !_tiv!
  if "!_tit!"=="s" (call %GWSRC%\num\sng toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  if "!_tit!"=="d" (call %GWSRC%\num\dbl toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
