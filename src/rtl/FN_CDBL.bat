@echo off
@REM FN_CDBL: convert numeric to double precision.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
if "!_t!"=="i" (call %GWSRC%\num\dbl fromInt !_a! & goto :_cdbl_push)
if "!_t!"=="s" (
  call %GWSRC%\num\sng toDec !_a!
  call %GWSRC%\num\dbl fromDec !__!
  goto :_cdbl_push
)
if "!_t!"=="d" (set "__=!_a!" & goto :_cdbl_push)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 13

:_cdbl_push
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
