@echo off
@REM PARAM_MARK: sentinel between a DEF FN name and its parameter list.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% PARAM_MRK
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
