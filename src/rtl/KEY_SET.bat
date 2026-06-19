@echo off
@REM KEY n, str$: assign a soft key.  We have no function-key buffer or
@REM label line, so pop the two operands and discard them (no-op).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _b
call %GWSRC%\stl\vec pop %_s% _a
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
