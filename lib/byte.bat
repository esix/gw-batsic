@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start


:_HexCharToDec hex ret
  setlocal DisableDelayedExpansion
  set "hex=%1"
  set "ret="
  if "%hex%"=="0" set "ret=0" && goto _HexCharToDec__end
  if "%hex%"=="1" set "ret=1"
  if "%hex%"=="2" set "ret=2"
  if "%hex%"=="3" set "ret=3"
  if "%hex%"=="4" set "ret=4"
  if "%hex%"=="5" set "ret=5"
  if "%hex%"=="6" set "ret=6"
  if "%hex%"=="7" set "ret=7"
  if "%hex%"=="8" set "ret=8"
  if "%hex%"=="9" set "ret=9"
  if "%hex%"=="A" set "ret=10"
  if "%hex%"=="a" set "ret=10"
  if "%hex%"=="B" set "ret=11"
  if "%hex%"=="b" set "ret=11"
  if "%hex%"=="C" set "ret=12"
  if "%hex%"=="c" set "ret=12"
  if "%hex%"=="D" set "ret=13"
  if "%hex%"=="d" set "ret=13"
  if "%hex%"=="E" set "ret=14"
  if "%hex%"=="e" set "ret=14"
  if "%hex%"=="F" set "ret=15"
  if "%hex%"=="f" set "ret=15"

  :_HexCharToDec__end
  if "%ret%"=="" (
    endlocal && exit /b 1
  )
  endlocal && if "%~2"=="" (
    echo %ret%
  ) else (
    set "%~2=%ret%"
  )
exit /b 0


:ByteToDec hex ret
  setlocal DisableDelayedExpansion
  set "hex=%1"
  set "ret=0"

  call :_HexCharToDec %hex:~0,1% c1
  if not ERRORLEVEL 0 endlocal && exit /b 1 

  call :_HexCharToDec %hex:~1,2% c2
  if not ERRORLEVEL 0 endlocal && exit /b 1 

  if not "%hex:~2,3%"=="" endlocal && exit /b 1

  set /a ret = c1 * 16 + c2

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

  call expect "byte _HexCharToDec 0 __" "0"
  call expect "byte _HexCharToDec 1 __" "1
  call expect "byte _HexCharToDec a __" "10"
  call expect "byte _HexCharToDec F __" "15"
  call expecterr "byte _HexCharToDec g __" 1

  call expect "byte ByteToDec 00 __" "0"
  call expect "byte ByteToDec 7f __" "127"
  call expect "byte ByteToDec Ff __" "255"
  call expecterr "byte ByteToDec 100 __" 1
  call expecterr "byte ByteToDec 0 __" 1

  echo Ran %numTests% tests
  echo      FAILED: %failedTests%
  echo      PASSED: %passedTests%

  endlocal
