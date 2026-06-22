@echo off
@REM ERR : the code of the most recently trapped error.
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_e=!_gw_err!"
if not defined _e set "_e=0"
call %GWSRC%\num\int fromDec !_e!
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
