@echo off
shift & goto :%~1

:Init
  set "gwLines="
exit /b


:LoadFile filename
  call buffer ReadFile content %~1
  rem TODO: check if binary file and parse other way
  call buffer SplitLines lines !content!

  for %%a in (!lines!) do (
    call:AddTxtLine %%a
  )
exit /b



:AddTxtLine buffer
  setlocal DisableDelayedExpansion
  call gwlexer ParseTxt tokens %~1
  @REM set "line=%~1"
  @REM echo line=%line%
  @REM call str Len len !line!
  @REM rem set %1=filled1
  @REM echo len=%len%
  endlocal
exit /B
