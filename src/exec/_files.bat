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
  @REM Releasing all handles also releases every FIELD live-window registration
  @REM and its record buffer; a stale fields.dat entry would otherwise make
  @REM _resolve intercept a later same-named ordinary variable.
  if exist "%GWTEMP%\fields.dat" del "%GWTEMP%\fields.dat"
  del "%GWTEMP%\recbuf_*.hex" >nul 2>nul
  del "%GWTEMP%\bpos_*.dat" >nul 2>nul
  exit /B 0


@REM open N MODE RECLEN HEXPATH  -> 0 ok / 53 not found / 55 already open
@REM HEXPATH is the lexer's case-correct hex of the OS path; stored verbatim
@REM and decoded (lossless) for the filesystem operations.
:open
  setlocal EnableDelayedExpansion
  set "_n=%~1" & set "_mode=%~2" & set "_rl=%~3" & set "_hp=%~4"
  call %GWSRC%\str\str decode !_hp! _path
  set "_ff=%GWTEMP%\files.dat"
  if not exist "!_ff!" type nul > "!_ff!"
  set "_dup="
  for /f "usebackq tokens=1 delims==" %%a in ("!_ff!") do if "%%a"=="!_n!" set "_dup=1"
  if defined _dup (endlocal & exit /B 55)
  if /I "!_mode!"=="I" if not exist "!_path!" (endlocal & exit /B 53)
  if /I "!_mode!"=="O" type nul > "!_path!"
  if /I "!_mode!"=="A" if not exist "!_path!" type nul > "!_path!"
  if /I "!_mode!"=="R" if not exist "!_path!" type nul > "!_path!"
  echo !_n!=!_mode! 0 !_rl! !_hp!>> "!_ff!"
  del "%GWTEMP%\bpos_!_n!.dat" >nul 2>nul
  endlocal & exit /B 0


@REM binpos N retVar  -> byte cursor for INPUT$ reads (0 if never read)
:binpos
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  set "_bp=0"
  if exist "%GWTEMP%\bpos_!_n!.dat" set /p "_bp=" < "%GWTEMP%\bpos_!_n!.dat"
  if "!_bp!"=="" set "_bp=0"
  endlocal & set "%~2=%_bp%" & exit /B 0

@REM setbinpos N OFF  -> store the byte cursor for handle N
:setbinpos
  setlocal EnableDelayedExpansion
  set "_n=%~1" & set "_off=%~2"
  > "%GWTEMP%\bpos_!_n!.dat" echo !_off!
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
  del "%GWTEMP%\bpos_!_n!.dat" >nul 2>nul
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
@REM readseq N RETHEX RETEOF — read the next sequential line of handle N
@REM (POS is the 0-based line index for INPUT-mode files), advancing POS.
@REM RETHEX = hex of the line (CR/LF stripped); RETEOF=1 if already at end.
:readseq
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  call %GWSRC%\exec\_files get !_n! _h
  if errorlevel 1 (endlocal & set "%~2=" & set "%~3=1" & exit /B 52)
  set "_hf=%TEMP%\_gwseq.hex"
  del "!_hf!" 2>nul
  certutil -encodehex "!_hpath!" "!_hf!" 12 >nul 2>nul
  set "_all="
  for /f "usebackq delims=" %%h in ("!_hf!") do set "_all=!_all!%%h"
  set "_all=!_all:a=A!"
  set "_all=!_all:b=B!"
  set "_all=!_all:c=C!"
  set "_all=!_all:d=D!"
  set "_all=!_all:e=E!"
  set "_all=!_all:f=F!"
  set "_all=!_all:0D0A=0A!"
  set "_all=!_all:0D=!"
  @REM Walk to line index _hpos.
  set "_idx=0"
  set "_lh="
  set "_got="
:_rs_walk
  if "!_all!"=="" goto :_rs_eol
  set "_b=!_all:~0,2!"
  set "_all=!_all:~2!"
  if "!_b!"=="0A" (
    if "!_idx!"=="!_hpos!" (set "_got=1" & goto :_rs_done)
    set /a "_idx+=1"
    set "_lh="
    goto :_rs_walk
  )
  set "_lh=!_lh!!_b!"
  goto :_rs_walk
:_rs_eol
  @REM end of data without a trailing newline: the buffer is the last line.
  if "!_idx!"=="!_hpos!" if defined _lh set "_got=1"
:_rs_done
  if not defined _got (endlocal & set "%~2=" & set "%~3=1" & exit /B 0)
  set /a "_np=_hpos+1"
  call %GWSRC%\exec\_files setpos !_n! !_np!
  endlocal & set "%~2=%_lh%" & set "%~3=0" & exit /B 0


@REM atEof N RETBOOL — RETBOOL=-1 if no more data, else 0.
:atEof
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  @REM If INPUT$ has been reading this handle byte-by-byte, EOF is byte-based:
  @REM true once the byte cursor has reached the file size.
  if exist "%GWTEMP%\bpos_!_n!.dat" (
    call %GWSRC%\exec\_files binpos !_n! _bp
    call %GWSRC%\exec\_files lof !_n! _sz
    if !_bp! GEQ !_sz! (endlocal & set "%~2=-1" & exit /B 0)
    endlocal & set "%~2=0" & exit /B 0
  )
  call %GWSRC%\exec\_files readseq !_n! _peek _eof
  if "!_eof!"=="1" (endlocal & set "%~2=-1" & exit /B 0)
  @REM readseq advanced POS; undo it (peek only).
  call %GWSRC%\exec\_files get !_n! _h2
  set /a "_back=_h2pos-1"
  call %GWSRC%\exec\_files setpos !_n! !_back!
  endlocal & set "%~2=0" & exit /B 0


@REM lof N RETBYTES — file size of handle N in bytes.
:lof
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  call %GWSRC%\exec\_files get !_n! _h
  if errorlevel 1 (endlocal & set "%~2=0" & exit /B 52)
  set "_sz=0"
  for %%S in ("!_hpath!") do set "_sz=%%~zS"
  endlocal & set "%~2=%_sz%" & exit /B 0
@REM ============================================================
@REM  Random-access record buffer + FIELD registry (Architecture A)
@REM  Buffer: temp/recbuf_<N>.hex = RECLEN bytes as uppercase hex (one line).
@REM  Registry: temp/fields.dat rows "KEY N OFF WIDTH" (KEY = VAR_STR_<base>).
@REM ============================================================

@REM bufinit N — create handle N's record buffer, space-filled (byte 20).
:bufinit
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  call %GWSRC%\exec\_files get !_n! _h
  if errorlevel 1 (endlocal & exit /B 52)
  set "_rl=!_hreclen!"
  if "!_rl!"=="" set "_rl=128"
  if "!_rl!"=="0" set "_rl=128"
  set "_hx="
  for /L %%i in (1,1,!_rl!) do set "_hx=!_hx!20"
  > "%GWTEMP%\recbuf_!_n!.hex" echo !_hx!
  endlocal & exit /B 0

@REM bufget N RETVAR — read handle N's buffer hex.
:bufget
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  set "_bf=%GWTEMP%\recbuf_!_n!.hex"
  set "_bx="
  if exist "!_bf!" set /p "_bx=" < "!_bf!"
  endlocal & set "%~2=%_bx%" & exit /B 0

@REM bufput N HEX — overwrite handle N's buffer hex.
:bufput
  setlocal EnableDelayedExpansion
  set "_n=%~1" & set "_hx=%~2"
  > "%GWTEMP%\recbuf_!_n!.hex" echo !_hx!
  endlocal & exit /B 0

@REM freg KEY N OFF WIDTH — register a field window (replace any existing KEY).
:freg
  setlocal EnableDelayedExpansion
  set "_k=%~1" & set "_n=%~2" & set "_o=%~3" & set "_w=%~4"
  set "_ff=%GWTEMP%\fields.dat"
  set "_tmp=%GWTEMP%\_fields.tmp"
  type nul > "!_tmp!"
  if exist "!_ff!" for /f "usebackq tokens=1*" %%a in ("!_ff!") do if /I not "%%a"=="!_k!" echo %%a %%b>> "!_tmp!"
  echo !_k! !_n! !_o! !_w!>> "!_tmp!"
  move /Y "!_tmp!" "!_ff!" >nul
  endlocal & exit /B 0

@REM fget KEY PREFIX — set <PREFIX>n/off/width from the registry; errorlevel 1 if absent.
:fget
  setlocal EnableDelayedExpansion
  set "_k=%~1"
  set "_ff=%GWTEMP%\fields.dat"
  set "_rec="
  if exist "!_ff!" for /f "usebackq tokens=1,2,3,4" %%a in ("!_ff!") do if /I "%%a"=="!_k!" set "_rec=%%b %%c %%d"
  if not defined _rec (endlocal & set "%~2n=" & exit /B 1)
  for /f "tokens=1,2,3" %%a in ("!_rec!") do (set "_rn=%%a" & set "_ro=%%b" & set "_rw=%%c")
  endlocal & set "%~2n=%_rn%" & set "%~2off=%_ro%" & set "%~2width=%_rw%" & exit /B 0

@REM fdel KEY — remove a field row (detach).  Deletes fields.dat if it empties.
:fdel
  setlocal EnableDelayedExpansion
  set "_k=%~1"
  set "_ff=%GWTEMP%\fields.dat"
  if not exist "!_ff!" (endlocal & exit /B 0)
  set "_tmp=%GWTEMP%\_fields.tmp"
  type nul > "!_tmp!"
  set "_any="
  for /f "usebackq tokens=1*" %%a in ("!_ff!") do if /I not "%%a"=="!_k!" (echo %%a %%b>> "!_tmp!" & set "_any=1")
  if defined _any (move /Y "!_tmp!" "!_ff!" >nul) else (del "!_tmp!" "!_ff!" >nul 2>nul)
  endlocal & exit /B 0
@REM filehex N RETHEX — whole file of handle N as one uppercase hex string.
:filehex
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  call %GWSRC%\exec\_files get !_n! _h
  if errorlevel 1 (endlocal & set "%~2=" & exit /B 52)
  set "_hf=%TEMP%\_gwfh.hex"
  del "!_hf!" 2>nul
  certutil -encodehex "!_hpath!" "!_hf!" 12 >nul 2>nul
  set "_all="
  for /f "usebackq delims=" %%h in ("!_hf!") do set "_all=!_all!%%h"
  set "_all=!_all:a=A!"
  set "_all=!_all:b=B!"
  set "_all=!_all:c=C!"
  set "_all=!_all:d=D!"
  set "_all=!_all:e=E!"
  set "_all=!_all:f=F!"
  endlocal & set "%~2=%_all%" & exit /B 0

@REM writehex N HEX — write HEX (bytes) to handle N's file.
:writehex
  setlocal EnableDelayedExpansion
  set "_n=%~1" & set "_hx=%~2"
  call %GWSRC%\exec\_files get !_n! _h
  if errorlevel 1 (endlocal & exit /B 52)
  set "_hf=%TEMP%\_gwwh.hex"
  > "!_hf!" echo !_hx!
  del "!_hpath!" 2>nul
  certutil -decodehex "!_hf!" "!_hpath!" >nul 2>nul
  del "!_hf!" 2>nul
  endlocal & exit /B 0
