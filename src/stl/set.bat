@echo off
@REM Set: unordered collection of unique space-separated values
@REM
@REM Data is stored in a named env var as a space-separated string.
@REM All operations take the variable NAME (not value) as first arg.
@REM
@REM Usage:
@REM   set "s="
@REM   call set add s A             -> s = "A"
@REM   call set add s B             -> s = "A B"
@REM   call set add s A             -> s = "A B" (no dup, errorlevel 1)
@REM   call set has s A             -> errorlevel 0
@REM   call set has s C             -> errorlevel 1
@REM   call set remove s A          -> s = "B"
@REM   call set size s __           -> __ = "1"
@REM   call set union s t dest      -> dest = s ∪ t
@REM   call set intersect s t dest  -> dest = s ∩ t
@REM   call set equal s t           -> errorlevel 0 if same elements

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


@REM --- add setName value ---
@REM Returns 0 if added, 1 if already exists.
:add
  setlocal EnableDelayedExpansion
  set "_s=!%~1!"
  if "!_s!"=="" (endlocal & set "%~1=%~2" & exit /B 0)
  for %%a in (!_s!) do if "%%a"=="%~2" (endlocal & exit /B 1)
  endlocal & set "%~1=%_s% %~2" & exit /B 0


@REM --- has setName value ---
@REM Returns 0 if found, 1 if not.
:has
  setlocal EnableDelayedExpansion
  set "_s=!%~1!"
  for %%a in (!_s!) do if "%%a"=="%~2" (endlocal & exit /B 0)
  endlocal & exit /B 1


@REM --- remove setName value ---
@REM Returns 0 if removed, 1 if not found.
:remove
  setlocal EnableDelayedExpansion
  set "_s=!%~1!"
  set "_r="
  set "_found="
  for %%a in (!_s!) do (
    if "%%a"=="%~2" (
      set "_found=1"
    ) else (
      if "!_r!"=="" (set "_r=%%a") else (set "_r=!_r! %%a")
    )
  )
  if defined _found (endlocal & set "%~1=%_r%" & exit /B 0)
  endlocal & exit /B 1


@REM --- size setName retVar ---
:size
  setlocal EnableDelayedExpansion
  set "_s=!%~1!"
  set /a "_c=0"
  for %%a in (!_s!) do set /a "_c+=1"
  endlocal & set "%~2=%_c%" & exit /B 0


@REM --- clear setName ---
:clear
  set "%~1="
  exit /B 0


@REM --- union setA setB destSet ---
@REM dest = A ∪ B
:union
  setlocal EnableDelayedExpansion
  set "_a=!%~1!"
  set "_b=!%~2!"
  set "_r=!_a!"
  for %%x in (!_b!) do (
    set "_dup="
    for %%y in (!_r!) do if "%%y"=="%%x" set "_dup=1"
    if not defined _dup (
      if "!_r!"=="" (set "_r=%%x") else (set "_r=!_r! %%x")
    )
  )
  endlocal & set "%~3=%_r%" & exit /B 0


@REM --- intersect setA setB destSet ---
@REM dest = A ∩ B
:intersect
  setlocal EnableDelayedExpansion
  set "_a=!%~1!"
  set "_b=!%~2!"
  set "_r="
  for %%x in (!_a!) do (
    for %%y in (!_b!) do if "%%x"=="%%y" (
      set "_dup="
      for %%z in (!_r!) do if "%%z"=="%%x" set "_dup=1"
      if not defined _dup (
        if "!_r!"=="" (set "_r=%%x") else (set "_r=!_r! %%x")
      )
    )
  )
  endlocal & set "%~3=%_r%" & exit /B 0


@REM --- diff setA setB destSet ---
@REM dest = A \ B (elements in A not in B)
:diff
  setlocal EnableDelayedExpansion
  set "_a=!%~1!"
  set "_b=!%~2!"
  set "_r="
  for %%x in (!_a!) do (
    set "_found="
    for %%y in (!_b!) do if "%%x"=="%%y" set "_found=1"
    if not defined _found (
      if "!_r!"=="" (set "_r=%%x") else (set "_r=!_r! %%x")
    )
  )
  endlocal & set "%~3=%_r%" & exit /B 0


@REM --- equal setA setB ---
@REM Returns 0 if same elements, 1 otherwise.
:equal
  setlocal EnableDelayedExpansion
  set "_a=!%~1!"
  set "_b=!%~2!"
  set /a "_sa=0"
  set /a "_sb=0"
  for %%x in (!_a!) do set /a "_sa+=1"
  for %%x in (!_b!) do set /a "_sb+=1"
  if !_sa! neq !_sb! (endlocal & exit /B 1)
  for %%x in (!_a!) do (
    set "_found="
    for %%y in (!_b!) do if "%%x"=="%%y" set "_found=1"
    if not defined _found (endlocal & exit /B 1)
  )
  endlocal & exit /B 0


:_start
echo set.bat - set data structure
