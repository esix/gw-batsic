@echo off
goto _start


:_start
  setlocal EnableDelayedExpansion
  set PATH=%~dp0src;%~dp0lib;%PATH%
  set GWSRC=%~dp0src

  call gw Load "examples\1.bas"
  :: call gw Load "examples\G3D.bas" 

endlocal && exit /b
