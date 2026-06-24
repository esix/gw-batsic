@echo off
@REM RUN_FILE: RUN <file-expr>[,R] - the filename is any string expression
@REM (literal, variable, array element, concatenation); the optional ,R flag is
@REM already popped+discarded by @RUN_ROPT, so we just pop and resolve the
@REM filename, then signal restart-with-load (flow code 98).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
if not "!_a:~0,4!"=="STR_" goto :_rf_err
set "_path="
if not "!_a!"=="STR_" call %GWSRC%\str\str decode !_a:~4! _path
if not defined _path goto :_rf_err
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_run_file=%_path%" & set "_run_line=" & exit /B 98
:_rf_err
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 64
