@echo off
@REM FN_SQR: GW-BASIC SQR(n) — square root, returning a single-precision MBF.
@REM
@REM Stack: NUM_<n> → NUM_s<MBF>.
@REM
@REM Implementation: shell out to PowerShell's [Math]::Sqrt and feed the
@REM decimal result through `sng fromDec`.  PowerShell formatting is forced
@REM to the invariant culture so we don't get "1,41..." in locales that use
@REM comma as the decimal separator.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a

@REM Convert input to a decimal string.
set "_t=!_a:~0,1!"
set "_d="
if "!_t!"=="i" (call %GWSRC%\num\int toDec !_a! & set "_d=!__!")
if "!_t!"=="s" (call %GWSRC%\num\sng toDec !_a! & set "_d=!__!")
if "!_t!"=="d" (call %GWSRC%\num\dbl toDec !_a! & set "_d=!__!")
if not defined _d (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)

@REM SQR of a negative is "Illegal function call" (code 5).
if "!_d:~0,1!"=="-" (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 5
)

@REM Hand the decimal to PowerShell.  G7 fits single-precision's significand.
for /f "usebackq delims=" %%r in (`powershell -NoLogo -NoProfile -Command "([Math]::Sqrt('!_d!')).ToString('G6', [System.Globalization.CultureInfo]::InvariantCulture)"`) do set "_res=%%r"
if not defined _res (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)

call %GWSRC%\num\sng fromDec !_res!
if errorlevel 1 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
