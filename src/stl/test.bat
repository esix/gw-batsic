@echo off
@REM Module test runner for src/stl
set "PATH=%~dp0;%PATH%"

echo [stl] Running tests...

call :_run vec.test.bat
call :_run set.test.bat

echo [stl] Done.
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
