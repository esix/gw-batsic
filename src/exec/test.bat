@echo off
@REM Module test runner for src/exec
if not defined GWSRC set "GWSRC=%~dp0.."
if not defined GWTEMP set "GWTEMP=%~dp0..\..\temp"
set "PATH=%~dp0;%GWSRC%\parser;%GWSRC%\lexer;%PATH%"

call %GWSRC%\lexer\keyword init
call %GWSRC%\parser\_table loadCache "%GWSRC%\parser\_table.dat"
call %GWSRC%\exec\_vars init

echo [exec] Running tests...

call :_run _program.test.bat
call :_run _arrays.test.bat
call :_run exec.test.bat

echo [exec] Done.
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
