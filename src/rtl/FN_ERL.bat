@echo off
@REM FN_ERL: push current error line (ERL) onto the stack as a number.
@REM Uses double precision (dbl) so line numbers up to 65535 round-trip cleanly.
setlocal EnableDelayedExpansion
set "_s=%~1"
set /a "_n=_err_line"
if "!_n!"=="" set "_n=0"
call %GWSRC%\num\dbl fromDec !_n!
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
