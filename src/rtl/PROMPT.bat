@echo off
@REM PROMPT: pop a string, print it (no newline) — the optional INPUT prompt.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
if "!_a:~0,4!"=="STR_" (
  if not "!_a!"=="STR_" (
    call %GWSRC%\str\str decode !_a:~4! _txt
    <nul set /p "=!_txt!"
  )
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_input_prompted=1" & exit /B 0
