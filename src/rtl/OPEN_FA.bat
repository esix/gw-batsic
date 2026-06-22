@echo off
@REM OPEN_FA: verbose form  OPEN file FOR APPEND AS [#]chan
@REM Stack (top->bottom): chan, file
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _chan
call %GWSRC%\stl\vec pop %_s% _file
call %GWSRC%\exec\_doopen A !_chan! !_file! ONIL
set "_e=!ERRORLEVEL!"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B %_e%
