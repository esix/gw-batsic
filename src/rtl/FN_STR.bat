@echo off
@REM FN_STR: STR$(n) — convert number to string.  GW-BASIC adds a leading
@REM space placeholder for non-negative numbers and "-" for negatives.
@REM Stack: NUM_<t><...> → STR_<hex>.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
set "_txt="
if "!_t!"=="i" (
  call %GWSRC%\num\int toDec !_a!
  set "_d=!__!"
  if "!_d:~0,1!"=="-" (set "_txt=!_d!") else (set "_txt= !_d!")
)
if "!_t!"=="s" (
  call %GWSRC%\num\sng toDec !_a!
  set "_d=!__!"
  if "!_d:~0,1!"=="-" (set "_txt=!_d!") else (set "_txt= !_d!")
)
if "!_t!"=="d" (
  call %GWSRC%\num\dbl toDec !_a!
  set "_d=!__!"
  if "!_d:~0,1!"=="-" (set "_txt=!_d!") else (set "_txt= !_d!")
)
if not defined _txt (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
call %GWSRC%\str\str encode "!_txt!" _hex
call %GWSRC%\stl\vec push %_s% STR_!_hex!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
