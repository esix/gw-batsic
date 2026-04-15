@echo off
@REM DEFINT: pop range (two VAR tokens), set default type to integer
@REM Stack: ... VAR_start VAR_end → ...
@REM Or just: ... VAR_single → ... (single letter, no range)
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _end
call %GWSRC%\stl\vec pop %_s% _start
@REM Extract letter from VAR_UNK_X
set "_fl=!_start:~8,1!"
set "_tl=!_end:~8,1!"
if not defined _tl set "_tl=!_fl!"
call %GWSRC%\exec\_vars defrange !_fl! !_tl! i
endlocal
exit /B 0
