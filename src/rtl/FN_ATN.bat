@echo off
@REM FN_ATN: arctangent, single-precision.  See FN_SQR.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
set "_d="
if "!_t!"=="i" (call %GWSRC%\num\int toDec !_a! & set "_d=!__!")
if "!_t!"=="s" (call %GWSRC%\num\sng toDec !_a! & set "_d=!__!")
if "!_t!"=="d" (call %GWSRC%\num\dbl toDec !_a! & set "_d=!__!")
if not defined _d (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
for /f "usebackq delims=" %%r in (`powershell -NoLogo -NoProfile -Command "([Math]::Atan('!_d!')).ToString('G6', [System.Globalization.CultureInfo]::InvariantCulture)"`) do set "_res=%%r"
call %GWSRC%\num\sng fromDec !_res!
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
