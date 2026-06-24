@echo off
@REM LIST_MAX: omitted LIST end -> LIST_MAX sentinel (to end of program).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% LIST_MAX
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
