@echo off
@REM Resolve a stack value: if it's a VAR_ token, look up its value.
@REM Otherwise return as-is.
@REM
@REM Usage: call _resolve value retVar
@REM   _resolve VAR_UNK_A __  → __ = i0064 (or default if not set)
@REM   _resolve i0064 __      → __ = i0064 (pass through)

setlocal EnableDelayedExpansion
set "_v=%~1"
if not "!_v:~0,4!"=="VAR_" goto :_res_pass
@REM FIELD live-window: if this var is registered (handle,off,width), return
@REM the current slice of that handle's record buffer.  Gated on fields.dat
@REM existing, so non-field programs pay only one `if exist` on the hot path.
if not exist "%GWTEMP%\fields.dat" goto :_res_var
call %GWSRC%\exec\_files fget !_v! _ff
if errorlevel 1 goto :_res_var
call %GWSRC%\exec\_files bufget !_ffn! _fbuf
set /a "_p=_ffoff*2"
set /a "_len=_ffwidth*2"
set "_r=STR_!_fbuf:~%_p%,%_len%!"
goto :_res_done
:_res_var
call %GWSRC%\exec\_vars get !_v! _r
goto :_res_done
:_res_pass
set "_r=!_v!"
:_res_done
endlocal & set "%~2=%_r%"
exit /B 0
