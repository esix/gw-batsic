@echo off
@REM End-to-end smoke test: load + RUN a .bas through the user-facing CLI
@REM (`gw-batsic.bat /R file.bas`).  Catches LOAD-path bugs that the
@REM per-module suite misses — e.g. the keyword-table init bug fixed
@REM in commit 757cca1, which produced "Syntax error" for any program
@REM that used FOR / NEXT / PRINT after a `gw-batsic.bat file.bas` invocation.
set "_root=%~dp0.."
set "_fix=%~dp0fixtures\smoke.bas"
set "_out=%TEMP%\_gwb_cli_smoke.out"

set /a numTests+=1
call "%_root%\gw-batsic.bat" /R "%_fix%" >"%_out%" 2>&1

set "_failed="
findstr /R /C:"^ 1$" "%_out%" >nul || set "_failed=1"
findstr /R /C:"^ 2$" "%_out%" >nul || set "_failed=1"
findstr /R /C:"^ 3$" "%_out%" >nul || set "_failed=1"

if defined _failed (
  echo FAILED: CLI smoke -- gw-batsic.bat /R smoke.bas did not produce 1/2/3
  echo --- captured output ---
  type "%_out%"
  echo --- end output ---
  set /a failedTests+=1
) else (
  set /a passedTests+=1
)
exit /B 0
