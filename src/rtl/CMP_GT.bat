@echo off
@REM CMP_GT: a > b
call %GWSRC%\rtl\_cmp %~1 GT
exit /B %ERRORLEVEL%
