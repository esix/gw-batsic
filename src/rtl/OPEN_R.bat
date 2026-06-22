@echo off
@REM OPEN_R: random AS form  OPEN file AS [#]chan [LEN= reclen]
@REM Stack (top->bottom): reclen-or-ONIL, chan, file
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _rl
call %GWSRC%\stl\vec pop %_s% _chan
call %GWSRC%\stl\vec pop %_s% _file
call %GWSRC%\exec\_doopen R !_chan! !_file! !_rl!
set "_e=!ERRORLEVEL!"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B %_e%
