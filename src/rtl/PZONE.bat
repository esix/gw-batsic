@echo off
@REM PZONE: empty PRINT zone - advance the cursor to the next 14-column
@REM print zone WITHOUT popping a value (leading / consecutive commas:
@REM PRINT ,X or PRINT A,,B).  Unlike PTAB there is no pending value, so
@REM when the cursor sits exactly on a zone boundary it still advances a
@REM full zone.  Spaces go through certutil-decodehex like PTAB so that
@REM leading whitespace survives.
setlocal EnableDelayedExpansion
if not defined _print_col set "_print_col=0"
set /a "_pad=14 - (_print_col %% 14)"
set "_hx="
for /L %%i in (1,1,!_pad!) do set "_hx=!_hx!20"
>"%TEMP%\_pad.hex" echo !_hx!
@REM certutil refuses to overwrite - clear .bin first.
del "%TEMP%\_pad.bin" 2>/dev/null
certutil -decodehex "%TEMP%\_pad.hex" "%TEMP%\_pad.bin" >/dev/null
type "%TEMP%\_pad.bin"
set /a "_print_col+=_pad"
endlocal & set "_print_col=%_print_col%" & exit /B 0
