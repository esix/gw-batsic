@echo off
@REM LIST_DUP: LIST n (single line) -> duplicate the line number as the end.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _v
call %GWSRC%\stl\vec push %_s% !_v!
call %GWSRC%\stl\vec push %_s% !_v!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
