@echo off
@REM WIDTH_MARK: push the WIDTH_MRK sentinel below the WIDTH argument list.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% WIDTH_MRK
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
