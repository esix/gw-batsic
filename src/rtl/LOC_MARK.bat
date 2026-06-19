@echo off
@REM LOC_MARK: push the LOCATE argument-list sentinel onto the stack.
call %GWSRC%\stl\vec push %~1 LOC_MARK
exit /B 0
