@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start





:_start

setlocal EnableDelayedExpansion
  set PATH=%~dp0..\..\tests;%~dp0..\src\mbf;%PATH%
  set "numTests=0"
  set "passedTests=0"
  set "failedTests=0"

  :call expect "mbf\int IntToDec 00FA 64000 __" "Out of Paper"
  :call expecterr "gwerror ErrorCodeToString 0 __" 1


  echo Ran %numTests% tests
  echo      FAILED: %failedTests%
  echo      PASSED: %passedTests%

endlocal
