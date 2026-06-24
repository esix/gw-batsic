@echo off
@REM LIST_PUSH0: omitted LIST start -> LIST_MIN sentinel (line 0).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% LIST_MIN
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
