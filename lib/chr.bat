@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start


:FromAscii asciiCode ret
  setlocal EnableDelayedExpansion
  set "ret=."
  set "asciiCode=%~1"
  set "ascii_table=   #$%%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
  set "ascii[33]=^!" & set "ascii[34]=""

  if "!asciiCode!"=="33" (
    endlocal && set "%~2=!"
    exit /b 0
  )
  
  if !asciiCode!==34 (
    endlocal && set %~2="
    exit /b 0
  )

  set /a index=32

  for /l %%0 in (0, 1, 94) do (
    if !asciiCode!==!index! (
      set "ret=!ascii_table:~%%0,1!"
      goto :FromAscii__Result
    )
    set /a index+=1
  )
  :FromAscii__Result
  endlocal && set "%~2=%ret%"
exit /b 0


:_start
  setlocal DisableDelayedExpansion
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
  call expect "chr FromAscii 32 __" " "
  call expect "chr FromAscii 33 __" "!"
  call expect "chr FromAscii 34 __" """
  call expect "chr FromAscii 35 __" "#"
  call expect "chr FromAscii 36 __" "$"
  call expect "chr FromAscii 37 __" "%%%%"
  ::call expect "chr FromAscii 38 __" "&"
  ::call expect "chr FromAscii 39 __" "'"
  ::call expect "chr FromAscii 40 __" "("
  ::call expect "chr FromAscii 45 __" "-"
  ::call expect "chr FromAscii 47 __" "/"
  ::call expect "chr FromAscii 48 __" "0"
exit /b
