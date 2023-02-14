@echo off
shift & goto :%~1

:ReadLines var file
  rem setlocal EnableDelayedExpansion
  set /a lineno=0

  FOR /F "tokens=1,* usebackq delims=:" %%a in (`"findstr /n ^^ %~2"`) do (
    set "%~1[!lineno!]=%%b"
    rem set /a "lineno=%%a - 1"
    set /a "lineno=!lineno! + 1"
  )

exit /b %lineno%
