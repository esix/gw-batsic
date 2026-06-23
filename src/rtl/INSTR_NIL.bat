@echo off
@REM INSTR_NIL: marks the absent first (start) argument of INSTR so @FN_INSTR
@REM always sees three operands and can tell INSTR(x$,y$) from INSTR(n,x$,y$).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% INSTR_NIL
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
