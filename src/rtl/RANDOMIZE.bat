@echo off
@REM RANDOMIZE: pop the seed expression and ignore it.
@REM
@REM Real GW-BASIC would reseed its PRNG; our RND wraps cmd's %RANDOM% which
@REM has no exposed seed knob, so RANDOMIZE is effectively a no-op apart from
@REM the stack discipline of removing the pushed seed.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _seed
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
