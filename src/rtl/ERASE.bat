@echo off
@REM ERASE arr : remove an array so it can be re-DIMmed (or auto-re-created).
@REM Stack: VAR_<type>_NAME (one @ERASE fires per array name in the list).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _v
set "_an=!_v!"
if "!_v:~0,4!"=="VAR_" set "_an=ARR_!_v:~4!"
call %GWSRC%\exec\_arrays erase !_an!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
