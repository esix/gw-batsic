@echo off
shift & goto :%~1

:LoadFile filename
  setlocal DisableDelayedExpansion
  set line=

  goto :LoadFile.start

  :LoadFile.onNextLine
    setlocal EnableDelayedExpansion
      echo bline=%*
      call buffer decode %* wholeLine
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
    for /f "tokens=* usebackq delims= " %%a in (`%GWSRC%\utils\hexDump.bat "%~1" ^| %GWSRC%\utils\gw.splitLines.bat`) do (
      call :LoadFile.onNextLine %%a
      if ERRORLEVEL 1 (
        echo "onNextLine - got error"
        exit /b 
      )
    )
    :: rem TODO: check if binary file and parse other way

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
