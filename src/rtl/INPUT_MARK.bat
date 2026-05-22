@echo off
@REM INPUT_MARK: push a sentinel onto the stack so @INPUT knows where the
@REM var list begins.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% INPUT_MRK
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
