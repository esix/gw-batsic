@echo off
shift & goto :%~1

:range a b ret
  setlocal EnableDelayedExpansion
  set /a "x = %~1"
  set /a "b = %~2"
  set "ret="
  :Range__Loop
  if !x! lss !b! (
    set "ret=!ret! !x!"
    set /a "x = !x! + 1"
    goto :Range__Loop
  )
  endlocal && set "%~3=%ret:~1%"
exit /b 0
