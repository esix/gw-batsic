@echo off
@REM COLOR [fg][,bg][,border] - set text attributes via ANSI SGR.  Args sit
@REM between a COL_MARK sentinel and this action; each slot is a value or
@REM COL_NIL (elided).  GW/CGA colour numbers are remapped to ANSI:
@REM   fg 0-31 (16-31 = blinking), bg 0-15, border ignored.
@REM CGA index -> ANSI base colour (CGA orders colours differently):
@REM   0 blk  1 blu  2 grn  3 cyn  4 red  5 mag  6 brn  7 wht
@REM   ANSI:  0      4      2      6      1      5      3      7
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_map=04261537"
set "_rev="
:_pop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_popdone
  if "!_v!"=="COL_MARK" goto :_popdone
  set "_rev=!_rev! !_v!"
  goto :_pop
:_popdone
@REM Flip reversed args (argN..arg1) to positional order.
set "_args="
for %%a in (!_rev!) do set "_args=%%a !_args!"
set "_fg=" & set "_bg=" & set "_i=0"
for %%a in (!_args!) do (
  set /a "_i+=1"
  set "_av=%%a"
  if not "!_av!"=="COL_NIL" (
    call %GWSRC%\exec\_resolve !_av! _rv
    call :_toint !_rv! _iv
    if "!_i!"=="1" set "_fg=!_iv!"
    if "!_i!"=="2" set "_bg=!_iv!"
  )
)
set "_codes="
@REM --- foreground (0-31; 16-31 blinks) ---
if defined _fg (
  if !_fg! GEQ 0 if !_fg! LEQ 31 (
    set /a "_fv=_fg"
    set "_blink="
    if !_fv! GEQ 16 (set "_blink=1" & set /a "_fv-=16")
    set "_brt="
    if !_fv! GEQ 8 (set "_brt=1" & set /a "_fv-=8")
    for %%i in (!_fv!) do set "_base=!_map:~%%i,1!"
    if defined _brt (set "_fc=9!_base!") else (set "_fc=3!_base!")
    set "_codes=!_fc!"
    if defined _blink (set "_codes=!_codes!;5") else (set "_codes=!_codes!;25")
  )
)
@REM --- background (0-15) ---
if defined _bg (
  if !_bg! GEQ 0 if !_bg! LEQ 15 (
    set /a "_bv=_bg"
    set "_bbrt="
    if !_bv! GEQ 8 (set "_bbrt=1" & set /a "_bv-=8")
    for %%i in (!_bv!) do set "_bbase=!_map:~%%i,1!"
    if defined _bbrt (set "_bc=10!_bbase!") else (set "_bc=4!_bbase!")
    if defined _codes (set "_codes=!_codes!;!_bc!") else (set "_codes=!_bc!")
  )
)
if defined _codes (
  call :_strhex "!_codes!" _ch
  set "_hx=1B5B!_ch!6D"
  >"%TEMP%\_col.hex" echo !_hx!
  del "%TEMP%\_col.bin" 2>nul
  certutil -decodehex "%TEMP%\_col.hex" "%TEMP%\_col.bin" >nul
  type "%TEMP%\_col.bin"
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_toint
  set "_v=%~1"
  set "_t=!_v:~0,1!"
  if "!_t!"=="i" (call %GWSRC%\num\int toDec !_v! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  set "%~2=0"
  exit /B 0

@REM _strhex STR retVar: ASCII-hex of a string of [0-9;] (digit d -> "3d", ; -> 3B).
:_strhex
  set "_t=%~1"
  set "_h="
:_sh
  if "!_t!"=="" (set "%~2=!_h!" & exit /B 0)
  set "_c=!_t:~0,1!"
  set "_t=!_t:~1!"
  if "!_c!"==";" (set "_h=!_h!3B") else (set "_h=!_h!3!_c!")
  goto :_sh
