@echo off
@REM PSEMI_END: trailing semicolon in PRINT — print the last item with no
@REM separator and no newline.  Same as PSEMI: pop value, render, emit
@REM without trailing newline.  Updates _print_col for the next PRINT to
@REM continue on the same line.
call %GWSRC%\rtl\PSEMI %~1
exit /B %ERRORLEVEL%
