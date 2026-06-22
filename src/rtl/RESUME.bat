@echo off
@REM RESUME [0] : re-run the statement that errored (the trapped line).
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_next_line=%_gw_erl%" & exit /B 0
