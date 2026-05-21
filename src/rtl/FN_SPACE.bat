@echo off
@REM FN_SPACE: SPACE$(n) — string of n space characters.
@REM Stack: NUM_i<n> → STR_<n × "20">.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call :_toIntDec !_a! _n
if !_n! LSS 0 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 5
)
set "_out="
set /a "_i=0"
:_sp_loop
  if !_i! GEQ !_n! goto :_sp_done
  set "_out=!_out!20"
  set /a "_i+=1"
  goto :_sp_loop
:_sp_done
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
