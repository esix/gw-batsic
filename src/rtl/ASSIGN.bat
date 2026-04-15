@echo off
@REM ASSIGN: pop value and variable ref, store variable
@REM Stack: ... varname value → ...
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _val
call %GWSRC%\stl\vec pop %_s% _var
call %GWSRC%\exec\_vars set !_var! !_val!
endlocal
exit /B 0
