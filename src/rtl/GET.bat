@echo off
@REM GET [#]n[, rec] : read record `rec` (1-based; default = current+1) of the
@REM random file on handle n into its record buffer, via whole-file-hex seek.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _rec
call %GWSRC%\stl\vec pop %_s% _handle
call %GWSRC%\exec\_resolve !_handle! _handle
call :_toInt !_handle! _n
call %GWSRC%\exec\_files get !_n! _h
if errorlevel 1 (endlocal & set "%~1=!%_s%!" & exit /B 52)
set "_r="
if /I "!_rec!"=="ONIL" (set /a "_r=_hpos+1") else (call %GWSRC%\exec\_resolve !_rec! _rec & call :_toInt !_rec! _r)
call %GWSRC%\exec\_files filehex !_n! _all
set /a "_off=(_r-1)*_hreclen*2"
set /a "_len=_hreclen*2"
set "_slice=!_all:~%_off%,%_len%!"
@REM pad short/EOF reads with spaces (20) to a full record
:_get_pad
  call :_hexlen2 "!_slice!" _sl
  set /a "_have=_sl*2"
  if !_have! LSS !_len! (set "_slice=!_slice!20" & goto :_get_pad)
call %GWSRC%\exec\_files bufput !_n! !_slice!
call %GWSRC%\exec\_files setpos !_n! !_r!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_hexlen2
  setlocal EnableDelayedExpansion
  set "_hl=%~1" & set /a "_n2=0"
:_hl2
  if not "!_hl!"=="" (set "_hl=!_hl:~2!" & set /a "_n2+=1" & goto :_hl2)
  endlocal & set "%~2=%_n2%" & exit /B 0

:_toInt
  set "_tiv=%~1" & set "_tit=!_tiv:~0,1!"
  if "!_tit!"=="i" call %GWSRC%\num\int toDec !_tiv!
  if "!_tit!"=="s" (call %GWSRC%\num\sng toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  if "!_tit!"=="d" (call %GWSRC%\num\dbl toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
