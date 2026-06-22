@echo off
@REM FILES with no spec: list every file in the current directory.
setlocal EnableDelayedExpansion
set "_s=%~1"
dir /b 2>nul
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
