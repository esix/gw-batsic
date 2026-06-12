@echo off
@REM NEW: erase the program and all variables, then halt execution with
@REM flow code 99 (the same graceful halt END and STOP use).
call %GWSRC%\exec\_program init
call %GWSRC%\exec\_vars init
call %GWSRC%\exec\_arrays init
exit /B 99
