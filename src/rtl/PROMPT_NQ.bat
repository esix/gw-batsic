@echo off
@REM PROMPT_NQ: INPUT "prompt", VAR - print the prompt with NO trailing
@REM "? " (_input_prompted=2 tells INPUT to skip the question mark; the
@REM semicolon form PROMPT sets 1, which keeps it).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
if "!_a:~0,4!"=="STR_" (
  if not "!_a!"=="STR_" (
    call %GWSRC%\str\str decodePrint !_a:~4! NONL
  )
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_input_prompted=2" & exit /B 0
