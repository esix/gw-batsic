@echo off
@REM FN_RIGHT: RIGHT$(s, n) — last n chars of s.
@REM Stack: STR_<hex> NUM_i<n> → STR_<hex_clipped>.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _n
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_n! _n
call %GWSRC%\exec\_resolve !_a! _a
if not "!_a:~0,4!"=="STR_" (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
call :_toIntDec !_n! _ni
if !_ni! LSS 0 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 5
)
set "_h=!_a:~4!"
@REM Compute current length in chars and clip.
set /a "_take=_ni*2"
@REM Compute total hex length cheaply via :~0,N tricks not available — count loop.
set "_hh=!_h!"
set /a "_len=0"
:_rl_loop
  if "!_hh!"=="" goto :_rl_done
  set /a "_len+=2"
  set "_hh=!_hh:~2!"
  goto :_rl_loop
:_rl_done
if !_take! GEQ !_len! (
  @REM Whole string.  Propagation happens after the block: %_final% inside
  @REM parens would expand at parse time, before set "_final=..." runs.
  call %GWSRC%\stl\vec push %_s% STR_!_h!
  goto :_rl_ret
)
set /a "_skip=_len-_take"
set "_out=!_h:~%_skip%!"
call %GWSRC%\stl\vec push %_s% STR_!_out!
:_rl_ret
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_toIntDec
  set "_v=%~1"
  set "_t=!_v:~0,1!"
  if "!_t!"=="i" (call %GWSRC%\num\int toDec !_v! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  exit /B 13
