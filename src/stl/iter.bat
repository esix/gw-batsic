@echo off
if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%

:range
  setlocal EnableDelayedExpansion
  set /a "x=%~1"
  set /a "b=%~2"
  set "ret="
:_range_loop
  if !x! LSS !b! (
    set "ret=!ret! !x!"
    set /a "x=x+1"
    goto :_range_loop
  )
  endlocal & set "%~3=%ret:~1%"
  exit /B 0

:_start
echo iter.bat - range iterator
