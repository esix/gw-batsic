@echo off
@REM WRITE: pop values down to WRITE_MRK and emit them comma-separated, with
@REM strings double-quoted and numbers with NO leading space, then a CRLF.
@REM Output goes through the print sink (PFILE_SET set _print_path for WRITE#,
@REM else console); the sink is cleared at the end.  Hex: 22=" 2C=,
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_vals="
:_w_pop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_w_done
  if "!_v!"=="WRITE_MRK" goto :_w_done
  if "!_vals!"=="" (set "_vals=!_v!") else (set "_vals=!_v! !_vals!")
  goto :_w_pop
:_w_done
set "_first=1"
for %%v in (!_vals!) do (
  if not "!_first!"=="1" call %GWSRC%\str\str decodePrint 2C NONL
  set "_first="
  call :_emitVal %%v
)
call %GWSRC%\exec\_pemit "" NL
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_print_path=" & set "_print_col=0" & exit /B 0

:_emitVal
  set "_v=%~1"
  call %GWSRC%\exec\_resolve !_v! _v
  if "!_v:~0,4!"=="STR_" (
    call %GWSRC%\str\str decodePrint 22 NONL
    if not "!_v!"=="STR_" call %GWSRC%\str\str decodePrint !_v:~4! NONL
    call %GWSRC%\str\str decodePrint 22 NONL
    exit /B 0
  )
  set "_t=!_v:~0,1!"
  if "!_t!"=="i" call %GWSRC%\num\int toDec !_v!
  if "!_t!"=="s" call %GWSRC%\num\sng toDec !_v!
  if "!_t!"=="d" call %GWSRC%\num\dbl toDec !_v!
  call %GWSRC%\exec\_pemit "!__!" NONL
  exit /B 0
