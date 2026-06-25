@echo off
@REM COMMON declares CHAIN-shared variables.  We already preserve every variable
@REM across CHAIN, so each declared name just needs to be popped off the stack.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _v
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
