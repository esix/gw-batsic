@echo off
@REM RESUME NEXT : continue at the line AFTER the one that errored (the run
@REM loop advances past _gw_erl via _resume_advance).
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_next_line=%_gw_erl%" & set "_resume_advance=1" & exit /B 0
