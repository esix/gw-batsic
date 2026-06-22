@echo off
@REM PFILE_SET: begin PRINT#/WRITE# output to a file channel.  Pop the file
@REM number, look up the open handle's path, and set _print_path so the PRINT
@REM formatter family appends to the file.  Errors: 52 bad file number (not
@REM open), 54 bad file mode (channel opened for INPUT).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _fn
call %GWSRC%\exec\_resolve !_fn! _fn
call :_toInt !_fn! _n
call %GWSRC%\exec\_files get !_n! _h
if errorlevel 1 goto :_pf_badnum
if /I "!_hmode!"=="I" goto :_pf_badmode
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_print_path=%_hpath%" & set "_print_col=0" & exit /B 0
:_pf_badnum
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 52
:_pf_badmode
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 54

:_toInt
  set "_v=%~1" & set "_t=!_v:~0,1!"
  if "!_t!"=="i" call %GWSRC%\num\int toDec !_v!
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & call %GWSRC%\num\int toDec !__!)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
