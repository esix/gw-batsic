@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start

:WordToDec hex ret
  setlocal DisableDelayedExpansion
  set "hex=%1"
  set "ret="

  if "%hex:~3,4%"=="" endlocal && exit /b 1

  call byte ByteToDec %hex:~0,2% c2
  if ERRORLEVEL 1 endlocal && exit /b 1 

  call byte ByteToDec %hex:~2,4% c1
  if ERRORLEVEL 1 endlocal && exit /b 1 

  if not "%hex:~4,5%"=="" endlocal && exit /b 1

  set /a ret = c1 * 256 + c2

  endlocal && if "%~2"=="" (
    echo %ret%
  ) else (
    set "%~2=%ret%"
  )
exit /b



:_start
  setlocal EnableDelayedExpansion
  set PATH=%~dp0..\tests;%~dp0;%PATH%
  set "numTests=0"
  set "passedTests=0"
  set "failedTests=0"

  call expect "word WordToDec 00FA __" "64000"
  :call expecterr "gwerror ErrorCodeToString 0 __" 1


  echo Ran %numTests% tests
  echo      FAILED: %failedTests%
  echo      PASSED: %passedTests%

  endlocal
