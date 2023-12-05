@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start

:check v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  echo "xhalf.check %~1"
  if "!v:~1,1!" neq "" endlocal && exit /B 1
  if "!v!" geq "A" if "!v!" leq "F" endlocal && exit /B 0
  if "!v!" geq "0" if "!v!" leq "9" endlocal && exit /B 0
  endlocal && exit /B 1


:_start
echo _start@xhalf.bat
