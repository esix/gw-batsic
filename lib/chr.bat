@echo off
shift & goto :%~1

:FromAscii ret asciiCode
  setlocal EnableDelayedExpansion
  set "ret=."
  set "asciiCode=%~2"
  set "ascii_table=   #$%%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
  set "ascii[33]=^!" & set "ascii[34]=""
  set /a index=32
  if !asciiCode!==33 (
    endlocal && set "%~1=!"
    exit /b 0
  )
  if !asciiCode!==34 endlocal & set "%~1=%ascii[34]%" & exit /b 0
  
  for /l %%0 in (0, 1, 94) do (
    if !asciiCode!==!index! (
      set "ret=!ascii_table:~%%0,1!"
      goto :FromAscii__Result
    )
    set /a index+=1
  )
  :FromAscii__Result 
  endlocal && set "%~1=%ret%"
exit /b 0


