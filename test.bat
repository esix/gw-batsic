@echo off
goto start

:RunTest operation result
  set "operation=%~1"
  set "__="
  set /a numTests+=1

  call %operation%

  set error=0
  if [%~2] neq [%__%] (
    echo FAILED: "%operation%"
    echo   Expected result = "%~2"
    echo                __ = "%__%"
    echo
    set /a failedTests+=1
  ) else set /a passedTests+=1
exit /B




:start
  setlocal EnableDelayedExpansion
  set PATH=%~dp0\src;%~dp0\lib;%PATH%

  set numTests=0
  set passedTests=0
  set failedTests=0

  rem call RunTest "chr FromAscii __ 33" "^!"
  rem call RunTest "chr FromAscii __ 34" "
  rem call RunTest "chr FromAscii __ 35" "#"
  call :RunTest "chr FromAscii __ 36" "$"
  rem call RunTest "chr FromAscii __ 37" "^%"
  rem call RunTest "chr FromAscii __ 38" "^^&"
  rem call RunTest "chr FromAscii __ 39" "'"
  rem call RunTest "chr FromAscii __ 40" "("
  rem call RunTest "chr FromAscii __ 41" ")"
  rem call RunTest "chr FromAscii __ 47" "/"
  rem call RunTest "chr FromAscii __ 48" "0"
  rem call RunTest "chr FromAscii __ 49" "1"
  rem call RunTest "chr FromAscii __ 58" ":"
  rem call RunTest "chr FromAscii __ 60" "<"
  rem call RunTest "chr FromAscii __ 65" "A"
  rem call RunTest "chr FromAscii __ 73" "I"
  rem call RunTest "chr FromAscii __ 94" "^^"
  rem call RunTest "chr FromAscii __ 97" "a"
  rem call RunTest "chr FromAscii __ 0" "."
  rem call RunTest "chr FromAscii __ 128" "."


  echo Ran %numTests% tests
  echo      FAILED: %failedTests%
  echo      PASSED: %passedTests%

  endlocal
exit /B
