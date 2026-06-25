@echo off
@REM Elided SCREEN argument (e.g. the mode in `SCREEN ,,0`): push a NIL slot.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% SCR_NIL
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
