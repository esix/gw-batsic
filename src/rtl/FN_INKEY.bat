@echo off
@REM FN_INKEY: INKEY$ - return the next keystroke as a 0- or 1-char string.
@REM Pure batch has no non-blocking single-key read, so this reads one line
@REM from stdin and returns its first character (empty string for a blank
@REM line or EOF).  Authenticity caveat: it blocks and needs Enter, unlike
@REM the real non-blocking INKEY$ (see docs/99-not-implementable.md).
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_line="
set /p "_line="
set "_c1=!_line:~0,1!"
if not defined _c1 (
  call %GWSRC%\stl\vec push %_s% STR_
) else (
  call %GWSRC%\str\str encodeRaw "!_c1!" _ph
  call %GWSRC%\stl\vec push %_s% STR_!_ph!
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
