@echo off
@REM ADD: pop two values, promote to common numeric type, add, push result
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _b
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call %GWSRC%\exec\_resolve !_b! _b
call %GWSRC%\exec\_promote !_a! !_b!
if "!__t!"=="i" call %GWSRC%\num\int add !__a! !__b!
if "!__t!"=="s" call %GWSRC%\num\sng add !__a! !__b!
if "!__t!"=="d" call %GWSRC%\num\dbl add !__a! !__b!
call %GWSRC%\stl\vec push %_s% !__!
@REM Propagate the locally-modified stack back to caller
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
