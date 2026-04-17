@echo off
@REM Promote two tagged numeric values to a common type.
@REM Promotion order: int (i) < single (s) < double (d).
@REM
@REM Usage:
@REM   call _promote a b
@REM Returns:
@REM   __a = promoted a
@REM   __b = promoted b
@REM   __t = target type letter (i / s / d)

setlocal EnableDelayedExpansion
set "_a=%~1"
set "_b=%~2"
set "_ta=!_a:~0,1!"
set "_tb=!_b:~0,1!"
@REM Pick the highest type
set "_tt=i"
if "!_ta!"=="s" set "_tt=s"
if "!_tb!"=="s" set "_tt=s"
if "!_ta!"=="d" set "_tt=d"
if "!_tb!"=="d" set "_tt=d"
@REM Promote a if needed
if "!_ta!" neq "!_tt!" (
  if "!_tt!"=="s" call %GWSRC%\num\sng fromInt !_a!
  if "!_tt!"=="d" call %GWSRC%\num\dbl fromInt !_a!
  set "_a=!__!"
)
@REM Promote b if needed
if "!_tb!" neq "!_tt!" (
  if "!_tt!"=="s" call %GWSRC%\num\sng fromInt !_b!
  if "!_tt!"=="d" call %GWSRC%\num\dbl fromInt !_b!
  set "_b=!__!"
)
endlocal & set "__a=%_a%" & set "__b=%_b%" & set "__t=%_tt%" & exit /B 0
