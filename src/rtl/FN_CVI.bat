@echo off
@REM CVI(s$): unpack the first 2 bytes (little-endian) as a signed int.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_h="
if "!_a:~0,4!"=="STR_" if not "!_a!"=="STR_" set "_h=!_a:~4!"
set "_b0=!_h:~0,2!"
set "_b1=!_h:~2,2!"
if "!_b0!"=="" set "_b0=00"
if "!_b1!"=="" set "_b1=00"
call %GWSRC%\stl\vec push %_s% i!_b1!!_b0!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
