@echo off
@REM KEY(n) ON / OFF / STOP : arm/disarm/suspend function-key event trapping.
@REM Parsed and accepted, but inert at runtime: batch has no non-blocking
@REM keyboard read (the same limit that makes INKEY$ block — see
@REM docs/99-not-implementable.md), so a trapped key can never be detected
@REM between statements and the handler can never fire.  We pop the key
@REM number to keep the operand stack balanced and return cleanly.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _kn
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
