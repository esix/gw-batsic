@echo off
@REM Program storage for GW-BASIC lines.
@REM
@REM Lines stored in temp/program.dat, one per line:
@REM   NNNNN TOKENS...
@REM where NNNNN is a 5-digit zero-padded line number (for lexicographic ==
@REM numeric sort) and TOKENS is the lexer's space-separated token list
@REM for that line (LN__ and EOL included).
@REM
@REM LIST uses the unlexer to render tokens back to text.
@REM
@REM Usage:
@REM   call _program init              - clear program
@REM   call _program add NUM "TOKENS"  - insert or replace a line
@REM   call _program del NUM           - delete a line
@REM   call _program list              - print all lines sorted by number
@REM   call _program get NUM retVar    - return tokens for line NUM (empty if absent)

if not defined GWSRC set "GWSRC=%~dp0.."
if not defined GWTEMP set "GWTEMP=%~dp0..\..\temp"

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:init
  type nul > "%GWTEMP%\program.dat"
  exit /B 0

:clear
  type nul > "%GWTEMP%\program.dat"
  exit /B 0


@REM --- add NUM "TOKENS": insert or replace a program line ---
:add
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  set "_tk=%~2"
  set "_key=00000!_n!"
  set "_key=!_key:~-5!"
  set "_pf=%GWTEMP%\program.dat"
  set "_tmp=%GWTEMP%\_program.tmp"
  type nul > "!_tmp!"
  for /f "usebackq tokens=1,* delims= " %%a in ("!_pf!") do (
    if "%%a" neq "!_key!" echo %%a %%b>> "!_tmp!"
  )
  echo !_key! !_tk!>> "!_tmp!"
  move /Y "!_tmp!" "!_pf!" >nul
  endlocal
  exit /B 0


@REM --- del NUM: delete a program line ---
:del
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  set "_key=00000!_n!"
  set "_key=!_key:~-5!"
  set "_pf=%GWTEMP%\program.dat"
  set "_tmp=%GWTEMP%\_program.tmp"
  type nul > "!_tmp!"
  for /f "usebackq tokens=1,* delims= " %%a in ("!_pf!") do (
    if "%%a" neq "!_key!" echo %%a %%b>> "!_tmp!"
  )
  move /Y "!_tmp!" "!_pf!" >nul
  endlocal
  exit /B 0


@REM --- list: print all lines sorted by number ---
:list
  setlocal EnableDelayedExpansion
  set "_pf=%GWTEMP%\program.dat"
  for /f "usebackq tokens=1,* delims= " %%a in (`sort "!_pf!"`) do (
    call %GWSRC%\lexer\unlexer print "%%b"
  )
  endlocal
  exit /B 0


@REM --- get NUM retVar: return tokens for line NUM (empty if not found) ---
:get
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  set "_key=00000!_n!"
  set "_key=!_key:~-5!"
  set "_pf=%GWTEMP%\program.dat"
  set "_tk="
  for /f "usebackq tokens=1,* delims= " %%a in ("!_pf!") do (
    if "%%a"=="!_key!" set "_tk=%%b"
  )
  endlocal & set "%~2=%_tk%" & exit /B 0


:_start
  echo _program.bat - GW-BASIC program storage
  echo Current program:
  type "%GWTEMP%\program.dat" 2>nul
