@echo off
shift & goto :%~1

:ReadFile ret file
  setlocal EnableDelayedExpansion
  set "file=%~2"
  FOR /F "usebackq" %%A IN ('%file%') DO set filesize=%%~zA
  rem echo filesize=%filesize%

  set "hexVal=41"
  set "x10=AAAAAAAAAA"

  set /a chunks=1+filesize / 10

  del dummy.txt 2>nul > nul
  for /L %%n in (0,1,%chunks%) DO (
    <nul >> dummy.txt set /p ".=%x10%"
  )
  set result=

  set /a expectedNum=0
  for /F "eol=F usebackq tokens=1,2 skip=1 delims=:[] " %%A in (`fc /b "%file%" dummy.txt`) DO (
    set /a num=0x%%A && (
      set /a numDec=num-1
      set "hex=%%B"

      for /L %%n in (!expectedNum!=,=1 !numDec!) DO (
        set "result=!result!!hexVal!"
      )
      set /a expectedNum=num+1
      set "result=!result!!hex!"
    )
  )
  endlocal && set "%~1=%result%"
exit /b 0 


:SplitLines ret buffer
  setlocal EnableDelayedExpansion
  set "buffer=%~2"
  set "result="
  
  :SplitLines__Loop
    set nextByte=!buffer:~%i%,2!
    if [!nextByte!] equ [0A] ( 
      set "result=!result! " 
    ) else (
      if [!nextByte!] neq [0D] set "result=!result!!nextByte!" 
    )  
    set /a i=i+2
    if [!nextByte!] neq []  goto SplitLines__Loop

  endlocal && set "%~1=%result%"
exit /b 0
