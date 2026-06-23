@echo off
@REM ARG_MARK: sentinel between an FN call name and its argument list.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% ARG_MRK
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
