@echo off
@REM LOC_NIL: push the "elided argument" sentinel for an omitted LOCATE slot.
call %GWSRC%\stl\vec push %~1 LOC_NIL
exit /B 0
