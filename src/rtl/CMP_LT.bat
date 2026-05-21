@echo off
@REM CMP_LT: a < b
call %GWSRC%\rtl\_cmp %~1 LT
exit /B %ERRORLEVEL%
