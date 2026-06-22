@echo off
@REM PUT [#]n[, rec] : write the record buffer of handle n to record `rec`
@REM (1-based; default current+1), extending the file with spaces if needed.
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
call %GWSRC%\exec\_files bufget !_n! _buf
set /a "_off=(_r-1)*_hreclen*2"
set /a "_aft=_off+_hreclen*2"
@REM extend file hex with spaces up to the record offset if short
:_put_pad
  call :_hexlen2 "!_all!" _al
  set /a "_have=_al*2"
  if !_have! LSS !_off! (set "_all=!_all!20" & goto :_put_pad)
set "_new=!_all:~0,%_off%!!_buf!!_all:~%_aft%!"
call %GWSRC%\exec\_files writehex !_n! !_new!
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
