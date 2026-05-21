@echo off
@REM CMP_LE: a <= b
call %GWSRC%\rtl\_cmp %~1 LE
exit /B %ERRORLEVEL%
