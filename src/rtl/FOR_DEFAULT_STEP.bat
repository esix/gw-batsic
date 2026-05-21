@echo off
@REM FOR_DEFAULT_STEP: push the implicit step value (1) when "STEP n" wasn't given.
@REM The grammar emits this marker for the empty StepClause so @FOR always
@REM finds a step on the stack.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% i0001
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
