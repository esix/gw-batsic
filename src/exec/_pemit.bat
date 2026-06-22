@echo off
@REM _pemit TEXT [NONL] — append safe text (numbers/spaces, or empty for a
@REM blank line) to the active print sink file (%_print_path%).  Routes through
@REM decodePrint so leading spaces survive and the CRLF rides inside the hex
@REM (a newline-only echo to a file emits nothing on the port).  Only called
@REM when _print_path is set; console PRINT keeps its inline fast path.
setlocal EnableDelayedExpansion
set "_t=%~1" & set "_m=%~2"
if not defined _t (
  if /I "!_m!"=="NONL" (endlocal & exit /B 0)
  call %GWSRC%\str\str decodePrint ""
  endlocal & exit /B 0
)
call %GWSRC%\str\str encode "!_t!" _eh
if /I "!_m!"=="NONL" (call %GWSRC%\str\str decodePrint !_eh! NONL) else (call %GWSRC%\str\str decodePrint !_eh!)
endlocal & exit /B 0
