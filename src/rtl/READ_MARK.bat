@echo off
@REM READ_MARK: push a sentinel so @READ knows where the var list starts.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% READ_MRK
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
