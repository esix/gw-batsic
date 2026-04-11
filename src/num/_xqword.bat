@echo off
if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:check
  setlocal EnableDelayedExpansion
  set "v=%~1"
  if "!v:~16,1!" neq "" endlocal & exit /B 1
  set "h=!v:~0,8!"
  set "l=!v:~8,8!"
  if "!l:~7,1!"=="" endlocal & exit /B 1
  call _xdword check !h!
  if errorlevel 1 endlocal & exit /B 1
  call _xdword check !l!
  if errorlevel 1 endlocal & exit /B 1
  endlocal & exit /B 0


:inc
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "h=!v:~0,8!"
  set "l=!v:~8,8!"
  call _xdword inc !l!
  set "l=!__!"
  set "c=!__c!"
  if "!c!"=="1" (
    call _xdword inc !h!
    set "h=!__!"
    set "c=!__c!"
  ) else set "c="
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:dec
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "h=!v:~0,8!"
  set "l=!v:~8,8!"
  call _xdword dec !l!
  set "l=!__!"
  set "c=!__c!"
  if "!c!"=="1" (
    call _xdword dec !h!
    set "h=!__!"
    set "c=!__c!"
  ) else set "c="
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:add
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xdword add !a:~8,8! !b:~8,8!
  set "rl=!__!"& set "c=!__c!"
  call _xdword add !a:~0,8! !b:~0,8!
  set "rh=!__!"& set "c2=!__c!"
  if "!c!"=="1" (
    call _xdword inc !rh!
    set "rh=!__!"
    if "!__c!"=="1" set "c2=1"
  )
  endlocal & set "__=%rh%%rl%" & set "__c=%c2%" & exit /B 0


:sub
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xdword sub !a:~8,8! !b:~8,8!
  set "rl=!__!"& set "c=!__c!"
  call _xdword sub !a:~0,8! !b:~0,8!
  set "rh=!__!"& set "c2=!__c!"
  if "!c!"=="1" (
    call _xdword dec !rh!
    set "rh=!__!"
    if "!__c!"=="1" set "c2=1"
  )
  endlocal & set "__=%rh%%rl%" & set "__c=%c2%" & exit /B 0


:inv
  setlocal EnableDelayedExpansion
  set "v=%~1"
  call _xdword xor !v:~0,8! FFFFFFFF
  set "h=!__!"
  call _xdword xor !v:~8,8! FFFFFFFF
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:neg
  setlocal EnableDelayedExpansion
  call _xqword inv %~1
  set "r=!__!"
  call _xqword inc !r!
  endlocal & set "__=%__%" & set "__c=%__c%" & exit /B 0


:and
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xdword and !a:~0,8! !b:~0,8!
  set "h=!__!"
  call _xdword and !a:~8,8! !b:~8,8!
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:or
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xdword or !a:~0,8! !b:~0,8!
  set "h=!__!"
  call _xdword or !a:~8,8! !b:~8,8!
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:xor
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xdword xor !a:~0,8! !b:~0,8!
  set "h=!__!"
  call _xdword xor !a:~8,8! !b:~8,8!
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:shr
  setlocal EnableDelayedExpansion
  set "v=%~1"
  call _xdword shr !v:~0,8!
  set "h=!__!"& set "hc=!__c!"
  call _xdword shr !v:~8,8!
  set "l=!__!"& set "c=!__c!"
  if "!hc!"=="1" (
    call _xdword add !l! 80000000
    set "l=!__!"
  )
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:shl
  setlocal EnableDelayedExpansion
  set "v=%~1"
  call _xdword shl !v:~8,8!
  set "l=!__!"& set "lc=!__c!"
  call _xdword shl !v:~0,8!
  set "h=!__!"& set "c=!__c!"
  if "!lc!"=="1" (
    call _xdword add !h! 00000001
    set "h=!__!"
  )
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:_start
echo _start@xqword.bat
