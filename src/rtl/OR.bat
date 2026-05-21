@echo off
@REM OR: bitwise OR on 16-bit integers (GW-BASIC convention).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _b
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call %GWSRC%\exec\_resolve !_b! _b
call :_toInt !_a! _ai
call :_toInt !_b! _bi
call %GWSRC%\num\int or !_ai! !_bi!
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
