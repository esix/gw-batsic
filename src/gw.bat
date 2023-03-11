@echo off
shift & goto :%~1

:Init
  set "gwLines="
exit /b


:LoadFile filename
  setlocal DisableDelayedExpansion
  set line=

  goto :LoadFile.start

  :LoadFile.onNextBuffer
    for %%b in (%*) do call :LoadFile.onNextChar %%b
  exit /b

  :LoadFile.onNextChar
    set isEol=

    if %~1==0D set "isEol=T"
    if %~1==0A set "isEol=T"

    if "%isEol%"=="T" (
      if "%line%"=="" exit /b
      call :LoadFile.onNextLine %line%
      set line=
      exit /b
    )
    if "%line%"=="" (
      set "line=%~1"
    ) else (
      set "line=%line%%~1"
    )
  exit /b

  :LoadFile.onNextLine
    echo line=%*
    call gwlexer ParseTxt %* tokens
    if ERRORLEVEL 1 (
      echo "ERROR"
    ) else (
      echo TOKENS=%tokens%
    )

  exit /b



  :LoadFile.start
  for /f "tokens=* usebackq delims= " %%a in (`hexDump "%~1"`) do call :LoadFile.onNextBuffer %%a
  call :LoadFile.onNextChar 0D

  rem TODO: check if binary file and parse other way
  :: call buffer SplitLines lines !content!

  :: for %%a in (!lines!) do (
  ::  echo %%a
  ::  call:AddTxtLine %%a
  ::)
  endlocal
exit /b


:AddTxtLine buffer
  setlocal EnableDelayedExpansion
  call gwlexer ParseTxt tokens %~1
  @REM set "line=%~1"
  @REM echo line=%line%
  @REM call str Len len !line!
  @REM rem set %1=filled1
  @REM echo len=%len%
  endlocal
exit /B
