@echo off
@REM WRITE_MARK: push the WRITE_MRK sentinel below the WRITE value list.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% WRITE_MRK
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
