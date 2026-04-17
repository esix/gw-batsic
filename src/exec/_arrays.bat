@echo off
@REM Array storage for GW-BASIC.
@REM
@REM Stored in temp/arrays.dat, one line per array:
@REM   ARR_TYPE_NAME NDIMS BOUND1 ... BOUNDN V0 V1 ... Vm
@REM where:
@REM   ARR_TYPE_NAME  — canonical name (ARR_INT_/ARR_SNG_/ARR_DBL_/ARR_STR_)
@REM   NDIMS          — number of dimensions (1..3)
@REM   BOUNDi         — upper bound, OPTION BASE 0 (so count is bound+1)
@REM   V0..Vm         — flat element values in row-major order
@REM
@REM Usage:
@REM   _arrays init                          - clear
@REM   _arrays typeof NAME retVar            - 'i'/'s'/'d'/'t' from ARR_UNK_ or explicit
@REM   _arrays exists NAME retVar            - "1" if declared
@REM   _arrays dim   NAME BOUND1 [B2 [B3]]   - declare (err 10 if already)
@REM   _arrays get   NAME IDX1 [I2 [I3]] retVar
@REM   _arrays set   NAME IDX1 [I2 [I3]] VALUE
@REM   _arrays dump
@REM
@REM Error codes: 9=Subscript out of range, 5=Illegal function call, 10=Duplicate Def.

if not defined GWSRC set "GWSRC=%~dp0.."
if not defined GWTEMP set "GWTEMP=%~dp0..\..\temp"

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:init
  type nul > "%GWTEMP%\arrays.dat"
  exit /B 0


@REM --- typeof NAME retVar ---
@REM Takes an ARR_*_X name or a VAR_*_X name (both work) and returns
@REM the type letter (i/s/d/t), using _vars' DEF letter table for UNK.
:typeof
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  if "!_n:~0,8!"=="ARR_INT_" (endlocal & set "%~2=i" & exit /B 0)
  if "!_n:~0,8!"=="ARR_SNG_" (endlocal & set "%~2=s" & exit /B 0)
  if "!_n:~0,8!"=="ARR_DBL_" (endlocal & set "%~2=d" & exit /B 0)
  if "!_n:~0,8!"=="ARR_STR_" (endlocal & set "%~2=t" & exit /B 0)
  @REM ARR_UNK_X or VAR_*_X: delegate to _vars
  if "!_n:~0,8!"=="ARR_UNK_" (
    call %GWSRC%\exec\_vars typeof VAR_UNK_!_n:~8! _tp
    goto :_typeof_ret
  )
  call %GWSRC%\exec\_vars typeof !_n! _tp
:_typeof_ret
  endlocal & set "%~2=%_tp%" & exit /B 0


@REM --- canonicalize NAME retVar (internal): ARR_UNK_X → ARR_TYP_X ---
:_canon
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  call :typeof !_n! _tp
  if "!_n:~0,8!"=="ARR_UNK_" (
    set "_base=!_n:~8!"
    if "!_tp!"=="i" set "_n=ARR_INT_!_base!"
    if "!_tp!"=="s" set "_n=ARR_SNG_!_base!"
    if "!_tp!"=="d" set "_n=ARR_DBL_!_base!"
    if "!_tp!"=="t" set "_n=ARR_STR_!_base!"
  )
  endlocal & set "%~2=%_n%" & exit /B 0


@REM --- exists NAME retVar: "1" if present in arrays.dat ---
:exists
  setlocal EnableDelayedExpansion
  call :_canon %~1 _n
  set "_r="
  for /f "usebackq tokens=1 delims= " %%a in ("%GWTEMP%\arrays.dat") do (
    if /I "%%a"=="!_n!" set "_r=1"
  )
  endlocal & set "%~2=%_r%" & exit /B 0


@REM --- dim NAME BOUND1 [B2 [B3]]: declare array ---
@REM Returns errorlevel 10 if already exists.
:dim
  setlocal EnableDelayedExpansion
  call :_canon %~1 _n
  @REM Check duplicate
  for /f "usebackq tokens=1 delims= " %%a in ("%GWTEMP%\arrays.dat") do (
    if /I "%%a"=="!_n!" (endlocal & exit /B 10)
  )
  @REM Count bounds and compute total elements
  set "_b1=%~2"
  set "_b2=%~3"
  set "_b3=%~4"
  set /a "_ndims=1"
  set /a "_count=_b1+1"
  if defined _b2 (set /a "_ndims=2" & set /a "_count=_count*(_b2+1)")
  if defined _b3 (set /a "_ndims=3" & set /a "_count=_count*(_b3+1)")
  @REM Pick default value based on type
  call :typeof !_n! _tp
  if "!_tp!"=="i" set "_zero=i0000"
  if "!_tp!"=="s" set "_zero=s00000000"
  if "!_tp!"=="d" set "_zero=d0000000000000000"
  if "!_tp!"=="t" set "_zero=STR_"
  @REM Build line: NAME NDIMS BOUNDS... VALUES...
  set "_line=!_n! !_ndims! !_b1!"
  if defined _b2 set "_line=!_line! !_b2!"
  if defined _b3 set "_line=!_line! !_b3!"
  for /L %%i in (1,1,!_count!) do set "_line=!_line! !_zero!"
  @REM Append
  echo !_line!>> "%GWTEMP%\arrays.dat"
  endlocal
  exit /B 0


@REM --- _offset NDIMS BOUNDS... INDICES... retVar ---
@REM Row-major offset for INDICES given BOUNDS. NDIMS controls how many bounds/indices.
@REM Validates: index in [0, bound]. Returns errorlevel 5 (neg) or 9 (overflow) if bad.
@REM Call: _offset ND B1 [B2 [B3]] I1 [I2 [I3]] retVar
:_offset
  setlocal EnableDelayedExpansion
  set "_nd=%~1"
  set "_b1=%~2"
  set "_off="
  set "_retV="
  if "!_nd!"=="1" goto :_off1
  if "!_nd!"=="2" goto :_off2
  if "!_nd!"=="3" goto :_off3
  endlocal & exit /B 5
:_off1
  set "_i1=%~3"
  set "_retV=%~4"
  if !_i1! LSS 0 (endlocal & exit /B 5)
  if !_i1! GTR !_b1! (endlocal & exit /B 9)
  set "_off=%~3"
  goto :_off_ret
:_off2
  set "_b2=%~3"
  set "_i1=%~4"
  set "_i2=%~5"
  set "_retV=%~6"
  if !_i1! LSS 0 (endlocal & exit /B 5)
  if !_i2! LSS 0 (endlocal & exit /B 5)
  if !_i1! GTR !_b1! (endlocal & exit /B 9)
  if !_i2! GTR !_b2! (endlocal & exit /B 9)
  set /a "_off=_i1*(_b2+1)+_i2"
  goto :_off_ret
:_off3
  set "_b2=%~3"
  set "_b3=%~4"
  set "_i1=%~5"
  set "_i2=%~6"
  set "_i3=%~7"
  set "_retV=%~8"
  if !_i1! LSS 0 (endlocal & exit /B 5)
  if !_i2! LSS 0 (endlocal & exit /B 5)
  if !_i3! LSS 0 (endlocal & exit /B 5)
  if !_i1! GTR !_b1! (endlocal & exit /B 9)
  if !_i2! GTR !_b2! (endlocal & exit /B 9)
  if !_i3! GTR !_b3! (endlocal & exit /B 9)
  set /a "_off=(_i1*(_b2+1)+_i2)*(_b3+1)+_i3"
  goto :_off_ret
:_off_ret
  endlocal & set "%_retV%=%_off%" & exit /B 0


@REM --- get NAME IDX1 [I2 [I3]] retVar ---
:get
  setlocal EnableDelayedExpansion
  call :_canon %~1 _n
  @REM Find the array line
  set "_found="
  for /f "usebackq tokens=1*" %%a in ("%GWTEMP%\arrays.dat") do (
    if /I "%%a"=="!_n!" set "_found=%%b"
  )
  if not defined _found (endlocal & exit /B 9)
  @REM Parse _found: NDIMS BOUNDS... VALUES...
  for /f "tokens=1*" %%a in ("!_found!") do (set "_nd=%%a" & set "_rest=%%b")
  @REM Extract bounds
  set "_bnds="
  set /a "_i=0"
  :_get_bnd
    if !_i! GEQ !_nd! goto :_get_bnd_done
    for /f "tokens=1*" %%a in ("!_rest!") do (set "_b=%%a" & set "_rest=%%b")
    if "!_bnds!"=="" (set "_bnds=!_b!") else (set "_bnds=!_bnds! !_b!")
    set /a "_i+=1"
    goto :_get_bnd
  :_get_bnd_done
  @REM Indices are positional; the last arg is retVar.
  set "_e=0"
  if "!_nd!"=="1" call :_offset 1 !_bnds! %~2 _off
  if "!_nd!"=="1" set "_e=!ERRORLEVEL!"
  if "!_nd!"=="2" call :_offset 2 !_bnds! %~2 %~3 _off
  if "!_nd!"=="2" set "_e=!ERRORLEVEL!"
  if "!_nd!"=="3" call :_offset 3 !_bnds! %~2 %~3 %~4 _off
  if "!_nd!"=="3" set "_e=!ERRORLEVEL!"
  if !_e! neq 0 (endlocal & exit /B !_e!)
  call :_nthToken "!_rest!" !_off! _val
  if "!_nd!"=="1" (endlocal & set "%~3=%_val%" & exit /B 0)
  if "!_nd!"=="2" (endlocal & set "%~4=%_val%" & exit /B 0)
  if "!_nd!"=="3" (endlocal & set "%~5=%_val%" & exit /B 0)
  endlocal & exit /B 5


@REM --- set NAME IDX1 [I2 [I3]] VALUE ---
:set
  setlocal EnableDelayedExpansion
  call :_canon %~1 _n
  @REM Load line
  set "_line="
  for /f "usebackq tokens=1*" %%a in ("%GWTEMP%\arrays.dat") do (
    if /I "%%a"=="!_n!" set "_line=%%b"
  )
  if not defined _line (endlocal & exit /B 9)
  for /f "tokens=1*" %%a in ("!_line!") do (set "_nd=%%a" & set "_rest=%%b")
  @REM Separate bounds and values
  set "_bnds="
  set /a "_i=0"
  :_set_bnd
    if !_i! GEQ !_nd! goto :_set_bnd_done
    for /f "tokens=1*" %%a in ("!_rest!") do (set "_b=%%a" & set "_rest=%%b")
    if "!_bnds!"=="" (set "_bnds=!_b!") else (set "_bnds=!_bnds! !_b!")
    set /a "_i+=1"
    goto :_set_bnd
  :_set_bnd_done
  @REM Compute offset per ndims; final arg is value
  set "_e=0"
  set "_val="
  if "!_nd!"=="1" call :_offset 1 !_bnds! %~2 _off
  if "!_nd!"=="1" set "_e=!ERRORLEVEL!"
  if "!_nd!"=="1" set "_val=%~3"
  if "!_nd!"=="2" call :_offset 2 !_bnds! %~2 %~3 _off
  if "!_nd!"=="2" set "_e=!ERRORLEVEL!"
  if "!_nd!"=="2" set "_val=%~4"
  if "!_nd!"=="3" call :_offset 3 !_bnds! %~2 %~3 %~4 _off
  if "!_nd!"=="3" set "_e=!ERRORLEVEL!"
  if "!_nd!"=="3" set "_val=%~5"
  if !_e! neq 0 (endlocal & exit /B !_e!)
  call :_replaceNth "!_rest!" !_off! "!_val!" _newvals
  call :_rewrite !_n! !_nd! "!_bnds!" "!_newvals!"
  endlocal & exit /B 0


@REM --- _nthToken "TOKENS" N retVar: return N-th (0-based) token ---
:_nthToken
  setlocal EnableDelayedExpansion
  set "_toks=%~1"
  set /a "_want=%~2"
  set /a "_i=0"
  set "_r="
  for %%t in (!_toks!) do (
    if !_i!==!_want! set "_r=%%t"
    set /a "_i+=1"
  )
  endlocal & set "%~3=%_r%" & exit /B 0


@REM --- _replaceNth "TOKENS" N "VALUE" retVar: replace N-th token ---
:_replaceNth
  setlocal EnableDelayedExpansion
  set "_toks=%~1"
  set /a "_pos=%~2"
  set "_val=%~3"
  set "_out="
  set /a "_i=0"
  for %%t in (!_toks!) do (
    if !_i!==!_pos! (
      if "!_out!"=="" (set "_out=!_val!") else (set "_out=!_out! !_val!")
    ) else (
      if "!_out!"=="" (set "_out=%%t") else (set "_out=!_out! %%t")
    )
    set /a "_i+=1"
  )
  endlocal & set "%~4=%_out%" & exit /B 0


@REM --- _rewrite NAME NDIMS "BOUNDS" "VALUES": replace array line in arrays.dat ---
:_rewrite
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  set "_nd=%~2"
  set "_bnds=%~3"
  set "_vals=%~4"
  set "_af=%GWTEMP%\arrays.dat"
  set "_tmp=%GWTEMP%\_arrays.tmp"
  type nul > "!_tmp!"
  for /f "usebackq tokens=1* delims= " %%a in ("!_af!") do (
    if /I "%%a"=="!_n!" (
      echo !_n! !_nd! !_bnds! !_vals!>> "!_tmp!"
    ) else (
      echo %%a %%b>> "!_tmp!"
    )
  )
  move /Y "!_tmp!" "!_af!" >nul
  endlocal & exit /B 0


@REM --- dump: print all arrays ---
:dump
  setlocal EnableDelayedExpansion
  echo --- Arrays ---
  set "_af=%GWTEMP%\arrays.dat"
  set /a "_c=0"
  for /f "usebackq delims=" %%a in ("!_af!") do (
    echo   %%a
    set /a "_c+=1"
  )
  if !_c!==0 echo   (none)
  endlocal
  exit /B 0


:_start
  call :init
  call :dump
