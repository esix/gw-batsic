@echo off
@REM IFILE_SET: begin INPUT# from a file channel.  Pop the file number, verify
@REM it is open for INPUT, and set _input_fh so INPUT.bat reads from the file.
@REM Errors: 52 bad file number, 54 bad file mode (not opened for INPUT).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _fn
call %GWSRC%\exec\_resolve !_fn! _fn
call :_toInt !_fn! _n
call %GWSRC%\exec\_files get !_n! _h
if errorlevel 1 goto :_if_badnum
if /I not "!_hmode!"=="I" goto :_if_badmode
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_input_fh=%_n%" & exit /B 0
:_if_badnum
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 52
:_if_badmode
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 54

:_toInt
  set "_v=%~1" & set "_t=!_v:~0,1!"
  if "!_t!"=="i" call %GWSRC%\num\int toDec !_v!
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & call %GWSRC%\num\int toDec !__!)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
