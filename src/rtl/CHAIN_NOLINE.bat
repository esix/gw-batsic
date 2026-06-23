@echo off
@REM CHAIN_NOLINE: sentinel for an omitted CHAIN start line, so @CHAIN/@CHAIN_MERGE
@REM always pop a line slot.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% CHAIN_NIL
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
