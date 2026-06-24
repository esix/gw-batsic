@echo off
@REM LIST_AE: bare LIST (no range) -> push start LIST_MIN and end LIST_MAX.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% LIST_MIN
call %GWSRC%\stl\vec push %_s% LIST_MAX
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
