@echo off
goto _start


:_start
  setlocal EnableDelayedExpansion
  set PATH=%~dp0src;%~dp0lib;%PATH%
  set GWSRC=%~dp0src
  chcp 65001

  call %GWSRC%\parser\init

  call gw Load "examples\1.bas"
  :: call gw Load "examples\G3D.bas" 

endlocal && exit /b
