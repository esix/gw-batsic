
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

