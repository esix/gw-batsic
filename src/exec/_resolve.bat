@echo off
@REM Resolve a stack value: if it's a VAR_ token, look up its value.
@REM Otherwise return as-is.
@REM
@REM Usage: call _resolve value retVar
@REM   _resolve VAR_UNK_A __  → __ = i0064 (or default if not set)
@REM   _resolve i0064 __      → __ = i0064 (pass through)

setlocal EnableDelayedExpansion
set "_v=%~1"
if "!_v:~0,4!"=="VAR_" (
  call %GWSRC%\exec\_vars get !_v! _r
) else (
  set "_r=!_v!"
)
endlocal & set "%~2=%_r%"
exit /B 0
