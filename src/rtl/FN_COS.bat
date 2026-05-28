@echo off
@REM FN_COS: cos(x) = sin(π/2 - x).  Delegates to FN_SIN after shifting the
@REM argument, so all the range-reduction / Taylor logic lives in one place.
@REM
@REM Stack: NUM_<n> → NUM_s<cos>.
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

@REM arg = π/2 - x
call %GWSRC%\num\sng fromDec 1.570796
call %GWSRC%\num\sng sub !__! !_x!
set "_arg=!__!"

@REM Push arg and let FN_SIN do the work (it pops, computes, pushes result).
call %GWSRC%\stl\vec push %_s% !_arg!
call %GWSRC%\rtl\FN_SIN %_s%
set "_e=!ERRORLEVEL!"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B %_e%
