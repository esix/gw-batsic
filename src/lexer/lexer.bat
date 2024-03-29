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
  set tokens=
  set error=
  set i=0
  set state=Start
  set acc=

  goto :ParseTxt__Loop

  :ParseTxt__Loop
    set /a  ii = 2 * i
    set "c=!buffer:~%ii%,2!"
    if "!c!"=="" goto ParseTxt__LoopEnd
    set /a  i = i + 1

    call:isSpace !c!
    call:isNumber !c!
    call:isLetter !c!
    set isEol=
    if !c!==00 set isEol=T
    rem echo State=!state! char=!c! isNumber=!isNumber! isSpace=!isSpace!

    if "!state!"=="Start" goto :ParseTxt__State__Start
    if "!state!"=="Normal" goto :ParseTxt__State__Normal
    if "!state!"=="Id" goto :ParseTxt__State__Id
    if "!state!"=="LineNumber" goto :ParseTxt__State__LineNumber
    if "!state!"=="Number0" goto :ParseTxt__State__Number0
    if "!state!"=="Number1" goto :ParseTxt__State__Number1
    if "!state!"=="Number2" goto :ParseTxt__State__Number2
    if "!state!"=="Less" goto :ParseTxt__State__Less
    if "!state!"=="More" goto :ParseTxt__State__More
    if "!state!"=="Quote" goto :ParseTxt__State__Quote
    if "!state!"=="Rem" goto :ParseTxt__State__Rem

    echo "Unknown state !state!: exit"
    goto :ParseTxt__Error

    :ParseTxt__State__Start
      if defined isEol goto :ParseTxt__Loop
      if defined isSpace goto :ParseTxt__Loop
      if defined isNumber (
        set state=LineNumber
        set acc=
        goto :ParseTxt__State__LineNumber
      )
      ( :: else
        set state=Normal
        goto :ParseTxt__State__Normal
      )

    :ParseTxt__State__Normal
      if defined isEol goto :ParseTxt__Loop
      if defined isSpace goto :ParseTxt__Loop
      if defined isLetter (
        set state=Id
        set acc=
        goto :ParseTxt__State__Id
      )
      if defined isNumber (
        set state=Number0
        set acc=
        goto :ParseTxt__State__Number0
      )
      if !c!==22 (
        set state=Quote
        set acc=
        goto :ParseTxt__Loop
      )
      if !c!==28 (
        set tokens=!tokens! OPAR
        goto :ParseTxt__Loop
      )
      if !c!==29 (
        set tokens=!tokens! CPAR
        goto :ParseTxt__Loop
      )
      if !c!==2A (
        set tokens=!tokens! MUL
        goto :ParseTxt__Loop
      )
      if !c!==2B (
        set tokens=!tokens! PLUS
        goto :ParseTxt__Loop
      )
      if !c!==2C (
        set tokens=!tokens! COMA
        goto :ParseTxt__Loop
      )
      if !c!==2D (
        set tokens=!tokens! MINUS
        goto :ParseTxt__Loop
      )
      if !c!==2E (
        set acc=.
        set state=Number2
        goto :ParseTxt__Loop
      )
      if !c!==2F (
        set tokens=!tokens! DIV
        goto :ParseTxt__Loop
      )
      if !c!==3A (
        set tokens=!tokens! COLON
        goto :ParseTxt__Loop
      )
      if !c!==3B (
        set tokens=!tokens! SEMICOLON
        goto :ParseTxt__Loop
      )
      if !c!==3C (
        set state=Less
        goto :ParseTxt__Loop
      )
      if !c!==3D (
        set tokens=!tokens! EQ
        goto :ParseTxt__Loop
      )
      if !c!==3E (
        set state=More
        goto :ParseTxt__Loop
      )
      goto :ParseTxt__Error

    :ParseTxt__State__Id
      if defined isLetter (
        call byte ByteToDec !c! dec
        call chr FromAscii !dec! char
        set acc=!acc!!char!
        goto :ParseTxt__Loop
      )
      if !c!==24 (
        call %GWSRC%\lexer\keyword isKeywordStr !acc!
        if ERRORLEVEL 1 (
          set acc=VAR_STR_!acc!
        ) else (
          set acc=!acc!_STR
        )
        set tokens=!tokens! !acc!
        set state=Normal
        set acc=
        goto :ParseTxt__Loop
      )
      ( :: else
        call %GWSRC%\lexer\keyword isKeyword !acc!
        if ERRORLEVEL 1 set acc=VAR_UNK_!acc!
        set tokens=!tokens! !acc!
        if "!acc!"=="REM" (
          set state=Rem
        ) else ( 
          set state=Normal
        )
        set acc=
        goto :ParseTxt__State__Normal
      )

    :ParseTxt__State__LineNumber
      if defined isNumber (
        set acc=!acc!!c!
        goto :ParseTxt__Loop
      )
      ( :: else
        call buffer decode !acc! lineNumber
        set tokens=!tokens! LN__!lineNumber!
        set acc=
        set state=Normal
        goto :ParseTxt__State__Normal
      )

    :ParseTxt__State__Number0
      if !c!==2B (
        set acc=!acc!+
        set state=Number1
        goto :ParseTxt__Loop
      )
      if !c!==2D (
        set acc=!acc!-
        set state=Number1
        goto :ParseTxt__Loop
      )
      if !c!==2E (
        set acc=!acc!.
        set state=Number2
        goto :ParseTxt__Loop
      )
      if defined isNumber (
        set acc=
        set state=Number1
        goto :ParseTxt__State__Number1  
      )
      goto :ParseTxt__Error

    :ParseTxt__State__Number1
      if defined isNumber (
        call byte ByteToDec !c! dec
        call chr FromAscii !dec! digit
        set acc=!acc!!digit!
        goto :ParseTxt__Loop
      )
      if !c!==2E (
        set acc=!acc!.
        set state=Number2
        goto :ParseTxt__Loop
      )
      ( :: else
        set tokens=!tokens! NUM_!acc!
        set acc=
        set state=Normal
        goto :ParseTxt__State__Normal
      )

    :ParseTxt__State__Number2
      if defined isNumber (
        call byte ByteToDec !c! dec
        call chr FromAscii !dec! digit
        set acc=!acc!!digit!
        goto :ParseTxt__Loop
      )
      ( :: else
        set tokens=!tokens! NUM_!acc!
        set acc=
        set state=Normal
        goto :ParseTxt__State__Normal
      )

    :ParseTxt__State__Less
      if !c!==3D (
        set tokens=!tokens! LE
        set state=Normal
        goto :ParseTxt__Loop
      )
      if !c!==3E (
        set tokens=!tokens! NE
        set state=Normal
        goto :ParseTxt__Loop
      )
      ( :: else
        set tokens=!tokens! LT
        set state=Normal
        goto :ParseTxt__State__Normal
      )

    :ParseTxt__State__More
      if !c!==3D (
        set tokens=!tokens! GE
        set state=Normal
        goto :ParseTxt__Loop
      )
      ( :: else
        set tokens=!tokens! GT
        set state=Normal
        goto :ParseTxt__State__Normal
      )

    :ParseTxt__State__Quote
      if !c!==22 (
        set tokens=!tokens! STR_!acc!
        set acc=
        set state=Normal
        goto :ParseTxt__Loop
      )
      if defined isEol (
        set tokens=!tokens! STR_!acc!
        set acc=
        set state=Normal
        goto :ParseTxt__Loop
      ) 
      ( :: else
        set acc=!acc!!c!
        goto :ParseTxt__Loop
      )

    :ParseTxt__State__Rem
      if defined isEol (
        set tokens=!tokens! REM_!acc!
        set acc=
        set state=Normal
        goto :ParseTxt__Loop
      ) 
      ( :: else
        set acc=!acc!!c!
        goto :ParseTxt__Loop
      )

  :ParseTxt__LoopEnd

  if "!state!" NEQ "Normal" goto :ParseTxt__Error

  endlocal && if "%~2"=="" (
    echo tokens=%tokens:~1%
  ) else (
    set "%~2=%tokens:~1%"
  )
  exit /b 0

  :ParseTxt__Error
    echo "tokens=%tokens%"
    call buffer decode !buffer! wholeLine
    echo "LEXER ERROR:
    echo "LEXER ERROR: !wholeLine!"
    echo "LEXER ERROR: state=%state%: undefined char !c! at index !i!"
    echo "LEXER ERROR:
    endlocal && set "%~2=%tokens:~1%"
  exit /b 2



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
  set isLetter=
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

