@echo off
@REM FN_ERR: push current error code (ERR) onto the stack as a number.
@REM Uses double precision (dbl) so 0..65535 round-trip cleanly through toDec.
setlocal EnableDelayedExpansion
set "_s=%~1"
set /a "_n=_err_code"
if "!_n!"=="" set "_n=0"
call %GWSRC%\num\dbl fromDec !_n!
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
