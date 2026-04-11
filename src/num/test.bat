@echo off
@REM Module test runner for src/num
@REM Runs test files in dependency order (foundation first, facades last)
@REM Expects: numTests, passedTests, failedTests, test, expect vars from parent

echo [num] Running tests...

call :_run _xhalf.test.bat
call :_run _xbyte.test.bat
call :_run _xword.test.bat
call :_run _xdword.test.bat
call :_run _xqword.test.bat
call :_run _mbfs.test.bat
call :_run _mbfd.test.bat
call :_run int.test.bat
call :_run sng.test.bat
call :_run dbl.test.bat

echo [num] Done.
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
