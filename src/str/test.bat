@echo off
@REM Module test runner for src/str
set "PATH=%~dp0;%PATH%"

echo [str] Running tests...

call :_run str.test.bat

echo [str] Done.
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
