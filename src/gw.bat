@echo off
shift & goto :%~1

:Load filename

  set "GW_LINE=10 20"
  set "GW_LINE[10]=HELLO"
  set "GW_LINE[20]=WORLD"
  
  set GW_LINE
  call %GWSRC%\cmds\DELETE.bat
  set GW_LINE

  setlocal EnableDelayedExpansion
  :: rem TODO: check if binary file and parse other way

  for /f "tokens=* usebackq delims= " %%a in (`%GWSRC%\utils\hexDump.bat "%~1" ^| %GWSRC%\utils\gw.splitLines.bat`) do (
    set tokens=
    call %GWSRC%\lexer\lexer ParseTxt %%a tokens

    if ERRORLEVEL 1 (
      echo "Lexer ERROR !ERRORLEVEL!"
      echo "Saved tokens=!tokens!"
      exit /b !ERRORLEVEL!
    ) else (
      echo TOKENS=!tokens!
      echo.
    )

    @REM TODO:
    @REM if tokens[0] != LN => error 66 (Direct statement in file)
  )

  endlocal
exit /b
