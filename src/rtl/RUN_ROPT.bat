@echo off
@REM RUN_ROPT: discard the RUN "file",R keep-files-open flag (a raw VAR_ token)
@REM so @RUN_FILE sees only the filename below it.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _v
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
