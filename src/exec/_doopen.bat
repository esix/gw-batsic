@echo off
@REM _doopen MODE CHANTOK FILETOK RECLENTOK  -> GW error code (0 ok).
@REM   MODE      O/I/A/R       (case-insensitive)
@REM   CHANTOK   numeric value tag (i/s/d) - the file number 1..255
@REM   FILETOK   STR_<hex>     - the filename
@REM   RECLENTOK numeric value tag, or the literal ONIL when omitted
@REM Resolves the args, validates, and records the handle via _files.
setlocal EnableDelayedExpansion
set "_mode=%~1" & set "_ct=%~2" & set "_ft=%~3" & set "_rt=%~4"
call %GWSRC%\exec\_resolve !_ct! _ct
call :_toInt !_ct! _chan
if "!_chan!"=="" (endlocal & exit /B 52)
if !_chan! LSS 1 (endlocal & exit /B 52)
if !_chan! GTR 255 (endlocal & exit /B 52)
call %GWSRC%\exec\_resolve !_ft! _ft
if not "!_ft:~0,4!"=="STR_" (endlocal & exit /B 64)
if "!_ft!"=="STR_" (endlocal & exit /B 64)
@REM Pass the lexer's case-correct hex straight through; re-encoding the path
@REM via `str encode` would uppercase it (lossy) and break case-sensitive
@REM filesystems and ..\.. resolution.
set "_fthex=!_ft:~4!"
set "_rl=0"
if /I not "!_rt!"=="ONIL" call :_toInt !_rt! _rl
if /I "!_mode!"=="R" if "!_rl!"=="0" set "_rl=128"
call %GWSRC%\exec\_files open !_chan! !_mode! !_rl! !_fthex!
set "_e=!ERRORLEVEL!"
endlocal & exit /B %_e%

:_toInt
  set "_v=%~1" & set "_t=!_v:~0,1!"
  if "!_t!"=="i" call %GWSRC%\num\int toDec !_v!
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & call %GWSRC%\num\int toDec !__!)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
