@echo off
@REM CMP_GE: a >= b
call %GWSRC%\rtl\_cmp %~1 GE
exit /B %ERRORLEVEL%
