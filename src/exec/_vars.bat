@echo off
@REM Variable storage for GW-BASIC runtime.
@REM
@REM Variables are stored in a file (temp/vars.dat), one per line:
@REM   VARNAME=taggedvalue
@REM   A%=i0064
@REM   B=s80000000
@REM   NAME$=STR_48454C4C4F
@REM
@REM Variable types are determined by:
@REM   1. Explicit suffix: A% (int), A! (sng), A# (dbl), A$ (str)
@REM   2. First letter + DEF settings (stored in _deftypes, 26 chars A-Z)
@REM   Default: all single (s)
@REM
@REM Usage:
@REM   call _vars init                    - clear all vars, reset DEF types
@REM   call _vars set VARNAME value       - store variable
@REM   call _vars get VARNAME retVar      - load variable (returns default if unset)
@REM   call _vars deftype LETTER type     - set default type for a letter range
@REM   call _vars typeof VARNAME retVar   - get type (i/s/d/str) for a variable name

if not defined GWSRC set "GWSRC=%~dp0.."
if not defined GWTEMP set "GWTEMP=%~dp0..\..\temp"

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


@REM --- init: clear vars, reset default types to all single ---
:init
  type nul > "%GWTEMP%\vars.dat"
  @REM 26 chars, one per letter A-Z. s=single (default), i=int, d=double, t=string
  set "_deftypes=ssssssssssssssssssssssssss"
  exit /B 0


@REM --- set VARNAME value: store or update a variable ---
:set
  setlocal EnableDelayedExpansion
  set "_name=%~1"
  set "_val=%~2"
  set "_vf=%GWTEMP%\vars.dat"
  @REM Remove existing entry if present
  set "_tmp=%GWTEMP%\_vars.tmp"
  type nul > "!_tmp!"
  for /f "usebackq tokens=1* delims==" %%a in ("!_vf!") do (
    if /I "%%a" neq "!_name!" echo %%a=%%b>> "!_tmp!"
  )
  @REM Add new entry
  echo !_name!=!_val!>> "!_tmp!"
  move /Y "!_tmp!" "!_vf!" >nul
  endlocal
  exit /B 0


@REM --- get VARNAME retVar: load variable value ---
@REM Returns default zero value if variable not set.
:get
  setlocal EnableDelayedExpansion
  set "_name=%~1"
  set "_val="
  set "_vf=%GWTEMP%\vars.dat"
  for /f "usebackq tokens=1* delims==" %%a in ("!_vf!") do (
    if /I "%%a"=="!_name!" set "_val=%%b"
  )
  if not defined _val (
    @REM Return default value based on variable type
    call :typeof !_name! _tp
    if "!_tp!"=="i" set "_val=i0000"
    if "!_tp!"=="s" set "_val=s00000000"
    if "!_tp!"=="d" set "_val=d0000000000000000"
    if "!_tp!"=="t" set "_val=STR_"
  )
  endlocal & set "%~2=%_val%" & exit /B 0


@REM --- del VARNAME: delete a variable ---
:del
  setlocal EnableDelayedExpansion
  set "_name=%~1"
  set "_vf=%GWTEMP%\vars.dat"
  set "_tmp=%GWTEMP%\_vars.tmp"
  type nul > "!_tmp!"
  for /f "usebackq tokens=1* delims==" %%a in ("!_vf!") do (
    if /I "%%a" neq "!_name!" echo %%a=%%b>> "!_tmp!"
  )
  move /Y "!_tmp!" "!_vf!" >nul
  endlocal
  exit /B 0


@REM --- clear: delete all variables (keep DEF settings) ---
:clear
  type nul > "%GWTEMP%\vars.dat"
  exit /B 0


@REM --- typeof VARNAME retVar: determine type from name ---
@REM Returns: i (integer), s (single), d (double), t (string)
:typeof
  setlocal EnableDelayedExpansion
  set "_name=%~1"
  @REM Check explicit suffix from lexer token name
  @REM VAR_INT_X -> i, VAR_SNG_X -> s, VAR_DBL_X -> d, VAR_STR_X -> t
  if "!_name:~0,8!"=="VAR_INT_" (endlocal & set "%~2=i" & exit /B 0)
  if "!_name:~0,8!"=="VAR_SNG_" (endlocal & set "%~2=s" & exit /B 0)
  if "!_name:~0,8!"=="VAR_DBL_" (endlocal & set "%~2=d" & exit /B 0)
  if "!_name:~0,8!"=="VAR_STR_" (endlocal & set "%~2=t" & exit /B 0)
  @REM Untyped variable: use DEF settings based on first letter
  @REM Extract the actual name (after VAR_UNK_)
  set "_n=!_name!"
  if "!_name:~0,8!"=="VAR_UNK_" set "_n=!_name:~8!"
  @REM First letter -> position in _deftypes (A=0, B=1, ..., Z=25)
  set "_fl=!_n:~0,1!"
  set "_abc=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  set "_pos=0"
  set "_tp=s"
  for /L %%j in (0,1,25) do (
    if /I "!_fl!"=="!_abc:~%%j,1!" (
      for %%p in (%%j) do set "_tp=!_deftypes:~%%p,1!"
    )
  )
  endlocal & set "%~2=%_tp%" & exit /B 0


@REM --- defrange startLetter endLetter type: set DEF type for letter range ---
@REM Used by DEFINT, DEFSNG, DEFDBL, DEFSTR
@REM Example: call _vars defrange A M i  (DEFINT A-M)
:defrange
  setlocal EnableDelayedExpansion
  set "_from=%~1"
  set "_to=%~2"
  set "_tp=%~3"
  set "_abc=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  set "_start=0"
  set "_end=25"
  @REM Find positions
  for /L %%j in (0,1,25) do (
    if /I "!_from!"=="!_abc:~%%j,1!" set "_start=%%j"
    if /I "!_to!"=="!_abc:~%%j,1!" set "_end=%%j"
  )
  @REM Update _deftypes: replace chars from _start to _end with _tp
  set "_new="
  for /L %%j in (0,1,25) do (
    set "_inrange="
    if %%j GEQ !_start! if %%j LEQ !_end! set "_inrange=1"
    if defined _inrange (
      set "_new=!_new!!_tp!"
    ) else (
      set "_new=!_new!!_deftypes:~%%j,1!"
    )
  )
  endlocal & set "_deftypes=%_new%"
  exit /B 0


@REM --- dump: show all variables and DEF settings ---
:dump
  setlocal EnableDelayedExpansion
  echo --- Variables ---
  set "_vf=%GWTEMP%\vars.dat"
  set /a "_c=0"
  for /f "usebackq delims=" %%a in ("!_vf!") do (
    echo   %%a
    set /a "_c+=1"
  )
  if !_c!==0 echo   (none)
  echo --- DEF types (A-Z) ---
  echo   !_deftypes!
  endlocal
  exit /B 0


:_start
  call :init
  call :dump
