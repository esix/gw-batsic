@echo off
@REM KILL "filespec": delete matching file(s) (wildcards allowed).  Matches are
@REM detected via captured dir output (portable across the cmd port and real
@REM cmd.exe).  Errors: 53 File not found, 64 Bad filename.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
if not "!_a:~0,4!"=="STR_" goto :_k_bad
set "_path="
if not "!_a!"=="STR_" call %GWSRC%\str\str decode !_a:~4! _path
if not defined _path goto :_k_bad
dir /b "!_path!" > "%GWTEMP%\_kill.tmp" 2>nul
set "_first="
set /p "_first=" < "%GWTEMP%\_kill.tmp"
del "%GWTEMP%\_kill.tmp" >nul 2>nul
if not defined _first goto :_k_nf
del /Q "!_path!" >nul 2>nul
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
:_k_nf
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 53
:_k_bad
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 64
