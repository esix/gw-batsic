@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start

:decode buffer ret
  setlocal EnableDelayedExpansion
  set "buffer=%~1"
  set "i=0"
  set ret=

  if "!buffer!"=="" goto ToString__LoopEnd

  :ToString__Loop
    set /a  ii = 2 * i
    set "c=!buffer:~%ii%,2!"
    if "!c!"=="" goto ToString__LoopEnd
    set /a  i = i + 1

    call byte ByteToDec !c! n
    call chr FromAscii !n! ascii

    set "ret=!ret!!ascii!"

    goto ToString__Loop
  :ToString__LoopEnd

  endlocal && set "%~2=%ret%"
exit /b 0


:encode str ret
exit /b 0


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
  :: 1090 print "                 HELLO WORLD!!!"
  call expect "buffer decode 31303930207072696E742022202020202020202020202020202020202048454C4C4F20574F524C4421212122 __" "1090 print ""                 HELLO WORLD""
exit /b
