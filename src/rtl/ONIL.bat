@echo off
@REM ONIL: push the ONIL sentinel marking an omitted reclen / LEN.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% ONIL
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
