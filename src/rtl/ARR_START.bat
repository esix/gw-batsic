@echo off
@REM ARR_START: push a sentinel "ARR_MRK" onto the data stack. Marks the
@REM beginning of array-index/dim-bound expressions for DIM / AIDX / ASSIGN_ARR.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% ARR_MRK
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
