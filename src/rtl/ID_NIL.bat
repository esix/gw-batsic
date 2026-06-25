@echo off
@REM ID_NIL: INPUT$(n) with no channel — push a sentinel so @FN_INPUTDOLLAR
@REM knows to read from the console rather than a file.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% IDNIL
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
