@echo off
@REM TIME$ = expr : set the system time.  We cannot set the host clock, so the
@REM new value is accepted and discarded (pop it to keep the stack balanced).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _v
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
