@echo off
@REM RND_NOARG: bare `RND` had no argument list — push the default arg (1).
@REM Equivalent to writing `RND(1)`, which means "next random number".
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% NUM_i0001
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
