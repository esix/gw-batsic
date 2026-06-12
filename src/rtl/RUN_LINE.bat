@echo off
@REM RUN_LINE: RUN <num> - pop the target line number and signal a
@REM restart (flow code 98) that starts there instead of the first line.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
set "_ln="
if "!_t!"=="i" (call %GWSRC%\num\int toDec !_a! & set "_ln=!__!")
if "!_t!"=="s" (call %GWSRC%\num\sng toDec !_a! & set "_ln=!__!")
if "!_t!"=="d" (call %GWSRC%\num\dbl toDec !_a! & set "_ln=!__!")
if not defined _ln goto :_rl_err
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_run_line=%_ln%" & set "_run_file=" & exit /B 98
:_rl_err
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 13
