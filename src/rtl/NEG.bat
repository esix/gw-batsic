@echo off
@REM NEG: pop one value, negate, push result
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call %GWSRC%\num\int neg !_a!
endlocal & call %GWSRC%\stl\vec push %~1 %__%
exit /B 0
