@echo off
@REM INPUT$(n [, [#]f]): read exactly n characters.  Stack top is the channel
@REM (file form) or the IDNIL sentinel (console form); the count is below it.
@REM File form reads n RAW bytes from the handle's byte cursor (separate from
@REM the line-based POS), advancing it; the value is the raw bytes as STR_<hex>.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _src
call %GWSRC%\stl\vec pop %_s% _cnt
call %GWSRC%\exec\_resolve !_cnt! _cnt
call :_toInt !_cnt! _n
if "!_src!"=="IDNIL" goto :_console
call %GWSRC%\exec\_resolve !_src! _src
call :_toInt !_src! _fn
call %GWSRC%\exec\_files binpos !_fn! _bp
call %GWSRC%\exec\_files filehex !_fn! _all
set /a "_start=_bp*2"
set /a "_len=_n*2"
call set "_slice=%%_all:~!_start!,!_len!%%"
set /a "_nb=_bp+_n"
call %GWSRC%\exec\_files setbinpos !_fn! !_nb!
call %GWSRC%\stl\vec push %_s% STR_!_slice!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_console
@REM Console form: best-effort — read a line from stdin, keep the first n chars.
set "_line="
set /p "_line=" 
call set "_chunk=%%_line:~0,!_n!%%"
call %GWSRC%\str\str encode "!_chunk!" _h
call %GWSRC%\stl\vec push %_s% STR_!_h!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_toInt
  set "_v=%~1" & set "_t=!_v:~0,1!"
  if "!_t!"=="i" call %GWSRC%\num\int toDec !_v!
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & call %GWSRC%\num\int toDec !__!)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
