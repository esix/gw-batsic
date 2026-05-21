@echo off
@REM IDIV: integer division (\).  Both operands forced to int, then int div;
@REM push the quotient.  In GW-BASIC int div truncates toward zero.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _b
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call %GWSRC%\exec\_resolve !_b! _b
call :_toInt !_a! _a
call :_toInt !_b! _b
call %GWSRC%\num\int div !_a! !_b!
set "_e=!ERRORLEVEL!"
if !_e! neq 0 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B %_e%
)
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_toInt
  set "_v=%~1"
  set "_t=!_v:~0,1!"
  if "!_t!"=="i" (set "%~2=!_v!" & exit /B 0)
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & set "%~2=!__!" & exit /B 0)
  exit /B 13
