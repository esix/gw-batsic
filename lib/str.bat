@echo off
shift & goto :%~1

:len ret str
  setlocal EnableDelayedExpansion
  set "s=A!%~2!"
  rem echo "%~1=STRLEN(%~2)"
  set "len=0"
  for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
    if "!s:~%%P,1!" neq "" (
      set /a "len+=%%P"
      set "s=!s:~%%P!"
    )
  )
  endlocal & set "%~1=%len%"
exit /b 0

