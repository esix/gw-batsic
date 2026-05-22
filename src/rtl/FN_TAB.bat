@echo off
@REM FN_TAB: TAB(n) inside a PRINT — pad with spaces to column n (1-based).
@REM Stack: NUM_i<n> → STR_  (empty sentinel so subsequent PSEMI/PTAB has
@REM something to pop).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
@REM Convert to int.
set "_t=!_a:~0,1!"
set "_n="
if "!_t!"=="i" (call %GWSRC%\num\int toDec !_a! & set "_n=!__!")
if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_a! & call %GWSRC%\num\int toDec !__! & set "_n=!__!")
if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_a! & call %GWSRC%\num\int toDec !__! & set "_n=!__!")
if not defined _n (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
if not defined _print_col set "_print_col=0"
@REM Target column is n-1 (TAB(1) means column 1 in BASIC, i.e. col index 0).
set /a "_target=_n - 1"
@REM If already past target, GW-BASIC moves to the next line then to the target.
if !_print_col! GTR !_target! (
  echo(
  set "_print_col=0"
)
set /a "_pad=_target - _print_col"
if !_pad! GTR 0 (
  set "_hx="
  for /L %%i in (1,1,!_pad!) do set "_hx=!_hx!20"
  >"%TEMP%\_tab.hex" echo !_hx!
  certutil -decodehex "%TEMP%\_tab.hex" "%TEMP%\_tab.bin" >nul
  type "%TEMP%\_tab.bin"
  set /a "_print_col+=_pad"
)
@REM Push empty STR_ sentinel so following PSEMI / PTAB has a value to pop.
call %GWSRC%\stl\vec push %_s% STR_
set "_final=!%_s%!"
endlocal ^
  & set "%~1=%_final%" ^
  & set "_print_col=%_print_col%" ^
  & exit /B 0
