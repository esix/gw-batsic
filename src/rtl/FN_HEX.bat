@echo off
@REM HEX$(n) : hexadecimal-digit string of n's 16-bit value (no leading zeros).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call :_toIHex !_a! _h
:_hstrip
  if not "!_h:~0,1!"=="0" goto :_hdone
  if "!_h:~1!"=="" goto :_hdone
  set "_h=!_h:~1!"
  goto :_hstrip
:_hdone
call %GWSRC%\str\str encode "!_h!" _ph
call %GWSRC%\stl\vec push %_s% STR_!_ph!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

@REM Convert a resolved numeric value to its 4-char int hex (i<HHHH> -> HHHH).
:_toIHex
  set "_thv=%~1" & set "_tht=!_thv:~0,1!"
  if "!_tht!"=="i" set "__=!_thv!"
  if "!_tht!"=="s" call %GWSRC%\num\sng toInt !_thv!
  if "!_tht!"=="d" call %GWSRC%\num\dbl toInt !_thv!
  set "%~2=%__:~1%"
  exit /B 0
