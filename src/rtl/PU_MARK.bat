@echo off
@REM PU_MARK: push the PRINT USING value-list sentinel.
call %GWSRC%\stl\vec push %~1 PU_MARK
exit /B 0
