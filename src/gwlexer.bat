@echo off
::
::  ParseTxt buffer &tokens
::
::  ParseBin buffer &tokens
::
if not "%~1"=="" shift & goto :%~1
goto :_start


:ParseTxt buffer tokens
  setlocal EnableDelayedExpansion
  :: 00 means last char
  set "buffer=%~100"
  set "tokens="
  set "error="
  set "i=0"
  set "state=Start"
  set "acc="

  goto :ParseTxt__Loop

  :ParseTxt__Loop
    set /a  ii = 2 * i
    set "c=!buffer:~%ii%,2!"
    if "!c!"=="" goto ParseTxt__LoopEnd
    set /a  i = i + 1

    call:isSpace !c!
    call:isNumber !c!
    call:isLetter !c!
    set "isEol="
    if "!c!"=="00" set "isEol=T"
    rem echo State=!state! char=!c! isNumber=!isNumber! isSpace=!isSpace!

    if "!state!"=="Start" goto :ParseTxt__State__Start
    if "!state!"=="Normal" goto :ParseTxt__State__Normal
    if "!state!"=="Id" goto :ParseTxt__State__Id
    if "!state!"=="LineNumber" goto :ParseTxt__State__LineNumber
    if "!state!"=="Number0" goto :ParseTxt__State__Number0
    if "!state!"=="Number1" goto :ParseTxt__State__Number1

    echo "Unknown state !state!: exit"
    goto :ParseTxt__LoopEnd

    :ParseTxt__State__Start
      if "!isEol!"=="T" goto ParseTxt__Loop
      if "!isSpace!"=="T" goto ParseTxt__Loop 
      if "!isNumber!"=="T" (
          set "state=LineNumber"
          set "acc="
          goto :ParseTxt__State__LineNumber
      )
      ( :: else
        set state=Normal
        goto :ParseTxt__State__Normal
      )

    :ParseTxt__State__Normal
      if "!isEol!"=="T" goto ParseTxt__Loop
      if "!isSpace!"=="T" goto ParseTxt__Loop
      if "!isLetter!"=="T" (
        set "state=Id"
        goto :ParseTxt__State__Id
      )
      if "!isNumber!"=="T" (
        set "state=Number0"
        goto :ParseTxt__State__Number0
      )
      if "!c!"=="28" (
        set "tokens=!tokens! OPAR"
        goto :ParseTxt__Loop  
      )
      if "!c!"=="29" (
        set "tokens=!tokens! CPAR"
        goto :ParseTxt__Loop  
      )
      if "!c!"=="2B" (
        set "tokens=!tokens! PLUS"
        goto :ParseTxt__Loop  
      )
      if "!c!"=="2C" (
        set "tokens=!tokens! COMA"
        goto :ParseTxt__Loop  
      )
      if "!c!"=="3A" (
        set "tokens=!tokens! COLON"
        goto :ParseTxt__Loop  
      )
      if "!c!"=="3D" (
        set "tokens=!tokens! EQ"
        goto :ParseTxt__Loop  
      )
      goto :ParseTxt__Error

    :ParseTxt__State__Number0
      if "!c!"=="2B" (
        set "acc=!acc!!c!"
        set "state=Number1"
        goto :ParseTxt__Loop  
      )
      if "!c!"=="2D" (
        set "acc=!acc!!c!"
        set "state=Number1"
        goto :ParseTxt__Loop  
      )
      if "!isNumber!"=="T" (
        set "state=Number1"
        goto :ParseTxt__State__Number1  
      )
      goto :ParseTxt__Error

    :ParseTxt__State__Number1
      if "!isNumber!"=="T" (
        set "acc=!acc!!c!"
        goto :ParseTxt__Loop  
      )
      ( :: else
        call buffer toString !acc! id
        set "acc="
        set "tokens=!tokens! NUM_!id!"
        set "state=Normal"
        goto :ParseTxt__State__Normal
      )

    :ParseTxt__State__Id
      if "!isLetter!"=="T" (
        set "acc=!acc!!c!"
        goto :ParseTxt__Loop
      )
      ( :: else
        call buffer toString !acc! id
        set "acc="
        set "tokens=!tokens! ID__!id!"
        set "state=Normal"
        goto :ParseTxt__State__Normal
      )

    :ParseTxt__State__LineNumber
      if "!isNumber!"=="T" (
        set "acc=!acc!!c!"
        goto ParseTxt__Loop
      )
      ( :: else
        call buffer toString !acc! lineNumber
        set "acc="
        set "tokens=!tokens! LN__!lineNumber!"
        set "state=Normal"
        goto :ParseTxt__State__Normal
      )

    :ParseTxt__Error
      echo "tokens=%tokens%"
      call buffer toString !buffer! wholeLine
      echo "LEXER ERROR:
      echo "LEXER ERROR: !wholeLine!"
      echo "LEXER ERROR: state=%state%: undefined char !c! at index !i!"
      echo "LEXER ERROR:
      exit /b 1

  :ParseTxt__LoopEnd

  endlocal && if "%~2"=="" (
    echo tokens=%tokens:~1%
  ) else (
    set "%~2=%tokens:~1%"
  )
exit /b


:isNumber c
  set "isNumber="
  set "isNumber="
  if "%~1" GEQ "30" (
    if "%~1" LEQ "39" set "isNumber=T"
  )
exit /b


:isSpace c
  set "isSpace="
  if "%~1"=="20" set "isSpace=T"
exit /b


:isLetter c
  call:isUppercaseLetter %~1
  call:isLowercaseLetter %~1
  set "isLetter="
  if "!isUppercaseLetter!"=="T" set "isLetter=T"
  if "!isLowercaseLetter!"=="T" set "isLetter=T"
exit /b

:isUppercaseLetter C
  set "isUppercaseLetter="
  if "%~1" GEQ "41" (
    if "%~1" LEQ "5A" set "isUppercaseLetter=T"
  )
exit /b


:isLowercaseLetter
  set "isLowercaseLetter="
  if "%~1" GEQ "61" (
    if "%~1" LEQ "7A" set "isLowercaseLetter=T"
  )
exit /b


:_start
  setlocal DisableDelayedExpansion
  set PATH=%~dp0;%~dp0..\lib;%PATH%

  ::                 6 5   D I M   H ( M A X F R A M E   +   1 ,   P O I N T S ,   2 ) 
  set "buffer=20202036352044494D2048284D41584652414D45202B20312C20504F494E54532C20322920"
  echo "   65 DIM H(MAXFRAME + 1, POINTS, 2)" 
  call:ParseTxt %buffer%
  endlocal

:isSpace c
  setlocal EnableDelayedExpansion
  set "isSpace="
  if "!c!"=="20" set "isSpace=T"
  endlocal && set "isSpace=%isSpace%"
exit /b