@echo off
goto _start


:_start
  setlocal EnableDelayedExpansion
  set PATH=%~dp0src;%~dp0src\num;%~dp0src\lexer;%~dp0lib;%PATH%
  set GWSRC=%~dp0src
  chcp 65001

  @REM Pre-load keyword tables (once, not per-call)
  call keyword init

  if "%~1"=="" (
    call gw Load "examples\1.bas"
  ) else (
    call gw Load "%~1"
  )

endlocal && exit /b
