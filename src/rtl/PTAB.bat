@echo off
@REM PTAB: comma separator in PRINT — pop the previous value, print it (no
@REM newline), then pad with spaces to the next 14-column tab stop.
@REM
@REM GW-BASIC PRINT zones are 14 columns wide.  Cursor column is tracked
@REM in _print_col (0-based); PEND resets it to 0.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a

@REM Render the value to its printable form.
set "_txt="
if "!_a:~0,4!"=="STR_" (
  if "!_a!"=="STR_" (set "_txt=") else (call %GWSRC%\str\str decode !_a:~4! _txt)
) else (
  set "_tp=!_a:~0,1!"
  if "!_tp!"=="i" (call %GWSRC%\num\int toDec !_a! & set "_txt= !__!")
  if "!_tp!"=="s" (call %GWSRC%\num\sng toDec !_a! & set "_txt= !__!")
  if "!_tp!"=="d" (call %GWSRC%\num\dbl toDec !_a! & set "_txt= !__!")
)
if defined _txt <nul set /p "=!_txt!"

@REM Update column counter by the printed-text length.
if not defined _print_col set "_print_col=0"
call :_len "!_txt!" _added
set /a "_print_col+=_added"

@REM Pad to next multiple of 14.  Output spaces via certutil-decodehex →
@REM type so leading whitespace survives (`<nul set /p` strips it).
set /a "_pad=14 - (_print_col %% 14)"
if !_pad! GTR 0 if !_pad! LSS 14 (
  set "_hx="
  for /L %%i in (1,1,!_pad!) do set "_hx=!_hx!20"
  >"%TEMP%\_pad.hex" echo !_hx!
  certutil -decodehex "%TEMP%\_pad.hex" "%TEMP%\_pad.bin" >nul
  type "%TEMP%\_pad.bin"
  set /a "_print_col+=_pad"
)

set "_final=!%_s%!"
endlocal ^
  & set "%~1=%_final%" ^
  & set "_print_col=%_print_col%" ^
  & exit /B 0


:_len
  setlocal EnableDelayedExpansion
  set "_v=%~1"
  set /a "_n=0"
:_len_loop
  if "!_v!"=="" (endlocal & set "%~2=%_n%" & exit /B 0)
  set /a "_n+=1"
  set "_v=!_v:~1!"
  goto :_len_loop
