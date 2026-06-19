@echo off
@REM LOCATE [row][,col][,cursor][,start][,stop] - position the cursor and/or
@REM toggle cursor visibility via ANSI escapes.  Arguments sit between a
@REM LOC_MARK sentinel and this action; each slot is a value or LOC_NIL.
@REM   row+col -> ESC[r;cH    row only -> ESC[r d (VPA)    col only -> ESC[c G (CHA)
@REM   cursor 0 -> hide (ESC[?25l), nonzero -> show (ESC[?25h)
@REM start/stop scanlines have no terminal meaning and are ignored.
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_rev="
:_pop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_popdone
  if "!_v!"=="LOC_MARK" goto :_popdone
  set "_rev=!_rev! !_v!"
  goto :_pop
:_popdone
@REM _rev holds args in reverse (argN..arg1); flip to positional order.
set "_args="
for %%a in (!_rev!) do set "_args=%%a !_args!"
set "_row=" & set "_col=" & set "_cur="
set "_i=0"
for %%a in (!_args!) do (
  set /a "_i+=1"
  set "_av=%%a"
  if not "!_av!"=="LOC_NIL" (
    call %GWSRC%\exec\_resolve !_av! _rv
    call :_toint !_rv! _iv
    if "!_i!"=="1" set "_row=!_iv!"
    if "!_i!"=="2" set "_col=!_iv!"
    if "!_i!"=="3" set "_cur=!_iv!"
  )
)
@REM Drop out-of-range positions (GW would error; we just skip them).
if defined _row if !_row! LSS 1 set "_row="
if defined _col if !_col! LSS 1 set "_col="
set "_hx="
if defined _row (
  if defined _col (
    call :_dechex !_row! _rh
    call :_dechex !_col! _ch
    set "_hx=1B5B!_rh!3B!_ch!48"
  ) else (
    call :_dechex !_row! _rh
    set "_hx=1B5B!_rh!64"
  )
) else (
  if defined _col (
    call :_dechex !_col! _ch
    set "_hx=1B5B!_ch!47"
  )
)
if defined _cur (
  if "!_cur!"=="0" (set "_hx=!_hx!1B5B3F32356C") else (set "_hx=!_hx!1B5B3F323568")
)
if defined _hx (
  >"%TEMP%\_loc.hex" echo !_hx!
  del "%TEMP%\_loc.bin" 2>nul
  certutil -decodehex "%TEMP%\_loc.hex" "%TEMP%\_loc.bin" >nul
  type "%TEMP%\_loc.bin"
)
if not defined _print_col set "_print_col=0"
if defined _col set /a "_print_col=_col-1"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_print_col=%_print_col%" & exit /B 0

:_toint
  set "_v=%~1"
  set "_t=!_v:~0,1!"
  if "!_t!"=="i" (call %GWSRC%\num\int toDec !_v! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  set "%~2=0"
  exit /B 0

@REM _dechex DEC retVar: ASCII-hex of a decimal string ("23" -> "3233").
:_dechex
  set "_d=%~1"
  set "_o="
:_dh
  if "!_d!"=="" (set "%~2=!_o!" & exit /B 0)
  set "_o=!_o!3!_d:~0,1!"
  set "_d=!_d:~1!"
  goto :_dh
