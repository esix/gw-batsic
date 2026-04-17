@echo off
@REM GOTO: pop target line number, override _next_line
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _t
call %GWSRC%\exec\_resolve !_t! _t
@REM Target is a tagged value (e.g. i0014 from NUM_i0014). Convert to decimal.
set "_tp=!_t:~0,1!"
if "!_tp!"=="i" call %GWSRC%\num\int toDec !_t!
if "!_tp!"=="s" call %GWSRC%\num\sng toDec !_t!
if "!_tp!"=="d" call %GWSRC%\num\dbl toDec !_t!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_next_line=%__%" & exit /B 0
