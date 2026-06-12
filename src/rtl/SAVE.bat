@echo off
@REM SAVE: SAVE "file"[,A|,P] - write the program to disk.  The option
@REM letter arrives as a raw VAR_ token on top of the stack; A selects
@REM ASCII output, anything else (or no option) saves tokenized binary.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
set "_mode="
if "!_a:~0,4!"=="VAR_" (
  for /f "tokens=3 delims=_" %%m in ("!_a!") do set "_mode=%%m"
  call %GWSRC%\stl\vec pop %_s% _a
)
call %GWSRC%\exec\_resolve !_a! _a
if not "!_a:~0,4!"=="STR_" goto :_sv_err
set "_path="
if not "!_a!"=="STR_" call %GWSRC%\str\str decode !_a:~4! _path
if not defined _path goto :_sv_err
if /I "!_mode!"=="A" (
  call %GWSRC%\file\file save "!_path!" A
) else (
  call %GWSRC%\file\file save "!_path!"
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
:_sv_err
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 64
