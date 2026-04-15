@echo off
@REM DEFDBL: set default type to double for letter range
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _end
call %GWSRC%\stl\vec pop %_s% _start
set "_fl=!_start:~8,1!"
set "_tl=!_end:~8,1!"
if not defined _tl set "_tl=!_fl!"
call %GWSRC%\exec\_vars defrange !_fl! !_tl! d
endlocal
exit /B 0
