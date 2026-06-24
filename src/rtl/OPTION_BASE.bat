@echo off
@REM OPTION BASE n : set the array subscript lower bound (0 or 1) for all arrays.
@REM Grammar is OPTION VAR NUM (BASE lexes as a variable, since BASE is also a
@REM legal identifier); pop the NUM (the base) then discard the BASE token.
@REM _option_base is read by _arrays dim/_offset; 0 (default) is the no-op path.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _v
call %GWSRC%\stl\vec pop %_s% _bvar
call %GWSRC%\exec\_resolve !_v! _v
set "_b=0"
if "!_v!"=="i0001" set "_b=1"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_option_base=%_b%" & exit /B 0
