@echo off
@REM PTAB_END: trailing comma in PRINT — print the last item, pad to next
@REM 14-col tab stop, no newline.  Same as PTAB.
call %GWSRC%\rtl\PTAB %~1
exit /B %ERRORLEVEL%
