@echo off
@REM OPEN_M: mode-comma form  OPEN modeStr , [#]chan , file [, reclen]
@REM Stack (top->bottom): reclen-or-ONIL, file, chan, modeStr
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _rl
call %GWSRC%\stl\vec pop %_s% _file
call %GWSRC%\stl\vec pop %_s% _chan
call %GWSRC%\stl\vec pop %_s% _modetok
call %GWSRC%\exec\_resolve !_modetok! _modetok
set "_ms="
if "!_modetok:~0,4!"=="STR_" if not "!_modetok!"=="STR_" call %GWSRC%\str\str decode !_modetok:~4! _ms
set "_mode=R"
if defined _ms set "_mode=!_ms:~0,1!"
call %GWSRC%\exec\_doopen !_mode! !_chan! !_file! !_rl!
set "_e=!ERRORLEVEL!"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B %_e%
