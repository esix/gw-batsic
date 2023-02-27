@echo off

set "operation=%~1"
set "__="
set /a numTests+=1

call %operation%
set "e=%ERRORLEVEL%"

if "%~2" neq "%__%" (
  echo FAILED: "%operation%"
  echo   Expected result = "%~2"
  echo                __ = "%__%"   err=%e%
  echo ^^
  set /a failedTests+=1
) else set /a passedTests+=1

exit /B
