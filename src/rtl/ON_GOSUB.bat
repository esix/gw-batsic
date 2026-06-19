@echo off
@REM ON_GOSUB: like ON_GOTO but records GOSUB mode; ON_END pushes the return
@REM address before jumping.  Postfix: <n> ON_GOSUB line1 ... ON_END.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _x
call %GWSRC%\exec\_resolve !_x! _x
call :_toint !_x! _idx
call %GWSRC%\stl\vec push %_s% ON_MARK
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_on_idx=%_idx%" & set "_on_mode=GOSUB" & exit /B 0

:_toint
  set "_v=%~1"
  set "_t=!_v:~0,1!"
  if "!_t!"=="i" (call %GWSRC%\num\int toDec !_v! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  set "%~2=0"
  exit /B 0
