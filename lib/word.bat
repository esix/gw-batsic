@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start

:WordToDec hex ret
  setlocal EnableDelayedExpansion
  set "hex=%~1"
  set "ret=0"
  set "i=0"
  set "multiplier=1"

  if "!hex!"=="" goto HexToInt__LoopEnd

  :HexToInt__Loop
    set "c=!hex:~%i%,1!"
    if "!c!"=="" goto HexToInt__LoopEnd
    set /a  i = i + 1
    if "!c!"=="a" set c=10
    if "!c!"=="A" set c=10
    if "!c!"=="b" set c=11
    if "!c!"=="B" set c=11
    if "!c!"=="c" set c=12
    if "!c!"=="C" set c=12
    if "!c!"=="d" set c=13
    if "!c!"=="D" set c=13
    if "!c!"=="e" set c=14
    if "!c!"=="E" set c=14
    if "!c!"=="f" set c=15
    if "!c!"=="F" set c=15
    set /a ret = ret + c * !multiplier!
    set /a multiplier = multiplier * 16
    goto HexToInt__Loop
  :HexToInt__LoopEnd

  if "!ret!"=="" (
    endlocal && exit /b 1
  )

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
