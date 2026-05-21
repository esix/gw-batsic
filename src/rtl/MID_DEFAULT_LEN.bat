@echo off
@REM MID_DEFAULT_LEN: pushes the max int (32767) as a sentinel so @FN_MID
@REM always sees three operands.  MID$(s, n) without a length is equivalent
@REM to "take everything from position n onward".
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec push %_s% i7FFF
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
