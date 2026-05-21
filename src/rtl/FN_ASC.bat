@echo off
@REM FN_ASC: ASC(s) — ASCII code of the first character of s.
@REM Stack: STR_<hex> → NUM_i<code>.  Empty string → 5 (Illegal function call).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
if not "!_a:~0,4!"=="STR_" (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
set "_h=!_a:~4!"
if "!_h!"=="" (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 5
)
set /a "_n=0x!_h:~0,2!"
call %GWSRC%\num\int fromDec !_n!
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
