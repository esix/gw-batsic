@echo off
shift & goto :%~1

:ReadFile file output
  setlocal EnableDelayedExpansion
  set "file=%~1"
  set "output=%~2"
  echo !output!
  echo. > !output!
  FOR /F "usebackq" %%A IN ('%file%') DO set filesize=%%~zA
  :: echo filesize=%filesize%

  set "hexVal=41"
  set "x10=AAAAAAAAAA"

  set /a chunks=1+filesize / 10

  del dummy.txt 2>nul > nul
  for /L %%n in (0,1,%chunks%) DO (
    <nul >> dummy.txt set /p ".=%x10%"
  )

  set "ret="

  set /a expectedNum=0
  for /F "eol=F usebackq tokens=1,2 skip=1 delims=:[] " %%A in (`fc /b "%file%" dummy.txt`) DO (
    set /a num=0x%%A && (
      set /a numDec=num-1
      set "hex=%%B"

      for /L %%n in (!expectedNum!=,=1 !numDec!) DO (
        call strdeq push ret !hexVal!
      )
      set /a expectedNum=num+1
      call strdeq push ret !hex!
      echo ret="!ret!"
      if not "!ret:~46,46!"=="" (
        echo !ret:~0,47! >> !output!
        set "ret=!ret:~48!"
      )
    )
  )

  if not "!ret!"=="" echo !ret:~0,47! >> !output!

  endlocal && set "%~2=%ret%"
exit /b 0


:ToString buffer ret
  setlocal EnableDelayedExpansion
  set "buffer=%~1"
  set "i=0"

  if "!buffer!"=="" goto ToString__LoopEnd

  :ToString__Loop
    set /a  ii = 2 * i
    set "c=!buffer:~%ii%,2!"
    if "!c!"=="" goto ToString__LoopEnd
    set /a  i = i + 1

    call int HexToInt n !c!

    call chr FromAscii ascii !n!
    set "ret=!ret!!ascii!"

    goto ToString__Loop
  :ToString__LoopEnd

  echo ToString %buffer%=%ret%

  endlocal && set "%~2=%ret%"
exit /b 0


:SplitLines ret buffer
  rem will work only for buffered text
  setlocal EnableDelayedExpansion
  set "buffer=%~2"
  set "ret="
  set "i=0"
  
  :SplitLines__Loop
    set nextByte=!buffer:~%i%,2!
    if [!nextByte!] equ [0A] ( 
      set "ret=!ret! " 
    ) else (
      if [!nextByte!] neq [0D] set "ret=!ret!!nextByte!" 
    )  
    set /a i=!i!+2
    if [!nextByte!] neq []  goto SplitLines__Loop

  endlocal && set "%~1=%ret%"
exit /b 0
