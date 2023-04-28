@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start


:push deq el
  setlocal EnableDelayedExpansion
  set "deq=%~1"
  set "val=!%deq%!"
  if "!val!"=="" (
    set "val=%~2"
  )  else (
    set "val=!val! %~2"
  )
  endlocal && set "%~1=%val%"
exit /b 0

:pop
  :: TODO
exit /b 0

:unshift
  :: TODO
exit /b

:shift deq
  setlocal EnableDelayedExpansion
  set "deq=%~1"
  set "val=!%deq%!"
  if "!val!"=="" (
    :: deq is empty
    endlocal
    exit /b 1
  )
  for /f "tokens=1*" %%a in ("!val!") do set "val=%%b"
  endlocal && set "%~1=%val%"
exit /b

:front
  :: TODO
exit /b 0

:back
  :: TODO
exit /b 0


:includes vec val
  setlocal EnableDelayedExpansion
  set "vec=%~1"
  set "val=!%vec%!"
  if "!val!"=="" (
    endlocal
    exit /b 1
  )
  for %%a in (!val!) do (
    if "%~2"=="%%a" (
      endlocal
      exit /b 0
    )
  )
  endlocal 
exit /b 1

:push_uniq vec val
  call:includes "%~1" "%~2"
  if ERRORLEVEL 1 (
    call:push "%~1" "%~2"
    exit /b 0
  )
exit /b 1



:_start
  setlocal EnableDelayedExpansion
  set PATH=%~dp0..\tests;%~dp0;%PATH%
  set "numTests=0"
  set "passedTests=0"
  set "failedTests=0"
  call:_test
  echo Total tests: %numTests%
  echo      FAILED: %failedTests%
  echo      PASSED: %passedTests%
  endlocal
exit /b

:_test
  set __=
  call expect "strdeq push __ xx" "xx"
  call expect "strdeq push __ yy" "xx yy"
  call expect "strdeq push __ zz" "xx yy zz"

  call expect "strdeq shift __" "yy zz"
  call expect "strdeq shift __" "zz"
  call expect "strdeq shift __" ""

exit /b
