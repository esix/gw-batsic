@echo off
@REM CLEAR_MARK: push the CLEAR_MRK sentinel below CLEAR's (ignored) size args.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% CLEAR_MRK
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
