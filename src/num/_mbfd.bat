@echo off
@REM Lookup tables for decimal conversion
set "_s_0=0"& set "_s_1=1"& set "_s_2=2"& set "_s_3=3"& set "_s_4=4"& set "_s_5=5"& set "_s_6=6"& set "_s_7=7"
set "_s_8=8"& set "_s_9=9"& set "_s_A=10"& set "_s_B=11"& set "_s_C=12"& set "_s_D=13"& set "_s_E=14"& set "_s_F=15"
set "_p_0=0"& set "_p_1=1"& set "_p_2=2"& set "_p_3=3"& set "_p_4=4"& set "_p_5=5"& set "_p_6=6"& set "_p_7=7"
set "_p_8=8"& set "_p_9=9"& set "_p_10=A"& set "_p_11=B"& set "_p_12=C"& set "_p_13=D"& set "_p_14=E"& set "_p_15=F"
@REM MBF Double precision internals (8 bytes = 16 hex chars = xqword)
@REM Layout (big-endian): EE SM MM MM MM MM MM MM
@REM   EE = exponent (biased 128). EE=00 means zero.
@REM   S  = sign bit (bit 7 of byte 6)
@REM   M  = 55-bit mantissa fraction (implied leading 1)
@REM   Value = (-1)^S * 1.mantissa * 2^(EE - 128)
@REM   Full mantissa as qword: 00XXXXXXXXXXXXXX (bit 55 = implied 1)

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:isZero
  setlocal EnableDelayedExpansion
  set "v=%~1"
  if "!v:~0,2!"=="00" (endlocal & set "__=1" & exit /B 0)
  endlocal & set "__=" & exit /B 0


:neg
  setlocal EnableDelayedExpansion
  set "v=%~1"
  if "!v:~0,2!"=="00" (endlocal & set "__=%~1" & exit /B 0)
  set "e=!v:~0,2!"& set "b=!v:~2,2!"& set "lo=!v:~4,12!"
  call _xbyte xor !b! 80
  endlocal & set "__=%e%%__%%lo%" & exit /B 0


:abs
  setlocal EnableDelayedExpansion
  set "v=%~1"
  if "!v:~0,2!"=="00" (endlocal & set "__=%~1" & exit /B 0)
  set "e=!v:~0,2!"& set "b=!v:~2,2!"& set "lo=!v:~4,12!"
  call _xbyte and !b! 7F
  endlocal & set "__=%e%%__%%lo%" & exit /B 0


:getMant
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "b=!v:~2,2!"& set "lo=!v:~4,12!"
  call _xbyte or !b! 80
  endlocal & set "__=00%__%%lo%" & exit /B 0


:pack
  setlocal EnableDelayedExpansion
  set "e=%~1"& set "s=%~2"& set "m=%~3"
  if "!e!"=="00" (endlocal & set "__=0000000000000000" & exit /B 0)
  set "b=!m:~2,2!"& set "lo=!m:~4,12!"
  call _xbyte and !b! 7F
  set "b=!__!"
  if "!s!"=="1" (call _xbyte or !b! 80 & set "b=!__!")
  endlocal & set "__=%e%%b%%lo%" & exit /B 0


:normalize
  setlocal EnableDelayedExpansion
  set "e=%~1"& set "m=%~2"
  if "!m!"=="0000000000000000" (endlocal & set "__=0000000000000000" & set "__e=00" & exit /B 0)
  set "_cnt=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwx"
:_norm_loop
  set "_ch=!m:~2,1!"
  for %%c in (8 9 A B C D E F) do if "!_ch!"=="%%c" goto :_norm_done
  call _xqword shl !m!
  set "m=!__!"
  call _xbyte dec !e!
  set "e=!__!"
  if "!e!"=="00" (endlocal & set "__=0000000000000000" & set "__e=00" & exit /B 0)
  set "_cnt=!_cnt:~1!"
  if "!_cnt!"=="" goto :_norm_done
  goto :_norm_loop
:_norm_done
  endlocal & set "__=%m%" & set "__e=%e%" & exit /B 0


:cmp
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  set "az="& set "bz="
  if "!a:~0,2!"=="00" set "az=1"
  if "!b:~0,2!"=="00" set "bz=1"
  if "!az!"=="1" if "!bz!"=="1" (endlocal & set "__=0" & exit /B 0)
  set "sa=0"& set "sb=0"
  for %%c in (8 9 A B C D E F) do (
    if "!a:~2,1!"=="%%c" set "sa=1"
    if "!b:~2,1!"=="%%c" set "sb=1"
  )
  if "!az!"=="1" (
    if "!sb!"=="1" (endlocal & set "__=1" & exit /B 0)
    endlocal & set "__=2" & exit /B 0
  )
  if "!bz!"=="1" (
    if "!sa!"=="1" (endlocal & set "__=2" & exit /B 0)
    endlocal & set "__=1" & exit /B 0
  )
  if "!sa!" neq "!sb!" (
    if "!sa!"=="1" (endlocal & set "__=2" & exit /B 0)
    endlocal & set "__=1" & exit /B 0
  )
  call _mbfd abs !a!
  set "aa=!__!"
  call _mbfd abs !b!
  set "ab=!__!"
  call _xqword sub !aa! !ab!
  set "r=!__!"& set "c=!__c!"
  if "!r!"=="0000000000000000" if "!c!" neq "1" (endlocal & set "__=0" & exit /B 0)
  set "mag=1"
  if "!c!"=="1" set "mag=2"
  if "!sa!"=="1" (
    set "_i_1=2"& set "_i_2=1"
    set "mag=!_i_%mag%!"
  )
  endlocal & set "__=%mag%" & exit /B 0


:add
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,2!"=="00" (endlocal & set "__=%~2" & exit /B 0)
  if "!b:~0,2!"=="00" (endlocal & set "__=%~1" & exit /B 0)
  set "ea=!a:~0,2!"& set "eb=!b:~0,2!"
  set "sa=0"& set "sb=0"
  for %%c in (8 9 A B C D E F) do (
    if "!a:~2,1!"=="%%c" set "sa=1"
    if "!b:~2,1!"=="%%c" set "sb=1"
  )
  call _mbfd getMant !a!
  set "ma=!__!"
  call _mbfd getMant !b!
  set "mb=!__!"
  call _xbyte sub !ea! !eb!
  set "diff=!__!"
  if "!__c!" neq "1" goto :_add_ord
  set "_t=!ea!"& set "ea=!eb!"& set "eb=!_t!"
  set "_t=!sa!"& set "sa=!sb!"& set "sb=!_t!"
  set "_t=!ma!"& set "ma=!mb!"& set "mb=!_t!"
  call _xbyte sub !ea! !eb!
  set "diff=!__!"
:_add_ord
  call _xbyte sub !diff! 39
  if "!__c!" neq "1" goto :_add_ret_a
:_add_align
  if "!diff!"=="00" goto :_add_go
  call _xqword shr !mb!
  set "mb=!__!"
  call _xbyte dec !diff!
  set "diff=!__!"
  goto :_add_align
:_add_go
  set "rs=!sa!"
  if "!sa!" neq "!sb!" goto :_add_dsign
  call _xqword add !ma! !mb!
  set "rm=!__!"
  if "!rm:~0,2!"=="00" goto :_add_pack
  call _xqword shr !rm!
  set "rm=!__!"
  call _xbyte inc !ea!
  set "ea=!__!"
  if "!ea!"=="00" (endlocal & exit /B 6)
  goto :_add_pack
:_add_dsign
  call _xqword sub !ma! !mb!
  set "rm=!__!"
  if "!__c!" neq "1" goto :_add_dnorm
  call _xqword sub !mb! !ma!
  set "rm=!__!"
  set "rs=!sb!"
:_add_dnorm
  if "!rm!"=="0000000000000000" (endlocal & set "__=0000000000000000" & exit /B 0)
  call _mbfd normalize !ea! !rm!
  set "rm=!__!"& set "ea=!__e!"
  if "!ea!"=="00" (endlocal & set "__=0000000000000000" & exit /B 0)
  goto :_add_pack
:_add_ret_a
  call _mbfd pack !ea! !sa! !ma!
  endlocal & set "__=%__%" & exit /B 0
:_add_pack
  call _mbfd pack !ea! !rs! !rm!
  endlocal & set "__=%__%" & exit /B 0


:sub
  setlocal EnableDelayedExpansion
  set "b=%~2"
  if "!b:~0,2!" neq "00" (call _mbfd neg !b! & set "b=!__!")
  call _mbfd add %~1 !b!
  endlocal & set "__=%__%" & exit /B 0


:mul
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,2!"=="00" (endlocal & set "__=0000000000000000" & exit /B 0)
  if "!b:~0,2!"=="00" (endlocal & set "__=0000000000000000" & exit /B 0)
  set "sa=0"& set "sb=0"& set "rs=0"
  for %%c in (8 9 A B C D E F) do (
    if "!a:~2,1!"=="%%c" set "sa=1"
    if "!b:~2,1!"=="%%c" set "sb=1"
  )
  if "!sa!" neq "!sb!" set "rs=1"
  set "ea=!a:~0,2!"& set "eb=!b:~0,2!"
  call _xword add 00!ea! 00!eb!
  set "esum=!__!"
  call _xword sub !esum! 0080
  set "eres=!__!"
  if "!__c!"=="1" (endlocal & set "__=0000000000000000" & exit /B 0)
  if "!eres!"=="0000" (endlocal & set "__=0000000000000000" & exit /B 0)
  if "!eres:~0,2!" neq "00" (endlocal & exit /B 6)
  set "re=!eres:~2,2!"
  call _mbfd getMant !a!
  set "ma=!__!"
  call _mbfd getMant !b!
  set "mb=!__!"
  @REM Split 56-bit mantissas into high dword (chars 0-7) + low dword (chars 8-15)
  set "ah=!ma:~0,8!"& set "al=!ma:~8,8!"
  set "bh=!mb:~0,8!"& set "bl=!mb:~8,8!"
  @REM 4 dword multiplications (each returns __=low, __h=high)
  call _xdword mul !al! !bl!
  set "p0l=!__!"& set "p0h=!__h!"
  call _xdword mul !ah! !bl!
  set "p1l=!__!"& set "p1h=!__h!"
  call _xdword mul !al! !bh!
  set "p2l=!__!"& set "p2h=!__h!"
  call _xdword mul !ah! !bh!
  set "p3l=!__!"& set "p3h=!__h!"
  @REM Accumulate 128-bit: R3:R2:R1:R0 (4 dwords)
  set "r0=!p0l!"
  set "cy=00000000"
  call _xdword add !p0h! !p1l!
  set "r1=!__!"
  if "!__c!"=="1" (call _xdword inc !cy! & set "cy=!__!")
  call _xdword add !r1! !p2l!
  set "r1=!__!"
  if "!__c!"=="1" (call _xdword inc !cy! & set "cy=!__!")
  set "cy2=00000000"
  call _xdword add !p1h! !p2h!
  set "r2=!__!"
  if "!__c!"=="1" (call _xdword inc !cy2! & set "cy2=!__!")
  call _xdword add !r2! !p3l!
  set "r2=!__!"
  if "!__c!"=="1" (call _xdword inc !cy2! & set "cy2=!__!")
  call _xdword add !r2! !cy!
  set "r2=!__!"
  if "!__c!"=="1" (call _xdword inc !cy2! & set "cy2=!__!")
  call _xdword add !p3h! !cy2!
  set "r3=!__!"
  @REM Upper 56 bits: 00 + R3[bytes 1-0] + R2 + R1[byte 3]
  set "rm=00!r3:~4,4!!r2!!r1:~0,2!"
  @REM Check bit 55 (char 2 of qword >= 8)
  set "_ch=!rm:~2,1!"
  for %%c in (8 9 A B C D E F) do if "!_ch!"=="%%c" goto :_mul_shr
  @REM Normal: shift left 1, bring in MSB of R1 byte 2
  call _xqword shl !rm!
  set "rm=!__!"
  set "_r1b=!r1:~2,1!"
  for %%c in (8 9 A B C D E F) do if "!_r1b!"=="%%c" (
    call _xqword inc !rm!
    set "rm=!__!"
  )
  goto :_mul_pack
:_mul_shr
  call _xbyte inc !re!
  set "re=!__!"
  if "!re!"=="00" (endlocal & exit /B 6)
:_mul_pack
  call _mbfd pack !re! !rs! !rm!
  endlocal & set "__=%__%" & exit /B 0


:div
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!b:~0,2!"=="00" (endlocal & exit /B 11)
  if "!a:~0,2!"=="00" (endlocal & set "__=0000000000000000" & exit /B 0)
  set "sa=0"& set "sb=0"& set "rs=0"
  for %%c in (8 9 A B C D E F) do (
    if "!a:~2,1!"=="%%c" set "sa=1"
    if "!b:~2,1!"=="%%c" set "sb=1"
  )
  if "!sa!" neq "!sb!" set "rs=1"
  set "ea=!a:~0,2!"& set "eb=!b:~0,2!"
  call _xword add 00!ea! 0080
  call _xword sub !__! 00!eb!
  set "eres=!__!"
  if "!__c!"=="1" (endlocal & set "__=0000000000000000" & exit /B 0)
  if "!eres!"=="0000" (endlocal & set "__=0000000000000000" & exit /B 0)
  if "!eres:~0,2!" neq "00" (endlocal & exit /B 6)
  set "re=!eres:~2,2!"
  call _mbfd getMant !a!
  set "ma=!__!"
  call _mbfd getMant !b!
  set "dsor=!__!"
  @REM Initial bit
  set "q=0000000000000000"
  call _xqword sub !ma! !dsor!
  if "!__c!" neq "1" goto :_div_fb
  set "r=!ma!"
  goto :_div_start
:_div_fb
  set "q=0000000000000001"
  set "r=!__!"
:_div_start
  @REM 55 more iterations
  set "_cnt=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz012"
:_div_loop
  if "!_cnt!"=="" goto :_div_end
  set "_cnt=!_cnt:~1!"
  call _xqword shl !r!
  set "r=!__!"
  call _xqword shl !q!
  set "q=!__!"
  call _xqword sub !r! !dsor!
  if "!__c!" neq "1" (
    set "r=!__!"
    call _xqword inc !q!
    set "q=!__!"
  )
  goto :_div_loop
:_div_end
  call _mbfd normalize !re! !q!
  set "rm=!__!"& set "re=!__e!"
  if "!re!"=="00" (endlocal & set "__=0000000000000000" & exit /B 0)
  call _mbfd pack !re! !rs! !rm!
  endlocal & set "__=%__%" & exit /B 0


:fromInt
  setlocal EnableDelayedExpansion
  set "n=%~1"
  if "!n!"=="0000" (endlocal & set "__=0000000000000000" & exit /B 0)
  set "s=0"
  set "ch=!n:~0,1!"
  for %%c in (8 9 A B C D E F) do if "!ch!"=="%%c" set "s=1"
  if "!s!"=="1" (call _xword neg !n! & set "n=!__!")
  set "m=0000000000!n!00"
  set "e=AF"
  call _mbfd normalize !e! !m!
  set "m=!__!"& set "e=!__e!"
  call _mbfd pack !e! !s! !m!
  endlocal & set "__=%__%" & exit /B 0


:toInt
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "e=!v:~0,2!"
  if "!e!"=="00" (endlocal & set "__=0000" & exit /B 0)
  set "s=0"
  set "ch=!v:~2,1!"
  for %%c in (8 9 A B C D E F) do if "!ch!"=="%%c" set "s=1"
  call _mbfd getMant !v!
  set "m=!__!"
  call _xbyte sub !e! 80
  if "!__c!"=="1" (endlocal & set "__=0000" & exit /B 0)
  set "k=!__!"
  call _xbyte sub !k! 10
  if "!__c!" neq "1" (endlocal & exit /B 6)
  @REM Shift right by 40 (=56-16) to get top 16 bits, then by (15-k) more
  @REM Fast: take bytes 6-5 (chars 2-5 of qword) as the 16-bit value
  set "w=!m:~2,4!"
  @REM Now shift right by (15-k) using loop
  call _xbyte sub 0F !k!
  set "cnt=!__!"
:_ti_shr
  if "!cnt!"=="00" goto :_ti_done
  call _xword shr !w!
  set "w=!__!"
  call _xbyte dec !cnt!
  set "cnt=!__!"
  goto :_ti_shr
:_ti_done
  if "!s!"=="1" (call _xword neg !w! & set "w=!__!")
  endlocal & set "__=%w%" & exit /B 0


@REM === fromDec / toDec: same approach as _mbfs but with qword ===

:fromDec
  setlocal EnableDelayedExpansion
  set "str=%~1"
  set "sign=0"
  set /a "sig=0"
  set /a "flen=0"
  set /a "digs=0"
  set "infr=0"
  set /a "pos=0"
  for %%i in (!pos!) do set "ch=!str:~%%i,1!"
  if "!ch!"=="-" (set "sign=1"& set /a "pos+=1")
  if "!ch!"=="+" set /a "pos+=1"
:_fd_dg
  for %%i in (!pos!) do set "ch=!str:~%%i,1!"
  if "!ch!"=="" goto :_fd_ec
  if "!ch!"=="." (set "infr=1"& set /a "pos+=1"& goto :_fd_dg)
  if "!ch!"=="E" goto :_fd_pe
  if "!ch!"=="e" goto :_fd_pe
  if !digs! LSS 7 (set /a "sig=sig*10+ch"& set /a "digs+=1")
  if "!infr!"=="1" set /a "flen+=1"
  set /a "pos+=1"
  goto :_fd_dg
:_fd_ec
  set /a "exp10=0-flen"
  goto :_fd_cv
:_fd_pe
  set /a "pos+=1"
  set /a "esign=1"
  for %%i in (!pos!) do set "ch=!str:~%%i,1!"
  if "!ch!"=="-" (set /a "esign=-1"& set /a "pos+=1")
  if "!ch!"=="+" set /a "pos+=1"
  set /a "eexp=0"
:_fd_ped
  for %%i in (!pos!) do set "ch=!str:~%%i,1!"
  if "!ch!"=="" goto :_fd_pedone
  set /a "eexp=eexp*10+ch"
  set /a "pos+=1"
  goto :_fd_ped
:_fd_pedone
  set /a "exp10=eexp*esign-flen"
:_fd_cv
  if !sig!==0 (endlocal & set "__=0000000000000000" & exit /B 0)
  @REM Convert sig to qword hex (inline, separate lines)
  set /a "b3=(sig>>24)&255"
  set /a "b2=(sig>>16)&255"
  set /a "b1=(sig>>8)&255"
  set /a "b0=sig&255"
  set /a "hn=b3/16"
  set /a "ln=b3%%16"
  for /F "tokens=1,2" %%a in ("!hn! !ln!") do set "d3=!_p_%%a!!_p_%%b!"
  set /a "hn=b2/16"
  set /a "ln=b2%%16"
  for /F "tokens=1,2" %%a in ("!hn! !ln!") do set "d2=!_p_%%a!!_p_%%b!"
  set /a "hn=b1/16"
  set /a "ln=b1%%16"
  for /F "tokens=1,2" %%a in ("!hn! !ln!") do set "d1=!_p_%%a!!_p_%%b!"
  set /a "hn=b0/16"
  set /a "ln=b0%%16"
  for /F "tokens=1,2" %%a in ("!hn! !ln!") do set "d0=!_p_%%a!!_p_%%b!"
  set "dw=00000000!d3!!d2!!d1!!d0!"
  @REM Normalize inline (avoid self-call)
  set "ne=B7"
  if "!dw!"=="0000000000000000" (endlocal & set "__=0000000000000000" & exit /B 0)
  set "_nc=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
:_fd_norm
  set "_nch=!dw:~2,1!"
  for %%c in (8 9 A B C D E F) do if "!_nch!"=="%%c" goto :_fd_nd
  call _xqword shl !dw!
  set "dw=!__!"
  call _xbyte dec !ne!
  set "ne=!__!"
  if "!ne!"=="00" (endlocal & set "__=0000000000000000" & exit /B 0)
  set "_nc=!_nc:~1!"
  if "!_nc!"=="" goto :_fd_nd
  goto :_fd_norm
:_fd_nd
  @REM Pack inline (avoid self-call)
  set "pb=!dw:~2,2!"
  call _xbyte and !pb! 7F
  set "pb=!__!"
  if "!sign!"=="1" (call _xbyte or !pb! 80 & set "pb=!__!")
  set "result=!ne!!pb!!dw:~4,12!"
  @REM Apply decimal exponent
  @REM 10.0 in MBF double = 8320000000000000
  if !exp10! GTR 0 goto :_fd_m10
  if !exp10! LSS 0 goto :_fd_d10
  goto :_fd_done
:_fd_m10
  if !exp10!==0 goto :_fd_done
  call _mbfd mul !result! 8320000000000000
  set "result=!__!"
  set /a "exp10-=1"
  goto :_fd_m10
:_fd_d10
  if !exp10!==0 goto :_fd_done
  call _mbfd div !result! 8320000000000000
  set "result=!__!"
  set /a "exp10+=1"
  goto :_fd_d10
:_fd_done
  endlocal & set "__=%result%" & exit /B 0


:toDec
  setlocal EnableDelayedExpansion
  set "v=%~1"
  if "!v:~0,2!"=="00" (endlocal & set "__=0" & exit /B 0)
  set "neg="
  set "ch=!v:~2,1!"
  for %%c in (8 9 A B C D E F) do if "!ch!"=="%%c" set "neg=1"
  if "!neg!"=="1" (
    set "_tb=!v:~2,2!"
    call _xbyte xor !_tb! 80
    set "v=!v:~0,2!!__!!v:~4,12!"
  )
  @REM 1.0 = 8000000000000000, 10.0 = 8320000000000000
  set /a "exp10=0"
  set /a "_guard=0"
:_td_up
  if !_guard! GTR 50 goto :_td_ext
  call _xbyte sub !v:~0,2! 80
  if "!__c!" neq "1" goto :_td_dn
  call _mbfd mul !v! 8320000000000000
  set "v=!__!"
  set /a "exp10-=1"
  set /a "_guard+=1"
  goto :_td_up
:_td_dn
  if !_guard! GTR 50 goto :_td_ext
  call _xbyte sub !v:~0,2! 84
  if "!__c!" neq "1" goto :_td_ddiv
  call _xbyte sub !v:~0,2! 83
  if "!__c!"=="1" goto :_td_ext
  if "!v:~0,2!" neq "83" goto :_td_ext
  set "_mb=!v:~2,2!"
  call _xbyte and !_mb! 7F
  call _xbyte sub !__! 20
  if "!__c!"=="1" goto :_td_ext
:_td_ddiv
  call _mbfd div !v! 8320000000000000
  set "v=!__!"
  set /a "exp10+=1"
  set /a "_guard+=1"
  goto :_td_dn
:_td_ext
  set "dg="
  set /a "i=0"
:_td_dg
  if !i!==7 goto :_td_fmt
  set "_de=!v:~0,2!"
  call _xbyte sub !_de! 80
  if "!__c!"=="1" (
    set "dg=!dg!0"
    goto :_td_mul
  )
  set "_dk=!__!"
  set "_db=!v:~2,2!"
  call _xbyte or !_db! 80
  set /a "_dv=!_s_%__:~0,1%!*16+!_s_%__:~1,1%!"
  set /a "_dshift=7-!_s_%_dk:~0,1%!*16-!_s_%_dk:~1,1%!"
  set /a "_digit=_dv>>_dshift"
  if !_digit! GTR 9 set /a "_digit=9"
  set "dg=!dg!!_digit!"
  if !_digit!==0 goto :_td_mul
  set "_df_1=8000000000000000"& set "_df_2=8100000000000000"& set "_df_3=8140000000000000"
  set "_df_4=8200000000000000"& set "_df_5=8220000000000000"& set "_df_6=8240000000000000"
  set "_df_7=8260000000000000"& set "_df_8=8300000000000000"& set "_df_9=8310000000000000"
  set "_df=!_df_%_digit%!"
  call _mbfd sub !v! !_df!
  set "v=!__!"
  if "!v:~0,2!" neq "00" (
    set "_sc=!v:~2,1!"
    for %%c in (8 9 A B C D E F) do if "!_sc!"=="%%c" set "v=0000000000000000"
  )
:_td_mul
  if "!v:~0,2!" neq "00" (call _mbfd mul !v! 8320000000000000 & set "v=!__!")
  set /a "i+=1"
  goto :_td_dg
:_td_fmt
:_td_trim
  if "!dg:~1!"=="" goto :_td_bld
  if "!dg:~-1!"=="0" (set "dg=!dg:~0,-1!"& goto :_td_trim)
:_td_bld
  set "r="
  if "!neg!"=="1" set "r=-"
  if "!dg:~1!"=="" (set "r=!r!!dg!") else (set "r=!r!!dg:~0,1!.!dg:~1!")
  if !exp10! neq 0 set "r=!r!E!exp10!"
  endlocal & set "__=%r%" & exit /B 0


:_start
echo _start@mbfd.bat
