@echo off
@REM MKI$(n): pack a number as a 2-byte little-endian signed int string.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
set "_ih="
if "!_t!"=="i" set "_ih=!_a:~1!"
if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_a! & set "_ih=!__:~1!")
if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_a! & set "_ih=!__:~1!")
@REM int16 hex is big-endian (HH LL); little-endian bytes = LL HH.
set "_le=!_ih:~2,2!!_ih:~0,2!"
call %GWSRC%\stl\vec push %_s% STR_!_le!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
