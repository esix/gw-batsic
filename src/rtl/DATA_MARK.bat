@echo off
@REM DATA_MARK: push a sentinel before the data values are pushed so @DATA
@REM can drain the stack down to it.  The real DATA-collection work happens
@REM at RUN time via a pre-scan of program.dat (see exec.bat :runProgram).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% DATA_MRK
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
