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
    for %%b in (%*) do (
      call :LoadFile.onNextChar %%b
      if ERRORLEVEL 1 (
        echo "onNextBuffer - got error"
        exit /b 
      )
    )
  exit /b 0

  :LoadFile.onNextChar
    set isEol=

    if %~1==0D set "isEol=T"
    if %~1==0A set "isEol=T"

    if NOT "%isEol%"=="T" (
      if "%line%"=="" (
        set "line=%~1"
      ) else (
        set "line=%line%%~1"
      )
      exit /b 0
    )

    if "%isEol%"=="T" (
      if "%line%"=="" exit /b 0
    )
    call :LoadFile.onNextLine %line%
    if ERRORLEVEL 1 (
      echo "Error occured %ERRORLEVEL%"
      exit /b %ERRORLEVEL%
    )
    set line=
  exit /b 0

  :LoadFile.onNextLine
    setlocal EnableDelayedExpansion
      echo bline=%*
      call buffer toString %* wholeLine
      echo _line=!wholeLine!
    endlocal

    set tokens=
    call gwlexer ParseTxt %* tokens
    if ERRORLEVEL 1 (
      echo "Lexer ERROR %ERRORLEVEL%"
      echo "Saved tokens=%tokens%"
      exit /b %ERRORLEVEL%
    ) else (
      echo TOKENS=%tokens%
      echo.
    )
  exit /b

  :LoadFile.start
    for /f "tokens=* usebackq delims= " %%a in (`hexDump "%~1"`) do (
      call :LoadFile.onNextBuffer %%a
      if ERRORLEVEL 1 (
        echo "LoadFile: error"
        goto:LoadFile.Finished 
      )
    )
    call :LoadFile.onNextChar 0D
    rem TODO: check if binary file and parse other way

    :LoadFile.Finished
    echo "Finished"
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
