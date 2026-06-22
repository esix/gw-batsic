@echo off
@REM WIDTH: accepted but a no-op (we don't model a fixed terminal width).
@REM Pop the argument values down to WIDTH_MRK and discard them.
setlocal EnableDelayedExpansion
set "_s=%~1"
:_w_pop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_w_done
  if "!_v!"=="WIDTH_MRK" goto :_w_done
  goto :_w_pop
:_w_done
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
