@echo off
@REM DIV: pop two values, divide, push result
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _b
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call %GWSRC%\exec\_resolve !_b! _b
call %GWSRC%\num\int div !_a! !_b!
endlocal & call %GWSRC%\stl\vec push %~1 %__%
exit /B 0
