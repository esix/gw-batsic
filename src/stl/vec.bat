@echo off
@REM Vector: ordered collection of space-separated values
@REM
@REM Data is stored in a named env var as a space-separated string.
@REM All operations take the variable NAME (not value) as first arg.
@REM
@REM Usage:
@REM   set "v="
@REM   call vec push v A           -> v = "A"
@REM   call vec push v B           -> v = "A B"
@REM   call vec front v __         -> __ = "A"
@REM   call vec shift v            -> v = "B"
@REM   call vec includes v B       -> errorlevel 0

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


@REM --- push vecName value ---
:push
  setlocal EnableDelayedExpansion
  set "_v=!%~1!"
  if "!_v!"=="" (
    endlocal & set "%~1=%~2" & exit /B 0
  )
  endlocal & set "%~1=%_v% %~2" & exit /B 0


@REM --- front vecName retVar ---
@REM Gets first element without removing it.
:front
  setlocal EnableDelayedExpansion
  set "_v=!%~1!"
  if "!_v!"=="" (endlocal & exit /B 1)
  for /f "tokens=1" %%a in ("!_v!") do set "_r=%%a"
  endlocal & set "%~2=%_r%" & exit /B 0


@REM --- shift vecName ---
@REM Removes first element.
:shift
  setlocal EnableDelayedExpansion
  set "_v=!%~1!"
  if "!_v!"=="" (endlocal & exit /B 1)
  for /f "tokens=1*" %%a in ("!_v!") do set "_v=%%b"
  endlocal & set "%~1=%_v%" & exit /B 0


@REM --- includes vecName value ---
@REM Returns errorlevel 0 if found, 1 if not.
:includes
  setlocal EnableDelayedExpansion
  set "_v=!%~1!"
  for %%a in (!_v!) do if "%%a"=="%~2" (endlocal & exit /B 0)
  endlocal & exit /B 1


@REM --- push_uniq vecName value ---
@REM Pushes only if not already present. Returns 0 if added, 1 if dup.
:push_uniq
  setlocal EnableDelayedExpansion
  set "_v=!%~1!"
  for %%a in (!_v!) do if "%%a"=="%~2" (endlocal & exit /B 1)
  if "!_v!"=="" (
    endlocal & set "%~1=%~2" & exit /B 0
  )
  endlocal & set "%~1=%_v% %~2" & exit /B 0


@REM --- size vecName retVar ---
:size
  setlocal EnableDelayedExpansion
  set "_v=!%~1!"
  set /a "_c=0"
  for %%a in (!_v!) do set /a "_c+=1"
  endlocal & set "%~2=%_c%" & exit /B 0


@REM --- clear vecName ---
:clear
  set "%~1="
  exit /B 0


:_start
echo vec.bat - vector data structure
