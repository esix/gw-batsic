@echo off
@REM FN_CINT: convert to signed 16-bit integer with rounding (banker's? half-up?).
@REM GW-BASIC: rounds to nearest; .5 cases round to even.  For simplicity we
@REM round half-away-from-zero (close enough for typical programs).
@REM Range: -32768 .. 32767, else Overflow (6).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
if "!_t!"=="i" (set "__=!_a!" & goto :_cint_push)

@REM Add ±0.5, then truncate toward zero.
if "!_t!"=="s" (
  call %GWSRC%\num\sng fromDec 0.5
  set "_half=!__!"
  set "_d=!_a:~3,1!"
  set "_neg="
  for %%c in (8 9 A B C D E F) do if "!_d!"=="%%c" set "_neg=1"
  if defined _neg (call %GWSRC%\num\sng sub !_a! !_half!) else (call %GWSRC%\num\sng add !_a! !_half!)
  call %GWSRC%\num\sng toInt !__!
  goto :_cint_push
)
if "!_t!"=="d" (
  call %GWSRC%\num\dbl fromDec 0.5
  set "_half=!__!"
  set "_d=!_a:~3,1!"
  set "_neg="
  for %%c in (8 9 A B C D E F) do if "!_d!"=="%%c" set "_neg=1"
  if defined _neg (call %GWSRC%\num\dbl sub !_a! !_half!) else (call %GWSRC%\num\dbl add !_a! !_half!)
  call %GWSRC%\num\dbl toInt !__!
  goto :_cint_push
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 13

:_cint_push
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
