@echo off
@REM Module test runner for src/parser
set "PATH=%~dp0;%~dp0..\stl;%PATH%"

call _table loadCache "%~dp0_table.dat"
if errorlevel 1 (echo _table.dat not found. Run _rebuild.bat & exit /B 1)

echo [parser] Running tests...

call :_run parse.test.bat

echo [parser] Done.
exit /B

:_run
  set "_bf=%failedTests%"
  echo   %~1 ...
  call %~1
  if "!failedTests!"=="%_bf%" (
    echo   %~1 OK
  ) else (
    echo   %~1 FAILED
  )
  exit /B
