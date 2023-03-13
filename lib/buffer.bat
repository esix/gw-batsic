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

  ::echo ToString %buffer%=%ret%

  endlocal && set "%~2=%ret%"
exit /b 0
