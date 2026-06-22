@echo off
@REM File-handle table for OPEN / CLOSE / PRINT# / INPUT# / GET / PUT.
@REM Storage: temp/files.dat, one line per open handle:
@REM   N=MODE POS RECLEN HEXPATH       (space-delimited value)
@REM     N        file number 1..255 (the key, before '=')
@REM     MODE     O output / I input / A append / R random
@REM     POS      byte offset (sequential) or current record (random), 0-based
@REM     RECLEN   record length (random) else 0
@REM     HEXPATH  hex-encoded OS path (str encode) so spaces/&/|/<> survive
@REM   Fields are space-delimited; MODE/POS/RECLEN/HEXPATH never contain
@REM   spaces, so a space is a safe field separator.
@REM
@REM Ops: init|clear|closeall, open, close, isopen, get, setpos.

if not defined GWTEMP set "GWTEMP=%~dp0..\..\temp"
if "%~1"=="" exit /B 0
set "_ffn=%~1"
shift
goto :%_ffn%


:init
:clear
:closeall
  type nul > "%GWTEMP%\files.dat"
  exit /B 0


@REM open N MODE RECLEN "REALPATH"  -> 0 ok / 53 not found / 55 already open
:open
  setlocal EnableDelayedExpansion
  set "_n=%~1" & set "_mode=%~2" & set "_rl=%~3" & set "_path=%~4"
  set "_ff=%GWTEMP%\files.dat"
  if not exist "!_ff!" type nul > "!_ff!"
  set "_dup="
  for /f "usebackq tokens=1 delims==" %%a in ("!_ff!") do if "%%a"=="!_n!" set "_dup=1"
  if defined _dup (endlocal & exit /B 55)
  if /I "!_mode!"=="I" if not exist "!_path!" (endlocal & exit /B 53)
  if /I "!_mode!"=="O" type nul > "!_path!"
  if /I "!_mode!"=="A" if not exist "!_path!" type nul > "!_path!"
  if /I "!_mode!"=="R" if not exist "!_path!" type nul > "!_path!"
  call %GWSRC%\str\str encode "!_path!" _hp
  echo !_n!=!_mode! 0 !_rl! !_hp!>> "!_ff!"
  endlocal & exit /B 0


@REM close N  (silently ok if not open)
:close
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  set "_ff=%GWTEMP%\files.dat"
  if not exist "!_ff!" (endlocal & exit /B 0)
  set "_tmp=%GWTEMP%\_files.tmp"
  type nul > "!_tmp!"
  for /f "usebackq tokens=1* delims==" %%a in ("!_ff!") do if "%%a" neq "!_n!" echo %%a=%%b>> "!_tmp!"
  move /Y "!_tmp!" "!_ff!" >nul
  endlocal & exit /B 0


@REM isopen N  -> errorlevel 0 if open, 1 if not
:isopen
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  set "_ff=%GWTEMP%\files.dat"
  set "_found="
  if exist "!_ff!" for /f "usebackq tokens=1 delims==" %%a in ("!_ff!") do if "%%a"=="!_n!" set "_found=1"
  if defined _found (endlocal & exit /B 0)
  endlocal & exit /B 1


@REM get N PREFIX  -> sets <PREFIX>mode/pos/reclen/path ; 52 if not open
:get
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  set "_ff=%GWTEMP%\files.dat"
  set "_rec="
  if exist "!_ff!" for /f "usebackq tokens=1* delims==" %%a in ("!_ff!") do if "%%a"=="!_n!" set "_rec=%%b"
  if not defined _rec (endlocal & exit /B 52)
  for /f "tokens=1-4" %%m in ("!_rec!") do (
    set "_m=%%m" & set "_p=%%n" & set "_r=%%o" & set "_hp=%%p"
  )
  call %GWSRC%\str\str decode !_hp! _rp
  endlocal & set "%~2mode=%_m%" & set "%~2pos=%_p%" & set "%~2reclen=%_r%" & set "%~2path=%_rp%" & exit /B 0


@REM setpos N POS  -> update the POS field of handle N
:setpos
  setlocal EnableDelayedExpansion
  set "_n=%~1" & set "_np=%~2"
  set "_ff=%GWTEMP%\files.dat"
  if not exist "!_ff!" (endlocal & exit /B 52)
  @REM Read the existing record first (a nested for inside the rewrite loop
  @REM mis-parses on the cmd port), then rewrite with the new POS.
  set "_rec="
  for /f "usebackq tokens=1* delims==" %%a in ("!_ff!") do if "%%a"=="!_n!" set "_rec=%%b"
  if not defined _rec (endlocal & exit /B 52)
  for /f "tokens=1-4" %%m in ("!_rec!") do (set "_m=%%m" & set "_r=%%o" & set "_hp=%%p")
  set "_tmp=%GWTEMP%\_files.tmp"
  type nul > "!_tmp!"
  for /f "usebackq tokens=1* delims==" %%a in ("!_ff!") do (
    if "%%a"=="!_n!" (echo %%a=!_m! !_np! !_r! !_hp!>> "!_tmp!") else (echo %%a=%%b>> "!_tmp!")
  )
  move /Y "!_tmp!" "!_ff!" >nul
  endlocal & exit /B 0
