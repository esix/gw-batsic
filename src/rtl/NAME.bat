@echo off
@REM NAME old AS new: rename a file in place.  Stack (top last): old new.
@REM Errors: 53 File not found (old), 58 File already exists (new), 64 Bad name.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _new
call %GWSRC%\stl\vec pop %_s% _old
call %GWSRC%\exec\_resolve !_new! _new
call %GWSRC%\exec\_resolve !_old! _old
if not "!_new:~0,4!"=="STR_" goto :_n_bad
if not "!_old:~0,4!"=="STR_" goto :_n_bad
set "_np=" & set "_op="
if not "!_new!"=="STR_" call %GWSRC%\str\str decode !_new:~4! _np
if not "!_old!"=="STR_" call %GWSRC%\str\str decode !_old:~4! _op
if not defined _np goto :_n_bad
if not defined _op goto :_n_bad
if not exist "!_op!" goto :_n_nf
if exist "!_np!" goto :_n_exists
@REM `move` (not `ren`) so a path-qualified destination works; we already
@REM verified the target does not exist, so this never silently overwrites.
move "!_op!" "!_np!" >nul 2>nul
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
:_n_nf
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 53
:_n_exists
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 58
:_n_bad
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 64
