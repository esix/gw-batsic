@echo off
goto start


:start
  setlocal EnableDelayedExpansion
  set PATH=%~dp0\src;%~dp0\lib;%PATH%

  call gw Init
  call gw LoadFile examples\1.bas

  exit /b

  call txt ReadLines lines examples\1.bas
  set numLines=%ERRORLEVEL%
  call iter range 0 %numLines%
  echo RANGE=%range%

  (for /l %%a in (%range%) do (
    echo set "line=!lines[%%a]!"
    set "line=!lines[%%a]!"
    call str Len len "!line!"
    echo line[%%a] = ^(!len!^) !line! 
  ))

  endlocal
exit /B
