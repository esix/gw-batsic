@echo off
@REM CMP_NE: a <> b
call %GWSRC%\rtl\_cmp %~1 NE
exit /B %ERRORLEVEL%
