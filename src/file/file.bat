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
:load
  setlocal EnableDelayedExpansion
  set "_path=%~1"
  if not exist "!_path!" (echo File not found: !_path! 1>&2 & endlocal & exit /B 1)
  @REM Clear existing program; loaded lines replace it.
  call %GWSRC%\exec\_program init
  @REM Detect tokenized binary (first byte 0xFF) vs plain ASCII.
  call %GWSRC%\file\_binary isBinary "!_path!"
  if not errorlevel 1 (
    call %GWSRC%\file\_binary detokenize "!_path!"
    endlocal
    exit /B 0
  )
  for /f "usebackq delims=" %%L in ("!_path!") do call :_loadLine "%%L"
  endlocal
  exit /B 0

:_loadLine
  setlocal EnableDelayedExpansion
  call %GWSRC%\str\str encode "%~1" _h
  call %GWSRC%\lexer\lexer ParseTxt !_h! _tokens
  set "_first="
  for /f "tokens=1*" %%a in ("!_tokens!") do set "_first=%%a"
  @REM Only store lines that start with a line number — silently skip anything else.
  if "!_first:~0,4!"=="LN__" call %GWSRC%\exec\_program add !_first:~4! "!_tokens!"
  endlocal
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
