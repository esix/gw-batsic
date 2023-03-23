@echo off
shift & goto :%~1

:LoadFile filename
  setlocal EnableDelayedExpansion
 
  for /f "tokens=* usebackq delims= " %%a in (`%GWSRC%\utils\hexDump.bat "%~1" ^| %GWSRC%\utils\gw.splitLines.bat`) do (
    set tokens=
    call gwlexer ParseTxt %%a tokens
    rem call :LoadFile.onNextLine %%a
    if ERRORLEVEL 1 (
      echo "Lexer ERROR !ERRORLEVEL!"
      echo "Saved tokens=!tokens!"
      exit /b !ERRORLEVEL!
    ) else (
      echo TOKENS=!tokens!
      echo.
    )
  )
  :: rem TODO: check if binary file and parse other way

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
