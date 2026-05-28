@echo off
@REM FN_TAN: tan(x) = sin(x) / cos(x).  Computes both via FN_SIN/FN_COS on a
@REM scratch stack, then divides.
@REM
@REM Stack: NUM_<n> → NUM_s<tan>.  Err 5 if cos(x) = 0 (asymptote).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a

set "_t=!_a:~0,1!"
set "_x="
if "!_t!"=="s" set "_x=!_a!"
if "!_t!"=="i" (call %GWSRC%\num\sng fromInt !_a! & set "_x=!__!")
if "!_t!"=="d" (
  call %GWSRC%\num\dbl toDec !_a!
  call %GWSRC%\num\sng fromDec !__!
  set "_x=!__!"
)
if not defined _x (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)

@REM sin(x) on a scratch stack.
set "_scratch=!_x!"
call %GWSRC%\rtl\FN_SIN _scratch
call %GWSRC%\stl\vec pop _scratch _sinv

@REM cos(x) on a scratch stack.
set "_scratch=!_x!"
call %GWSRC%\rtl\FN_COS _scratch
call %GWSRC%\stl\vec pop _scratch _cosv

@REM Guard against cos ≈ 0.
if "!_cosv:~1,2!"=="00" (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 5
)

call %GWSRC%\num\sng div !_sinv! !_cosv!
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
