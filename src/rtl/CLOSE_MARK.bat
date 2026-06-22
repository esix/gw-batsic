@echo off
@REM CLOSE_MARK: push the CLOSE_MRK sentinel below the channel list.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% CLOSE_MRK
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
