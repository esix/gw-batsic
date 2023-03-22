@echo off
goto _start


:_start
  setlocal EnableDelayedExpansion
  set PATH=%~dp0src;%~dp0lib;%PATH%
  set GWSRC=%~dp0src

  call gw Init
  :: call gw LoadFile "examples\1.bas"
  call gw LoadFile "examples\G3D.bas" 

  endlocal && exit /b

  @REM call txt ReadLines lines examples\1.bas
  @REM set numLines=%ERRORLEVEL%
  @REM call iter range 0 %numLines%
  @REM echo RANGE=%range%

  @REM (for /l %%a in (%range%) do (
  @REM   echo set "line=!lines[%%a]!"
  @REM   set "line=!lines[%%a]!"
  @REM   call str Len len "!line!"
  @REM   echo line[%%a] = ^(!len!^) !line! 
  @REM ))

  endlocal
exit /B
