@echo off
@REM RESTORE: reset the DATA pointer to the start of the queue.
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_data_ptr=0" & exit /B 0
