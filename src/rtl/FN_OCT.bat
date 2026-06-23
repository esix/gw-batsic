@echo off
@REM OCT$(n) : octal-digit string of n's 16-bit unsigned value.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call :_toIHex !_a! _h
set /a "_u=0x!_h!"
set "_o="
if !_u! EQU 0 set "_o=0"
:_oloop
  if !_u! EQU 0 goto :_odone
  set /a "_dg=_u%%8"
  set "_o=!_dg!!_o!"
  set /a "_u/=8"
  goto :_oloop
:_odone
call %GWSRC%\str\str encode "!_o!" _po
call %GWSRC%\stl\vec push %_s% STR_!_po!
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
