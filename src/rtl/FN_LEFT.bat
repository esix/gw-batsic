@echo off
@REM FN_LEFT: LEFT$(s, n) — first n chars of s.
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
@REM Convert n to int decimal.
call :_toIntDec !_n! _ni
if !_ni! LSS 0 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 5
)
set "_h=!_a:~4!"
@REM Take first 2n hex digits.
set /a "_take=_ni*2"
set "_out=!_h:~0,%_take%!"
call %GWSRC%\stl\vec push %_s% STR_!_out!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_toIntDec
  set "_v=%~1"
  set "_t=!_v:~0,1!"
  if "!_t!"=="i" (call %GWSRC%\num\int toDec !_v! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  exit /B 13
