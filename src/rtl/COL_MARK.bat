@echo off
@REM COL_MARK: push the COLOR argument-list sentinel onto the stack.
call %GWSRC%\stl\vec push %~1 COL_MARK
exit /B 0
