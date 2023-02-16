@echo off
shift & goto :%~1

:HexToInt ret buffer
  setlocal EnableDelayedExpansion
  set "buffer=%~2"
  set "ret=0"
  set "i=0"

  if "!buffer!"=="" goto HexToInt__LoopEnd

  :HexToInt__Loop

    set "c=!buffer:~%i%,1!"
    if "!c!"=="" goto HexToInt__LoopEnd
    set /a  i = i + 1
    if "!c!"=="a" set c=10
    if "!c!"=="A" set c=10
    if "!c!"=="b" set c=11
    if "!c!"=="B" set c=11
    if "!c!"=="c" set c=12
    if "!c!"=="C" set c=12
    if "!c!"=="d" set c=13
    if "!c!"=="D" set c=13
    if "!c!"=="e" set c=14
    if "!c!"=="E" set c=14
    if "!c!"=="f" set c=15
    if "!c!"=="F" set c=15
    set /a ret = 16 * ret + c

    goto HexToInt__Loop
  :HexToInt__LoopEnd

  endlocal && set "%~1=%ret%"
exit /b