@echo off
shift & goto :%~1

:Range a b
  setlocal EnableExtensions EnableDelayedExpansion
  set /a "x = %~1"
  set /a "b = %~2"
  set "result="
  :Range__Loop
  if !x! lss !b! (
    set "result=!result! !x!"
    set /a "x = !x! + 1"
    goto :Range__Loop
  )
  endlocal & set "range=%result%"
exit /b 0
