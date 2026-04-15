@echo off
@REM REM: comment — pop the comment text, ignore it
setlocal EnableDelayedExpansion
call %GWSRC%\stl\vec pop %~1 _a
endlocal
exit /B 0
