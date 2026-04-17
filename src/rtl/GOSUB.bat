@echo off
@REM GOSUB: pop target line number, push current _next_line on the gosub
@REM stack, then override _next_line with target.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _t
call %GWSRC%\exec\_resolve !_t! _t
set "_tp=!_t:~0,1!"
if "!_tp!"=="i" call %GWSRC%\num\int toDec !_t!
if "!_tp!"=="s" call %GWSRC%\num\sng toDec !_t!
if "!_tp!"=="d" call %GWSRC%\num\dbl toDec !_t!
set "_target=!__!"
@REM Push current _next_line (the natural next, set by RUN loop) as return addr
call %GWSRC%\stl\vec push _gosub_stack !_next_line!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_next_line=%_target%" & set "_gosub_stack=%_gosub_stack%" & exit /B 0
