@echo off
@REM RESET: close all open files (flush + release every handle).
call %GWSRC%\exec\_files closeall
exit /B 0
