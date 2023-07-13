@echo off
if not defined GWSRC set GWSRC=%~dp0..

goto :_start


:computeNullable
  setlocal EnableDelayedExpansion
  echo Computing nullable...
  set nullable=
  set fixpoint=
  set iteration=
  call %GWSRC%\lib\iter range 0 %grammar.rules.length% iter

  :computeNullable__Loop
    set fixpoint=T
    for %%i in (!iter!) do (
      call :computeNullable__checkRule "!grammar.rules[%%i]!"
    )
  
  endlocal && set "tables.nullable=%nullable%"
  exit /b 0

  :computeNullable__checkRule rule
    set "rule=%~1"
    call %GWSRC%\lib\strvec shift rule
    echo Rule: %rule%
    set passed=T
    for %%e in (!rule!) do (
      call %GWSRC%\lib\strvec includes tables.nullable %%e
      if not errorlevel 1 (
        echo "NOT INCLUDES"  
        set passed=
      )
      echo %%e: passed=%passed% %errorlevel%
    )
  exit /b 0


:_start
  call:computeNullable
  echo nullable=%tables.nullable%
