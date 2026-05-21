@echo off
@REM FN_CHR: CHR$(n) — convert int 0..255 to a 1-char string.
@REM Stack: NUM_i<n> → STR_<2-hex>.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
@REM Convert to int.
set "_t=!_a:~0,1!"
set "_n="
if "!_t!"=="i" (
  call %GWSRC%\num\int toDec !_a!
  set "_n=!__!"
)
if "!_t!"=="s" (
  call %GWSRC%\num\sng toInt !_a!
  call %GWSRC%\num\int toDec !__!
  set "_n=!__!"
)
if "!_t!"=="d" (
  call %GWSRC%\num\dbl toInt !_a!
  call %GWSRC%\num\int toDec !__!
  set "_n=!__!"
)
if not defined _n (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
if !_n! LSS 0 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 5
)
if !_n! GTR 255 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 5
)
@REM Format as 2-hex.
set /a "_h1=!_n!/16"
set /a "_h2=!_n!%%16"
set "_HD=0123456789ABCDEF"
call set "_hh=%%_HD:~%_h1%,1%%%%_HD:~%_h2%,1%%"
call %GWSRC%\stl\vec push %_s% STR_!_hh!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
