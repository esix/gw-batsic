@echo off
shift & goto :%~1

:ParseTxt tokens buffer
  setlocal EnableDelayedExpansion
  set "buffer=%~2"
  set "tokens="
  set "i=0"
  set "state=Start"
  set "acc="

  :ParseTxt__Loop
    set /a  ii = 2 * i
    set "c=!buffer:~%ii%,2!"
    if "!c!"=="" goto ParseTxt__LoopEnd
    set /a  i = i + 1

    call :isSpace !c!
    call :isNumber !c!
    rem echo State=!state! char=!c! isNumber=!isNumber! isSpace=!isSpace!

    if "!state!"=="Start" goto ParseTxt__State__Start
    if "!state!"=="Normal" goto ParseTxt__State__Normal
    if "!state!"=="LineNumber" goto ParseTxt__State__LineNumber
    echo "Unknown state !state!: exit"
    goto ParseTxt__LoopEnd

    :ParseTxt__State__Start
      if "!isSpace!"=="T" ( 
        rem space is ok
      ) else (
        if "!isNumber!"=="T" (
          set state=LineNumber
          set "acc=!c!"
        ) else (
          set state=Normal
          set /a "i=!i!-1"
        )
      )
    goto ParseTxt__Loop

    :ParseTxt__State__Normal
      rem 
    goto ParseTxt__Loop

    :ParseTxt__State__LineNumber
      if "!isNumber!"=="T" (
        set "acc=!acc!!c!"
      ) else (
        call buffer toString a !acc!
        echo "LineNumber: !a!"
        set state=Normal
      )
    goto ParseTxt__Loop

  :ParseTxt__LoopEnd

  endlocal & set "%~1=%tokens%"
exit /b


:isNumber c
  setlocal EnableDelayedExpansion
  set "isNumber="
  if "!c!"=="30" set "isNumber=T"
  if "!c!"=="31" set "isNumber=T"
  if "!c!"=="32" set "isNumber=T"
  if "!c!"=="33" set "isNumber=T"
  if "!c!"=="34" set "isNumber=T"
  if "!c!"=="35" set "isNumber=T"
  if "!c!"=="36" set "isNumber=T"
  if "!c!"=="37" set "isNumber=T"
  if "!c!"=="38" set "isNumber=T"
  if "!c!"=="39" set "isNumber=T"
  endlocal && set "isNumber=%isNumber%"
exit /b

:isSpace c
  setlocal EnableDelayedExpansion
  set "isSpace="
  if "!c!"=="20" set "isSpace=T"
  endlocal && set "isSpace=%isSpace%"
exit /b
