@echo off
if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:check
  setlocal EnableDelayedExpansion
  set "v=%~1"
  if "!v:~8,1!" neq "" endlocal & exit /B 1
  set "h=!v:~0,4!"
  set "l=!v:~4,4!"
  if "!l:~3,1!"=="" endlocal & exit /B 1
  call _xword check !h!
  if errorlevel 1 endlocal & exit /B 1
  call _xword check !l!
  if errorlevel 1 endlocal & exit /B 1
  endlocal & exit /B 0


:inc
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "h=!v:~0,4!"
  set "l=!v:~4,4!"
  call _xword inc !l!
  set "l=!__!"
  set "c=!__c!"
  if "!c!"=="1" (
    call _xword inc !h!
    set "h=!__!"
    set "c=!__c!"
  ) else set "c="
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:dec
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "h=!v:~0,4!"
  set "l=!v:~4,4!"
  call _xword dec !l!
  set "l=!__!"
  set "c=!__c!"
  if "!c!"=="1" (
    call _xword dec !h!
    set "h=!__!"
    set "c=!__c!"
  ) else set "c="
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:add
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xword add !a:~4,4! !b:~4,4!
  set "rl=!__!"& set "c=!__c!"
  call _xword add !a:~0,4! !b:~0,4!
  set "rh=!__!"& set "c2=!__c!"
  if "!c!"=="1" (
    call _xword inc !rh!
    set "rh=!__!"
    if "!__c!"=="1" set "c2=1"
  )
  endlocal & set "__=%rh%%rl%" & set "__c=%c2%" & exit /B 0


:sub
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xword sub !a:~4,4! !b:~4,4!
  set "rl=!__!"& set "c=!__c!"
  call _xword sub !a:~0,4! !b:~0,4!
  set "rh=!__!"& set "c2=!__c!"
  if "!c!"=="1" (
    call _xword dec !rh!
    set "rh=!__!"
    if "!__c!"=="1" set "c2=1"
  )
  endlocal & set "__=%rh%%rl%" & set "__c=%c2%" & exit /B 0


:inv
  setlocal EnableDelayedExpansion
  set "v=%~1"
  call _xword xor !v:~0,4! FFFF
  set "h=!__!"
  call _xword xor !v:~4,4! FFFF
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:neg
  setlocal EnableDelayedExpansion
  call _xdword inv %~1
  set "r=!__!"
  call _xdword inc !r!
  endlocal & set "__=%__%" & set "__c=%__c%" & exit /B 0


:and
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xword and !a:~0,4! !b:~0,4!
  set "h=!__!"
  call _xword and !a:~4,4! !b:~4,4!
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:or
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xword or !a:~0,4! !b:~0,4!
  set "h=!__!"
  call _xword or !a:~4,4! !b:~4,4!
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:xor
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xword xor !a:~0,4! !b:~0,4!
  set "h=!__!"
  call _xword xor !a:~4,4! !b:~4,4!
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:shr
  setlocal EnableDelayedExpansion
  set "v=%~1"
  call _xword shr !v:~0,4!
  set "h=!__!"& set "hc=!__c!"
  call _xword shr !v:~4,4!
  set "l=!__!"& set "c=!__c!"
  if "!hc!"=="1" (
    call _xword add !l! 8000
    set "l=!__!"
  )
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:shl
  setlocal EnableDelayedExpansion
  set "v=%~1"
  call _xword shl !v:~4,4!
  set "l=!__!"& set "lc=!__c!"
  call _xword shl !v:~0,4!
  set "h=!__!"& set "c=!__c!"
  if "!lc!"=="1" (
    call _xword add !h! 0001
    set "h=!__!"
  )
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:_start
echo _start@xdword.bat
