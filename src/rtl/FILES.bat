@echo off
@REM FILES "filespec": list matching files, one name per line.  Uses captured
@REM dir output (not `if exist`, which the cmd port doesn't wildcard-match, nor
@REM dir's errorlevel, which the port doesn't set on no-match) so it behaves the
@REM same on the port and real cmd.exe.  Error: 53 not found, 64 bad filename.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
if not "!_a:~0,4!"=="STR_" goto :_f_bad
set "_path="
if not "!_a!"=="STR_" call %GWSRC%\str\str decode !_a:~4! _path
if not defined _path goto :_f_bad
dir /b "!_path!" > "%GWTEMP%\_files.tmp" 2>nul
set "_first="
set /p "_first=" < "%GWTEMP%\_files.tmp"
if not defined _first goto :_f_nf
type "%GWTEMP%\_files.tmp"
del "%GWTEMP%\_files.tmp" >nul 2>nul
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
:_f_nf
del "%GWTEMP%\_files.tmp" >nul 2>nul
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 53
:_f_bad
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 64
