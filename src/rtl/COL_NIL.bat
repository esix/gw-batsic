@echo off
@REM COL_NIL: push the "elided argument" sentinel for an omitted COLOR slot.
call %GWSRC%\stl\vec push %~1 COL_NIL
exit /B 0
