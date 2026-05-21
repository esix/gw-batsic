@echo off
@REM WEND: pop the top of the WHILE loop stack and jump back to that line.
@REM Re-executing the WHILE statement re-evaluates the condition and either
@REM continues the loop or skips past WEND.
@REM
@REM Error 30 — "WEND without WHILE" if the loop stack is empty.

setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop _while_stack _line
if not defined _line (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 30
)
set "_final=!%_s%!"
endlocal ^
  & set "%~1=%_final%" ^
  & set "_next_line=%_line%" ^
  & set "_while_stack=%_while_stack%" ^
  & exit /B 0
