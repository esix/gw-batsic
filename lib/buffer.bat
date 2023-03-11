@echo off
shift & goto :%~1

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
