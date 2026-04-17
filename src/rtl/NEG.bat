@echo off
@REM NEG: pop one value, negate (in its own type), push result
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
if "!_t!"=="i" call %GWSRC%\num\int neg !_a!
if "!_t!"=="s" call %GWSRC%\num\sng neg !_a!
if "!_t!"=="d" call %GWSRC%\num\dbl neg !_a!
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
