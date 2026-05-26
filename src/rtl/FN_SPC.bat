@echo off
@REM FN_SPC: SPC(n) inside a PRINT — print n spaces inline.
@REM Stack: NUM_i<n> → STR_  (empty sentinel for subsequent separator).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
set "_n="
if "!_t!"=="i" (call %GWSRC%\num\int toDec !_a! & set "_n=!__!")
if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_a! & call %GWSRC%\num\int toDec !__! & set "_n=!__!")
if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_a! & call %GWSRC%\num\int toDec !__! & set "_n=!__!")
if not defined _n (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
if !_n! LSS 0 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 5
)
if not defined _print_col set "_print_col=0"
if !_n! GTR 0 (
  set "_hx="
  for /L %%i in (1,1,!_n!) do set "_hx=!_hx!20"
  >"%TEMP%\_spc.hex" echo !_hx!
  @REM certutil refuses to overwrite — clear .bin first.
  del "%TEMP%\_spc.bin" 2>nul
  certutil -decodehex "%TEMP%\_spc.hex" "%TEMP%\_spc.bin" >nul
  type "%TEMP%\_spc.bin"
  set /a "_print_col+=_n"
)
call %GWSRC%\stl\vec push %_s% STR_
set "_final=!%_s%!"
endlocal ^
  & set "%~1=%_final%" ^
  & set "_print_col=%_print_col%" ^
  & exit /B 0
