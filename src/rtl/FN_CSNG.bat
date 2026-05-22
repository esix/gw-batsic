@echo off
@REM FN_CSNG: convert numeric to single precision.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
if "!_t!"=="i" (call %GWSRC%\num\sng fromInt !_a! & goto :_csng_push)
if "!_t!"=="s" (set "__=!_a!" & goto :_csng_push)
if "!_t!"=="d" (
  @REM Go through decimal — no direct dbl→sng primitive yet.  Single has fewer
  @REM mantissa bits so we lose precision, which is the expected behavior.
  call %GWSRC%\num\dbl toDec !_a!
  call %GWSRC%\num\sng fromDec !__!
  goto :_csng_push
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 13

:_csng_push
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
