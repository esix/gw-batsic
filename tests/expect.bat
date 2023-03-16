@echo off

set "operation=%~1"
:: set "__="
set /a numTests+=1

call %operation%
set "e=%ERRORLEVEL%"

set isFailed=
set expected=%~2

setlocal EnableDelayedExpansion
if "!expected!" neq "!__!" (
  echo FAILED: "%operation%"
  echo   Expected result = "%~2"
  ::set __
  echo                __ = "%__%"   err=%e%
  echo.
  endlocal && set isFailed=T
) else (
  endlocal
)


if "%isFailed%"=="T" (
  set /a failedTests+=1
) else (
  set /a passedTests+=1
)
set isFailed=

exit /B

