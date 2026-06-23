@echo off
@REM ON KEY(n) GOSUB line : register a function-key event handler (GOSUB 0
@REM disarms).  Accepted but inert for the same reason as KEY(n) ON/OFF/STOP
@REM (see KEY_TRAP.bat / docs/99-not-implementable.md): with no non-blocking
@REM key read, the trap can never trigger.  Pop the handler line and key
@REM number to balance the stack.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _ln
call %GWSRC%\stl\vec pop %_s% _kn
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
