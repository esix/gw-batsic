@echo off
@REM CMP_EQ: a = b — push -1 if equal, 0 otherwise.
call %GWSRC%\rtl\_cmp %~1 EQ
exit /B %ERRORLEVEL%
