@echo off
if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:check v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  if "!v:~2,1!" neq "" endlocal & exit /B 1
  set "h=!v:~0,1!"
  set "l=!v:~1,1!"
  if "!l!"=="" endlocal & exit /B 1
  call _xhalf check !h!
  if errorlevel 1 endlocal & exit /B 1
  call _xhalf check !l!
  if errorlevel 1 endlocal & exit /B 1
  endlocal & exit /B 0


:inc v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "h=!v:~0,1!"
  set "l=!v:~1,1!"
  call _xhalf inc !l!
  set "l=!__!"
  set "c=!__c!"
  call _xhalf addc !h! !c!
  set "h=!__!"
  set "c=!__c!"
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:dec v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "h=!v:~0,1!"
  set "l=!v:~1,1!"
  call _xhalf dec !l!
  set "l=!__!"
  set "c=!__c!"
  call _xhalf subc !h! !c!
  set "h=!__!"
  set "c=!__c!"
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:add
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xhalf add !a:~1,1! !b:~1,1!
  set "rl=!__!"
  set "c=!__c!"
  call _xhalf add !a:~0,1! !b:~0,1!
  set "rh=!__!"
  set "c2=!__c!"
  call _xhalf addc !rh! !c!
  set "rh=!__!"
  if "!__c!"=="1" set "c2=1"
  endlocal & set "__=%rh%%rl%" & set "__c=%c2%" & exit /B 0


:sub
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xhalf sub !a:~1,1! !b:~1,1!
  set "rl=!__!"
  set "c=!__c!"
  call _xhalf sub !a:~0,1! !b:~0,1!
  set "rh=!__!"
  set "c2=!__c!"
  call _xhalf subc !rh! !c!
  set "rh=!__!"
  if "!__c!"=="1" set "c2=1"
  endlocal & set "__=%rh%%rl%" & set "__c=%c2%" & exit /B 0


:mul
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  set "ah=!a:~0,1!"& set "al=!a:~1,1!"
  set "bh=!b:~0,1!"& set "bl=!b:~1,1!"
  @REM al*bl -> byte
  call _xhalf mul !al! !bl!
  set "r1=!__!"
  @REM al*bh -> byte, shifted left 4 bits
  call _xhalf mul !al! !bh!
  set "r2=!__!"
  @REM ah*bl -> byte, shifted left 4 bits
  call _xhalf mul !ah! !bl!
  set "r3=!__!"
  @REM result low = r1 low nibble
  set "rl=!r1:~1,1!"
  @REM result high = r1.hi + r2.lo + r3.lo
  set "rh=!r1:~0,1!"
  call _xhalf add !rh! !r2:~1,1!
  set "rh=!__!"& set "ov=!__c!"
  call _xhalf add !rh! !r3:~1,1!
  set "rh=!__!"
  if "!__c!"=="1" set "ov=1"
  @REM overflow nibble2 = r2.hi + r3.hi + r4.lo + carry_from_nibble1
  call _xhalf mul !ah! !bh!
  set "r4=!__!"
  set "cy=0"
  set "n2=!r2:~0,1!"
  call _xhalf add !n2! !r3:~0,1!
  set "n2=!__!"
  if "!__c!"=="1" (call _xhalf inc !cy! & set "cy=!__!")
  call _xhalf add !n2! !r4:~1,1!
  set "n2=!__!"
  if "!__c!"=="1" (call _xhalf inc !cy! & set "cy=!__!")
  call _xhalf addc !n2! !ov!
  set "n2=!__!"
  if "!__c!"=="1" (call _xhalf inc !cy! & set "cy=!__!")
  @REM overflow nibble3 = r4.hi + carries
  call _xhalf add !r4:~0,1! !cy!
  set "n3=!__!"
  endlocal & set "__=%rh%%rl%" & set "__h=%n3%%n2%" & exit /B 0


:inv v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  call _xhalf xor !v:~0,1! F
  set "h=!__!"
  call _xhalf xor !v:~1,1! F
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:and
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xhalf and !a:~0,1! !b:~0,1!
  set "h=!__!"
  call _xhalf and !a:~1,1! !b:~1,1!
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:or
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xhalf or !a:~0,1! !b:~0,1!
  set "h=!__!"
  call _xhalf or !a:~1,1! !b:~1,1!
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:xor
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xhalf xor !a:~0,1! !b:~0,1!
  set "h=!__!"
  call _xhalf xor !a:~1,1! !b:~1,1!
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:shr v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  call _xhalf shr !v:~0,1!
  set "h=!__!"& set "hc=!__c!"
  call _xhalf shr !v:~1,1!
  set "l=!__!"& set "c=!__c!"
  if "!hc!"=="1" (
    call _xhalf add !l! 8
    set "l=!__!"
  )
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:shl v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  call _xhalf shl !v:~1,1!
  set "l=!__!"& set "lc=!__c!"
  call _xhalf shl !v:~0,1!
  set "h=!__!"& set "c=!__c!"
  if "!lc!"=="1" (
    call _xhalf add !h! 1
    set "h=!__!"
  )
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:_start
echo _start@xbyte.bat
