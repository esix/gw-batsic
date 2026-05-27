@echo off
@REM FN_TIMER: GW-BASIC TIMER builtin — seconds since midnight as a single.
@REM Stack: → result (NUM_s<MBF>).
setlocal EnableDelayedExpansion
set "_s=%~1"

@REM Parse %TIME% ("HH:MM:SS.cc").  Use the `1XX-100` trick to avoid octal
@REM interpretation of leading-zero fields (e.g. "08", "09").
set "_tm=%TIME%"
set "_h=!_tm:~0,2!"
set "_m=!_tm:~3,2!"
set "_sec=!_tm:~6,2!"
@REM Treat empty leading-space form ("space digit") same as "0digit".
if "!_h:~0,1!"==" " set "_h=0!_h:~1,1!"
set /a "_total=(1!_h! - 100) * 3600 + (1!_m! - 100) * 60 + (1!_sec! - 100)"

call %GWSRC%\num\sng fromDec !_total!
if errorlevel 1 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
