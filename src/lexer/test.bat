@echo off
@REM Module test runner for src/lexer
set "PATH=%~dp0;%~dp0..\num;%~dp0..;%~dp0..\..\lib;%PATH%"
set "GWSRC=%~dp0.."

call keyword init

echo [lexer] Running tests...

call :_run lexer.test.bat

echo [lexer] Done.
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
