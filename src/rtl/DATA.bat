@echo off
@REM DATA: discard the values that were pushed for this DATA statement.
@REM Pop down to the DATA_MRK sentinel.  The actual data queue was built
@REM at RUN time by the program-wide pre-scan.
setlocal EnableDelayedExpansion
set "_s=%~1"
:_data_pop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_data_done
  if "!_v!"=="DATA_MRK" goto :_data_done
  goto :_data_pop
:_data_done
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
