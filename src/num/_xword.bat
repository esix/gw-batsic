@echo off
@REM Hex-to-decimal / decimal-to-hex lookup (for conversion functions)
set "_s_0=0"& set "_s_1=1"& set "_s_2=2"& set "_s_3=3"& set "_s_4=4"& set "_s_5=5"& set "_s_6=6"& set "_s_7=7"
set "_s_8=8"& set "_s_9=9"& set "_s_A=10"& set "_s_B=11"& set "_s_C=12"& set "_s_D=13"& set "_s_E=14"& set "_s_F=15"
set "_p_0=0"& set "_p_1=1"& set "_p_2=2"& set "_p_3=3"& set "_p_4=4"& set "_p_5=5"& set "_p_6=6"& set "_p_7=7"
set "_p_8=8"& set "_p_9=9"& set "_p_10=A"& set "_p_11=B"& set "_p_12=C"& set "_p_13=D"& set "_p_14=E"& set "_p_15=F"
if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:check v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  if "!v:~4,1!" neq "" endlocal & exit /B 1
  set "h=!v:~0,2!"
  set "l=!v:~2,2!"
  if "!l:~1,1!"=="" endlocal & exit /B 1
  call _xbyte check !h!
  if errorlevel 1 endlocal & exit /B 1
  call _xbyte check !l!
  if errorlevel 1 endlocal & exit /B 1
  endlocal & exit /B 0


:inc v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "h=!v:~0,2!"
  set "l=!v:~2,2!"
  call _xbyte inc !l!
  set "l=!__!"
  set "c=!__c!"
  if "!c!"=="1" (
    call _xbyte inc !h!
    set "h=!__!"
    set "c=!__c!"
  ) else set "c="
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:dec v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "h=!v:~0,2!"
  set "l=!v:~2,2!"
  call _xbyte dec !l!
  set "l=!__!"
  set "c=!__c!"
  if "!c!"=="1" (
    call _xbyte dec !h!
    set "h=!__!"
    set "c=!__c!"
  ) else set "c="
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:add
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xbyte add !a:~2,2! !b:~2,2!
  set "rl=!__!"& set "c=!__c!"
  call _xbyte add !a:~0,2! !b:~0,2!
  set "rh=!__!"& set "c2=!__c!"
  if "!c!"=="1" (
    call _xbyte inc !rh!
    set "rh=!__!"
    if "!__c!"=="1" set "c2=1"
  )
  endlocal & set "__=%rh%%rl%" & set "__c=%c2%" & exit /B 0


:sub
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xbyte sub !a:~2,2! !b:~2,2!
  set "rl=!__!"& set "c=!__c!"
  call _xbyte sub !a:~0,2! !b:~0,2!
  set "rh=!__!"& set "c2=!__c!"
  if "!c!"=="1" (
    call _xbyte dec !rh!
    set "rh=!__!"
    if "!__c!"=="1" set "c2=1"
  )
  endlocal & set "__=%rh%%rl%" & set "__c=%c2%" & exit /B 0


:inv v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  call _xbyte xor !v:~0,2! FF
  set "h=!__!"
  call _xbyte xor !v:~2,2! FF
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:and
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xbyte and !a:~0,2! !b:~0,2!
  set "h=!__!"
  call _xbyte and !a:~2,2! !b:~2,2!
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:or
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xbyte or !a:~0,2! !b:~0,2!
  set "h=!__!"
  call _xbyte or !a:~2,2! !b:~2,2!
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:xor
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  call _xbyte xor !a:~0,2! !b:~0,2!
  set "h=!__!"
  call _xbyte xor !a:~2,2! !b:~2,2!
  set "l=!__!"
  endlocal & set "__=%h%%l%" & exit /B 0


:shr v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  call _xbyte shr !v:~0,2!
  set "h=!__!"& set "hc=!__c!"
  call _xbyte shr !v:~2,2!
  set "l=!__!"& set "c=!__c!"
  if "!hc!"=="1" (
    call _xbyte add !l! 80
    set "l=!__!"
  )
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


:shl v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  call _xbyte shl !v:~2,2!
  set "l=!__!"& set "lc=!__c!"
  call _xbyte shl !v:~0,2!
  set "h=!__!"& set "c=!__c!"
  if "!lc!"=="1" (
    call _xbyte add !h! 01
    set "h=!__!"
  )
  endlocal & set "__=%h%%l%" & set "__c=%c%" & exit /B 0


@REM === Conversion: set /a at the boundary between decimal and hex ===

:fromDec dec
  setlocal EnableDelayedExpansion
  set /a "d=%~1" 2>nul
  if !d! LSS -32768 endlocal & exit /B 1
  if !d! GTR 32767 endlocal & exit /B 1
  if !d! LSS 0 set /a "d=65536+d"
  set /a "h3=d/4096"& set /a "d=d%%4096"
  set /a "h2=d/256"& set /a "d=d%%256"
  set /a "h1=d/16"& set /a "h0=d%%16"
  set "r=!_p_%h3%!!_p_%h2%!!_p_%h1%!!_p_%h0%!"
  endlocal & set "__=%r%" & exit /B 0


:toDec v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "h3=!v:~0,1!"& set "h2=!v:~1,1!"& set "h1=!v:~2,1!"& set "h0=!v:~3,1!"
  set /a "d=!_s_%h3%!*4096+!_s_%h2%!*256+!_s_%h1%!*16+!_s_%h0%!"
  if !d! GEQ 32768 set /a "d=d-65536"
  endlocal & set "__=%d%" & exit /B 0


:neg v
  setlocal EnableDelayedExpansion
  call _xword inv %~1
  set "r=!__!"
  call _xword inc !r!
  endlocal & set "__=%__%" & set "__c=%__c%" & exit /B 0


@REM === Unsigned multiplication: 16x16 -> 32 bit ===
@REM Returns low word in __, high word in __h

:mul
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  set "ah=!a:~0,2!"& set "al=!a:~2,2!"
  set "bh=!b:~0,2!"& set "bl=!b:~2,2!"
  @REM P0 = AL * BL
  call _xbyte mul !al! !bl!
  set "p0l=!__!"& set "p0h=!__h!"
  @REM P1 = AH * BL
  call _xbyte mul !ah! !bl!
  set "p1l=!__!"& set "p1h=!__h!"
  @REM P2 = AL * BH
  call _xbyte mul !al! !bh!
  set "p2l=!__!"& set "p2h=!__h!"
  @REM P3 = AH * BH
  call _xbyte mul !ah! !bh!
  set "p3l=!__!"& set "p3h=!__h!"
  @REM R0 = P0L (result low byte)
  set "r0=!p0l!"
  @REM R1 = P0H + P1L + P2L (result high byte, carries propagate up)
  call _xbyte add !p0h! !p1l!
  set "r1=!__!"& set "c1=!__c!"
  call _xbyte add !r1! !p2l!
  set "r1=!__!"& set "c2=!__c!"
  @REM R2 = P1H + P2H + P3L + carries from R1
  call _xbyte add !p1h! !p2h!
  set "r2=!__!"& set "c3=!__c!"
  call _xbyte add !r2! !p3l!
  set "r2=!__!"& set "c4=!__c!"
  if "!c1!"=="1" (call _xbyte inc !r2! & set "r2=!__!"& if "!__c!"=="1" set "c4=1")
  if "!c2!"=="1" (call _xbyte inc !r2! & set "r2=!__!"& if "!__c!"=="1" set "c4=1")
  @REM R3 = P3H + carries from R2
  set "r3=!p3h!"
  if "!c3!"=="1" (call _xbyte inc !r3! & set "r3=!__!")
  if "!c4!"=="1" (call _xbyte inc !r3! & set "r3=!__!")
  endlocal & set "__=%r1%%r0%" & set "__h=%r3%%r2%" & exit /B 0


@REM === Unsigned division: 16-bit / 16-bit -> quotient + remainder ===
@REM Binary long division. Returns quotient in __, remainder in __r.

:div
  setlocal EnableDelayedExpansion
  set "dend=%~1"
  set "dsor=%~2"
  if "!dsor!"=="0000" endlocal & exit /B 11
  set "q=0000"
  set "r=0000"
  set "_i=0123456789ABCDEF"
:_div_loop
  if "!_i!"=="" goto :_div_done
  set "_i=!_i:~1!"
  @REM Shift dividend left, MSB into carry
  call _xword shl !dend!
  set "dend=!__!"& set "msb=!__c!"
  @REM Shift remainder left, insert MSB
  call _xword shl !r!
  set "r=!__!"
  if "!msb!"=="1" (call _xword inc !r! & set "r=!__!")
  @REM Shift quotient left
  call _xword shl !q!
  set "q=!__!"
  @REM If remainder >= divisor: subtract and set quotient bit 0
  call _xword sub !r! !dsor!
  if "!__c!" neq "1" (
    set "r=!__!"
    call _xword inc !q!
    set "q=!__!"
  )
  goto :_div_loop
:_div_done
  endlocal & set "__=%q%" & set "__r=%r%" & exit /B 0


@REM === Signed multiplication ===
@REM Returns low word in __, high word in __h.

:smul
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  set "s=0"
  @REM Negate if negative (high nibble >= 8)
  for %%c in (8 9 A B C D E F) do (
    if "!a:~0,1!"=="%%c" (call _xword neg !a! & set "a=!__!"& set /a "s=s+1")
    if "!b:~0,1!"=="%%c" (call _xword neg !b! & set "b=!__!"& set /a "s=s+1")
  )
  call _xword mul !a! !b!
  set "rl=!__!"& set "rh=!__h!"
  @REM Negate result if signs differ (s is odd)
  set /a "s=s%%2"
  if !s!==1 (
    @REM Negate 32-bit result: inv both words, inc low, if carry inc high
    call _xword inv !rl!
    set "rl=!__!"
    call _xword inv !rh!
    set "rh=!__!"
    call _xword inc !rl!
    set "rl=!__!"
    if "!__c!"=="1" (call _xword inc !rh! & set "rh=!__!")
  )
  endlocal & set "__=%rl%" & set "__h=%rh%" & exit /B 0


@REM === Signed division ===
@REM Returns quotient in __, remainder in __r.

:sdiv
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  set "sq=0"& set "sr=0"
  for %%c in (8 9 A B C D E F) do (
    if "!a:~0,1!"=="%%c" (call _xword neg !a! & set "a=!__!"& set /a "sq=sq+1"& set "sr=1")
    if "!b:~0,1!"=="%%c" (call _xword neg !b! & set "b=!__!"& set /a "sq=sq+1")
  )
  call _xword div !a! !b!
  set "q=!__!"& set "r=!__r!"
  set /a "sq=sq%%2"
  if !sq!==1 (call _xword neg !q! & set "q=!__!")
  if "!sr!"=="1" (call _xword neg !r! & set "r=!__!")
  endlocal & set "__=%q%" & set "__r=%r%" & exit /B 0


:_start
echo _start@xword.bat
