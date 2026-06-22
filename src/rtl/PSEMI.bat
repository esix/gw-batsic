@echo off
@REM PSEMI: semicolon separator in PRINT — pop value, print, no newline,
@REM no padding.  Advances _print_col by the printed length.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
@REM Force-clear `_hex` — it might be inherited from caller scope (e.g. the
@REM test harness encodes its source line into `_hex` for lex/parse).
set "_hex="
set "_txt="
set "_isStr="
if "!_a:~0,4!"=="STR_" (
  set "_isStr=1"
  if not "!_a!"=="STR_" (
    set "_hex=!_a:~4!"
    @REM Decode into _txt for length counting; print path uses decodePrint
    @REM so `!`/`=`/etc. don't get mangled.
    call %GWSRC%\str\str decode !_hex! _txt
  )
) else (
  set "_tp=!_a:~0,1!"
  if "!_tp!"=="i" (call %GWSRC%\num\int toDec !_a! & set "_txt= !__!")
  if "!_tp!"=="s" (call %GWSRC%\num\sng toDec !_a! & set "_txt= !__!")
  if "!_tp!"=="d" (call %GWSRC%\num\dbl toDec !_a! & set "_txt= !__!")
)
if defined _isStr (
  if defined _hex call %GWSRC%\str\str decodePrint !_hex! NONL
) else (
  @REM Numeric: `_txt` is safe (digits/space/sign).  Sacrificial var name `_`
  @REM so a leading `=` would not break `set /p` (defensive — numbers won't
  @REM produce one in practice).
  if defined _txt if defined _print_path (call %GWSRC%\exec\_pemit "!_txt!" NONL) else (<nul set /p "_=!_txt!")
)
if not defined _print_col set "_print_col=0"
if defined _isStr (
  @REM Length from hex (2 hex chars = 1 byte); `_txt` may have lost `!`s.
  call :_len "!_hex!" _added
  set /a "_added/=2"
) else (
  call :_len "!_txt!" _added
)
set /a "_print_col+=_added"
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
