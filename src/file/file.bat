@echo off
@REM File I/O for GW-BASIC programs.
@REM
@REM Phase 1: ASCII text format only. One program line per file line, exactly
@REM as `LIST` outputs (numbered lines, sorted).
@REM
@REM Usage:
@REM   call file load PATH      - read PATH into _program (replaces current program)
@REM   call file save PATH      - write current _program to PATH
@REM
@REM Phase 2 (later) will add binary `.BAS` detection on load and produce
@REM tokenized binary on save by default.

if not defined GWSRC set "GWSRC=%~dp0.."
if not defined GWTEMP set "GWTEMP=%~dp0..\..\temp"

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


@REM --- load PATH: read file, detect format, populate _program ---
@REM
@REM ASCII source files: encode the WHOLE file to hex via certutil, then split
@REM on line endings (0D0A / 0A) at the hex level.  Each per-line hex string
@REM is handed straight to the lexer, bypassing CMD's argument quoting —
@REM otherwise `"` and `^` in source get mangled by each `call` along the way.
:load
  setlocal EnableDelayedExpansion
  set "_path=%~1"
  if not exist "!_path!" (echo File not found: !_path! 1>&2 & endlocal & exit /B 1)
  @REM Replace the current program — unless merging (CHAIN MERGE overlays the
  @REM file's lines onto the current program; same-numbered lines overwrite).
  if not defined _mergemode call %GWSRC%\exec\_program init
  if defined _mergemode if not "!_mergedel!"=="" call :_mergeDelete !_mergedel!
  @REM Detect tokenized binary (first byte 0xFF) vs plain ASCII.  MERGE requires
  @REM an ASCII source, so skip the binary path when merging.
  if not defined _mergemode (
    call %GWSRC%\file\_binary isBinary "!_path!"
    if not errorlevel 1 (
      call %GWSRC%\file\_binary detokenize "!_path!"
      endlocal
      exit /B 0
    )
  )
  @REM ASCII path: encode to hex first, then split on line boundaries.
  set "_hf=%TEMP%\_gwbas_loadasc.hex"
  del "!_hf!" 2>nul
  certutil -encodehex "!_path!" "!_hf!" 12 >nul 2>nul
  if errorlevel 1 (echo Cannot read: !_path! 1>&2 & endlocal & exit /B 1)
  @REM Concatenate all hex into one stream (uppercase).
  set "_all="
  for /f "usebackq delims=" %%h in ("!_hf!") do set "_all=!_all!%%h"
  set "_all=!_all:a=A!"
  set "_all=!_all:b=B!"
  set "_all=!_all:c=C!"
  set "_all=!_all:d=D!"
  set "_all=!_all:e=E!"
  set "_all=!_all:f=F!"
  @REM Normalize CRLF → LF: replace "0D0A" with "0A".  Drop trailing CR ("0D")
  @REM in case the file ends without a final LF.
  set "_all=!_all:0D0A=0A!"
  set "_all=!_all:0D=!"
  @REM Walk lines (delimited by hex "0A").
:_load_line
  if "!_all!"=="" goto :_load_done
  set "_lh="
  set "_rest=!_all!"
:_load_split
  if "!_rest!"=="" goto :_load_doline
  set "_b=!_rest:~0,2!"
  set "_rest=!_rest:~2!"
  if "!_b!"=="0A" goto :_load_doline
  @REM Ctrl-Z (CP/M-style EOF marker): finish this line, then stop -
  @REM vintage .bas files are often ^Z-terminated and NUL-padded.
  if "!_b!"=="1A" (set "_ldEof=1" & goto :_load_doline)
  set "_lh=!_lh!!_b!"
  goto :_load_split
:_load_doline
  set "_all=!_rest!"
  if "!_lh!"=="" (
    if defined _ldEof goto :_load_done
    goto :_load_line
  )
  @REM Lex the line's hex; emits a token stream.  Only store if it starts
  @REM with a line-number token (LN__nnn).
  call %GWSRC%\lexer\lexer ParseTxt !_lh! _tokens
  set "_first="
  for /f "tokens=1*" %%a in ("!_tokens!") do set "_first=%%a"
  if "!_first:~0,4!"=="LN__" call %GWSRC%\exec\_program add !_first:~4! "!_tokens!"
  if defined _ldEof goto :_load_done
  goto :_load_line
:_load_done
  endlocal
  exit /B 0


@REM --- loadmerge PATH [lo hi]: overlay PATH's lines onto the current program
@REM (CHAIN MERGE), optionally deleting line range lo..hi first.  Same line
@REM parsing as :load, but additive (no _program init). ---
:loadmerge
  setlocal EnableDelayedExpansion
  set "_mergemode=1"
  set "_mergedel=%~2"
  call %GWSRC%\file\file load "%~1"
  set "_r=!ERRORLEVEL!"
  endlocal & exit /B %_r%

@REM --- _mergeDelete lo hi: drop program lines whose number is in [lo,hi] ---
:_mergeDelete
  set "_dlo=00000%~1" & set "_dlo=!_dlo:~-5!"
  set "_dhi=00000%~2" & set "_dhi=!_dhi:~-5!"
  set "_mpf=%GWTEMP%\program.dat"
  set "_mtmp=%GWTEMP%\_merge.tmp"
  type nul > "!_mtmp!"
  for /f "usebackq tokens=1,* delims= " %%a in ("!_mpf!") do (
    set "_keep=1"
    if not "%%a" LSS "!_dlo!" if not "%%a" GTR "!_dhi!" set "_keep="
    if defined _keep echo %%a %%b>> "!_mtmp!"
  )
  move /Y "!_mtmp!" "!_mpf!" >nul
  exit /B 0


@REM --- save PATH [A]: write current program to PATH ---
@REM Default: tokenized binary `.BAS` (matches `SAVE "name"` in GW-BASIC).
@REM Pass "A" as second arg for ASCII listing (matches `SAVE "name",A`).
:save
  setlocal EnableDelayedExpansion
  set "_path=%~1"
  set "_mode=%~2"
  if /I "!_mode!"=="A" goto :_save_ascii
  call %GWSRC%\file\_binary tokenize "!_path!"
  endlocal
  exit /B 0
:_save_ascii
  type nul > "!_path!"
  for /f "usebackq tokens=1,* delims= " %%a in (`sort "%GWTEMP%\program.dat"`) do (
    call %GWSRC%\lexer\unlexer print "%%b" >> "!_path!"
  )
  endlocal
  exit /B 0


:_start
  echo file.bat - GW-BASIC program file I/O
