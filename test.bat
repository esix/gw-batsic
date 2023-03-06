@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start


:_start
  setlocal EnableDelayedExpansion
  set PATH=%~dp0\src;%~dp0\lib;%PATH%

  set numTests=0
  set passedTests=0
  set failedTests=0

  echo byte
  call byte _test

  echo strdeq
  call strdeq _test

  echo Total tests: %numTests%
  echo      FAILED: %failedTests%
  echo      PASSED: %passedTests%

  endlocal
exit /B
