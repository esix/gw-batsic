@echo off
@REM PFILE_CLR: end PRINT#/WRITE# file output — restore the console sink.
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_print_path=" & set "_print_col=0" & exit /B 0
