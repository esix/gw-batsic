@echo off
@REM SCREEN argument-list start marker (mirrors LOCATE's @LOC_MARK).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% SCR_MARK
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
