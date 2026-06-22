@echo off
@REM FIELD_MARK: push the FIELD_MRK sentinel below the width/var pair list.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% FIELD_MRK
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
