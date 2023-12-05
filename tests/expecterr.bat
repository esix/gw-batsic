@echo off
:: Usage
::  expecterr "Command" errorcode

set "operation=%~1"
set "__="
set /a numTests+=1

call %operation%
set "e=%ERRORLEVEL%"

if "%~2" neq "%ERRORLEVEL%" (
  echo FAILED: "%operation%"
  echo   Expected error = %~2
  echo              got = %e%    result="%__%"
  echo.
  set /a failedTests+=1
) else set /a passedTests+=1

exit /B
