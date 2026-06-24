@echo off
@REM TIME$ : current time as "HH:MM:SS" (GW format).  %TIME% is "HH:MM:SS.cc"
@REM (single-digit hours come with a leading space) — zero-pad and drop the
@REM fractional part by taking the first 8 characters.
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_t=%TIME%"
if "!_t:~0,1!"==" " set "_t=0!_t:~1!"
set "_tp=!_t:~0,8!"
call %GWSRC%\str\str encode "!_tp!" _h
call %GWSRC%\stl\vec push %_s% STR_!_h!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
