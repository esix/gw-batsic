@echo off
@REM DATE$ : current date as "MM-DD-YYYY" (GW format).  %DATE% is the host
@REM "Www MM/DD/YYYY" — take the last space-token (the date) and turn / into -.
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_d=%DATE%"
set "_dp="
for %%a in (!_d!) do set "_dp=%%a"
set "_dp=!_dp:/=-!"
call %GWSRC%\str\str encode "!_dp!" _h
call %GWSRC%\stl\vec push %_s% STR_!_h!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
