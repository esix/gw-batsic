@echo off
@REM Lookup tables for decimal conversion
set "_s_0=0"& set "_s_1=1"& set "_s_2=2"& set "_s_3=3"& set "_s_4=4"& set "_s_5=5"& set "_s_6=6"& set "_s_7=7"
set "_s_8=8"& set "_s_9=9"& set "_s_A=10"& set "_s_B=11"& set "_s_C=12"& set "_s_D=13"& set "_s_E=14"& set "_s_F=15"
set "_p_0=0"& set "_p_1=1"& set "_p_2=2"& set "_p_3=3"& set "_p_4=4"& set "_p_5=5"& set "_p_6=6"& set "_p_7=7"
set "_p_8=8"& set "_p_9=9"& set "_p_10=A"& set "_p_11=B"& set "_p_12=C"& set "_p_13=D"& set "_p_14=E"& set "_p_15=F"
@REM MBF Single precision internals (4 bytes = 8 hex chars = xdword)
@REM Layout (big-endian): EE SM MM MM
@REM   EE = exponent (biased by 128, 0x80). EE=00 means zero.
@REM   S  = sign bit (bit 7 of byte 2)
@REM   M  = 23-bit mantissa fraction (implied leading 1)
@REM   Value = (-1)^S * 1.mantissa * 2^(EE - 128)
@REM
@REM Mantissa in internal ops is 24-bit (implied 1 restored), stored in
@REM lower 24 bits of a xdword: 00XXXXXX (bit 23 = implied 1)

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


@REM === Predicates ===

:isZero
  setlocal EnableDelayedExpansion
  set "v=%~1"
  if "!v:~0,2!"=="00" (endlocal & set "__=1" & exit /B 0)
  endlocal & set "__=" & exit /B 0


@REM === Sign operations ===

:neg
  setlocal EnableDelayedExpansion
  set "v=%~1"
  if "!v:~0,2!"=="00" (endlocal & set "__=%~1" & exit /B 0)
  set "e=!v:~0,2!"
  set "b2=!v:~2,2!"
  set "lo=!v:~4,4!"
  call _xbyte xor !b2! 80
  set "b2=!__!"
  endlocal & set "__=%e%%b2%%lo%" & exit /B 0


:abs
  setlocal EnableDelayedExpansion
  set "v=%~1"
  if "!v:~0,2!"=="00" (endlocal & set "__=%~1" & exit /B 0)
  set "e=!v:~0,2!"
  set "b2=!v:~2,2!"
  set "lo=!v:~4,4!"
  call _xbyte and !b2! 7F
  set "b2=!__!"
  endlocal & set "__=%e%%b2%%lo%" & exit /B 0


@REM === Field extraction (raw xdword in, components out) ===
@REM These return raw hex values, no type prefix.

:getExp
  set "__=%~1"
  set "__=!__:~0,2!"
  exit /B 0

:getSign
  setlocal EnableDelayedExpansion
  set "ch=!%~1:~2,1!"
  set "ch=%~1"
  set "ch=!ch:~2,1!"
  set "__=0"
  for %%c in (8 9 A B C D E F) do if "!ch!"=="%%c" set "__=1"
  endlocal & set "__=%__%" & exit /B 0


:getMant
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "b2=!v:~2,2!"
  set "lo=!v:~4,4!"
  @REM Clear sign bit and set implied 1 (both = OR with 80)
  call _xbyte or !b2! 80
  set "b2=!__!"
  endlocal & set "__=00%b2%%lo%" & exit /B 0


@REM === Pack: exponent + sign + mantissa -> MBF single ===
@REM   %1 = exponent (xbyte)
@REM   %2 = sign ("0" or "1")
@REM   %3 = mantissa (xdword, 24-bit with implied 1 in bit 23)

:pack
  setlocal EnableDelayedExpansion
  set "e=%~1"
  set "s=%~2"
  set "m=%~3"
  if "!e!"=="00" (endlocal & set "__=00000000" & exit /B 0)
  @REM Get byte 2 of mantissa (chars 2-3), clear implied 1, set sign
  set "b2=!m:~2,2!"
  call _xbyte and !b2! 7F
  set "b2=!__!"
  if "!s!"=="1" (
    call _xbyte or !b2! 80
    set "b2=!__!"
  )
  set "lo=!m:~4,4!"
  endlocal & set "__=%e%%b2%%lo%" & exit /B 0


@REM === Normalization: shift mantissa left until bit 23 is set ===
@REM   %1 = exponent (xbyte)
@REM   %2 = mantissa (xdword)
@REM   Returns __ = normalized mantissa, __e = adjusted exponent
@REM   If mantissa is zero, returns exp=00 (zero result)

:normalize
  setlocal EnableDelayedExpansion
  set "e=%~1"
  set "m=%~2"
  if "!m!"=="00000000" (endlocal & set "__=00000000" & set "__e=00" & exit /B 0)
  set "_cnt=0123456789ABCDEFGHIJKLMN"
:_norm_loop
  @REM Check if bit 23 is set: char at position 2 of dword >= '8'
  set "_ch=!m:~2,1!"
  for %%c in (8 9 A B C D E F) do if "!_ch!"=="%%c" goto :_norm_done
  @REM Not set: shift left, decrement exponent
  call _xdword shl !m!
  set "m=!__!"
  call _xbyte dec !e!
  set "e=!__!"
  if "!e!"=="00" (endlocal & set "__=00000000" & set "__e=00" & exit /B 0)
  set "_cnt=!_cnt:~1!"
  if "!_cnt!"=="" goto :_norm_done
  goto :_norm_loop
:_norm_done
  endlocal & set "__=%m%" & set "__e=%e%" & exit /B 0


@REM === fromInt: xword (raw, no prefix) -> MBF single (raw) ===

:fromInt
  setlocal EnableDelayedExpansion
  set "n=%~1"
  if "!n!"=="0000" (endlocal & set "__=00000000" & exit /B 0)
  @REM Determine sign
  set "s=0"
  set "ch=!n:~0,1!"
  for %%c in (8 9 A B C D E F) do if "!ch!"=="%%c" set "s=1"
  @REM Take absolute value if negative
  if "!s!"=="1" (
    call _xword neg !n!
    set "n=!__!"
  )
  @REM Zero-extend to dword and shift left by 8 to put value in bits 8-23
  set "m=00!n!00"
  @REM Starting exponent: assume MSB at bit 15 -> exp = 128+15 = 143 = 0x8F
  set "e=8F"
  @REM Normalize: shift left until bit 23 is set
  call _mbfs normalize !e! !m!
  set "m=!__!"
  set "e=!__e!"
  @REM Pack result
  call _mbfs pack !e! !s! !m!
  endlocal & set "__=%__%" & exit /B 0


@REM === toInt: MBF single (raw) -> xword (raw, no prefix) ===
@REM Truncates toward zero (like CINT in GW-BASIC for values within range)

:toInt
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "e=!v:~0,2!"
  @REM Zero
  if "!e!"=="00" (endlocal & set "__=0000" & exit /B 0)
  @REM Get sign
  set "s=0"
  set "ch=!v:~2,1!"
  for %%c in (8 9 A B C D E F) do if "!ch!"=="%%c" set "s=1"
  @REM Get mantissa (24-bit, implied 1 restored)
  call _mbfs getMant !v!
  set "m=!__!"
  @REM Compute shift count: we need to shift mantissa right by (23 - k)
  @REM where k = exp - 128. Equivalently, start at exp=8F (143),
  @REM shift right by (8F - exp) then shift right by 8 more to get 16-bit.
  @REM But it's simpler: shift right from bit 23 down to bit 0 position,
  @REM total right shifts = 23 - (exp - 128) = 151 - exp.
  @REM
  @REM If exp > 142 (0x8E), result > 32767 magnitude -> overflow
  @REM (except -32768 when sign=1 and exp=143 with mantissa=1.0)
  @REM If exp < 128 (0x80), result is fractional -> 0
  @REM
  @REM Check exp < 128: underflow to zero
  call _xbyte sub !e! 80
  if "!__c!"=="1" (endlocal & set "__=0000" & exit /B 0)
  @REM k = exp - 128 (as xbyte). k is in __ from the sub above.
  set "k=!__!"
  @REM Check k > 15 (0x0F): overflow
  call _xbyte sub !k! 10
  if "!__c!" neq "1" (endlocal & exit /B 6)
  @REM Shift mantissa right by (23 - k) = shift right by 8 first (fast),
  @REM then by (15 - k) more.
  @REM Fast shift right by 8: take bytes 2,1 (drop byte 0, shift high down)
  set "m=0000!m:~2,4!"
  @REM Now need (15 - k) more right shifts. Compute count.
  call _xbyte sub 0F !k!
  set "cnt=!__!"
  @REM Shift loop using string counter
  @REM Convert cnt (0x00-0x0F) to iteration string
  set "_i="
  if "!cnt!" neq "00" (
    set "_i=x"
    call _xbyte dec !cnt!
    set "cnt=!__!"
    if "!cnt!" neq "00" for /L %%j in (1,1,14) do (
      if "!cnt!" neq "00" (
        set "_i=!_i!x"
        call _xbyte dec !cnt!
        set "cnt=!__!"
      )
    )
  )
:_toInt_shrloop
  if "!_i!"=="" goto :_toInt_shrdone
  set "_i=!_i:~1!"
  call _xdword shr !m!
  set "m=!__!"
  goto :_toInt_shrloop
:_toInt_shrdone
  @REM Take lower 16 bits (word)
  set "r=!m:~4,4!"
  @REM Apply sign
  if "!s!"=="1" (
    call _xword neg !r!
    set "r=!__!"
  )
  @REM Overflow check: positive must be <= 7FFF, negative must be >= 8000
  @REM (neg already handled, just check the result makes sense)
  endlocal & set "__=%r%" & exit /B 0


@REM === Compare: returns __ = "0" (eq), "1" (a>b), "2" (a<b) ===

:cmp
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  set "az="& set "bz="
  if "!a:~0,2!"=="00" set "az=1"
  if "!b:~0,2!"=="00" set "bz=1"
  @REM Both zero
  if "!az!"=="1" if "!bz!"=="1" (endlocal & set "__=0" & exit /B 0)
  @REM Get signs
  set "sa=0"& set "sb=0"
  for %%c in (8 9 A B C D E F) do (
    if "!a:~2,1!"=="%%c" set "sa=1"
    if "!b:~2,1!"=="%%c" set "sb=1"
  )
  @REM Zero vs non-zero
  if "!az!"=="1" (
    if "!sb!"=="1" (endlocal & set "__=1" & exit /B 0)
    endlocal & set "__=2" & exit /B 0
  )
  if "!bz!"=="1" (
    if "!sa!"=="1" (endlocal & set "__=2" & exit /B 0)
    endlocal & set "__=1" & exit /B 0
  )
  @REM Different signs: positive > negative
  if "!sa!" neq "!sb!" (
    if "!sa!"=="1" (endlocal & set "__=2" & exit /B 0)
    endlocal & set "__=1" & exit /B 0
  )
  @REM Same sign: compare absolute values via dword subtraction
  call _mbfs abs !a!
  set "aa=!__!"
  call _mbfs abs !b!
  set "ab=!__!"
  call _xdword sub !aa! !ab!
  set "r=!__!"& set "c=!__c!"
  if "!r!"=="00000000" if "!c!" neq "1" (endlocal & set "__=0" & exit /B 0)
  @REM mag=1 if |a|>|b|, mag=2 if |a|<|b|
  set "mag=1"
  if "!c!"=="1" set "mag=2"
  @REM For negative numbers, invert comparison
  if "!sa!"=="1" (
    set "_i_1=2"& set "_i_2=1"
    set "mag=!_i_%mag%!"
  )
  endlocal & set "__=%mag%" & exit /B 0


@REM === Addition ===

:add
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,2!"=="00" (endlocal & set "__=%~2" & exit /B 0)
  if "!b:~0,2!"=="00" (endlocal & set "__=%~1" & exit /B 0)
  @REM Extract exponents
  set "ea=!a:~0,2!"& set "eb=!b:~0,2!"
  @REM Extract signs
  set "sa=0"& set "sb=0"
  for %%c in (8 9 A B C D E F) do (
    if "!a:~2,1!"=="%%c" set "sa=1"
    if "!b:~2,1!"=="%%c" set "sb=1"
  )
  @REM Get mantissas (24-bit with implied 1, in dword)
  call _mbfs getMant !a!
  set "ma=!__!"
  call _mbfs getMant !b!
  set "mb=!__!"
  @REM Ensure ea >= eb (swap if needed so 'a' has larger exponent)
  call _xbyte sub !ea! !eb!
  set "diff=!__!"
  if "!__c!" neq "1" goto :_add_ordered
  set "_t=!ea!"& set "ea=!eb!"& set "eb=!_t!"
  set "_t=!sa!"& set "sa=!sb!"& set "sb=!_t!"
  set "_t=!ma!"& set "ma=!mb!"& set "mb=!_t!"
  call _xbyte sub !ea! !eb!
  set "diff=!__!"
:_add_ordered
  @REM If diff > 24 (0x18), b is negligible — return a
  call _xbyte sub !diff! 19
  if "!__c!" neq "1" goto :_add_return_a
  @REM Align: shift mb right by diff bits
:_add_align
  if "!diff!"=="00" goto :_add_aligned
  call _xdword shr !mb!
  set "mb=!__!"
  call _xbyte dec !diff!
  set "diff=!__!"
  goto :_add_align
:_add_aligned
  set "rs=!sa!"
  if "!sa!" neq "!sb!" goto :_add_diff_sign
  @REM Same sign: add mantissas
  call _xdword add !ma! !mb!
  set "rm=!__!"
  @REM Check overflow (bit 24+: high byte not 00)
  if "!rm:~0,2!"=="00" goto :_add_pack
  call _xdword shr !rm!
  set "rm=!__!"
  call _xbyte inc !ea!
  set "ea=!__!"
  if "!ea!"=="00" (endlocal & exit /B 6)
  goto :_add_pack
:_add_diff_sign
  @REM Different signs: subtract (ma has larger exponent)
  call _xdword sub !ma! !mb!
  set "rm=!__!"
  if "!__c!" neq "1" goto :_add_diff_norm
  @REM Borrow: mb > ma (equal exponents case), flip sign
  call _xdword sub !mb! !ma!
  set "rm=!__!"
  set "rs=!sb!"
:_add_diff_norm
  if "!rm!"=="00000000" (endlocal & set "__=00000000" & exit /B 0)
  call _mbfs normalize !ea! !rm!
  set "rm=!__!"& set "ea=!__e!"
  if "!ea!"=="00" (endlocal & set "__=00000000" & exit /B 0)
  goto :_add_pack
:_add_return_a
  @REM Reconstruct a from ea/sa/ma (in case it was swapped)
  call _mbfs pack !ea! !sa! !ma!
  endlocal & set "__=%__%" & exit /B 0
:_add_pack
  call _mbfs pack !ea! !rs! !rm!
  endlocal & set "__=%__%" & exit /B 0


@REM === Subtraction: negate b, then add ===

:sub
  setlocal EnableDelayedExpansion
  set "b=%~2"
  if "!b:~0,2!" neq "00" (
    call _mbfs neg !b!
    set "b=!__!"
  )
  call _mbfs add %~1 !b!
  endlocal & set "__=%__%" & exit /B 0


@REM === Multiplication ===
@REM Result = a * b. Mantissa multiplication is 24x24-bit (schoolbook, 9 byte-muls).

:mul
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,2!"=="00" (endlocal & set "__=00000000" & exit /B 0)
  if "!b:~0,2!"=="00" (endlocal & set "__=00000000" & exit /B 0)
  @REM Result sign: XOR of signs
  set "sa=0"& set "sb=0"& set "rs=0"
  for %%c in (8 9 A B C D E F) do (
    if "!a:~2,1!"=="%%c" set "sa=1"
    if "!b:~2,1!"=="%%c" set "sb=1"
  )
  if "!sa!" neq "!sb!" set "rs=1"
  @REM Result exponent: ea + eb - 128
  set "ea=!a:~0,2!"& set "eb=!b:~0,2!"
  call _xword add 00!ea! 00!eb!
  set "esum=!__!"
  call _xword sub !esum! 0080
  set "eres=!__!"
  if "!__c!"=="1" (endlocal & set "__=00000000" & exit /B 0)
  if "!eres!"=="0000" (endlocal & set "__=00000000" & exit /B 0)
  if "!eres:~0,2!" neq "00" (endlocal & exit /B 6)
  set "re=!eres:~2,2!"
  @REM Get mantissas (24-bit in dword)
  call _mbfs getMant !a!
  set "ma=!__!"
  call _mbfs getMant !b!
  set "mb=!__!"
  @REM Extract bytes: ma = m2:m1:m0, mb = n2:n1:n0
  set "m2=!ma:~2,2!"& set "m1=!ma:~4,2!"& set "m0=!ma:~6,2!"
  set "n2=!mb:~2,2!"& set "n1=!mb:~4,2!"& set "n0=!mb:~6,2!"
  @REM 9 partial products (byte*byte -> __=lo, __h=hi)
  call _xbyte mul !m0! !n0!
  set "p0l=!__!"& set "p0h=!__h!"
  call _xbyte mul !m0! !n1!
  set "p1l=!__!"& set "p1h=!__h!"
  call _xbyte mul !m1! !n0!
  set "p2l=!__!"& set "p2h=!__h!"
  call _xbyte mul !m0! !n2!
  set "p3l=!__!"& set "p3h=!__h!"
  call _xbyte mul !m1! !n1!
  set "p4l=!__!"& set "p4h=!__h!"
  call _xbyte mul !m2! !n0!
  set "p5l=!__!"& set "p5h=!__h!"
  call _xbyte mul !m1! !n2!
  set "p6l=!__!"& set "p6h=!__h!"
  call _xbyte mul !m2! !n1!
  set "p7l=!__!"& set "p7h=!__h!"
  call _xbyte mul !m2! !n2!
  set "p8l=!__!"& set "p8h=!__h!"
  @REM Accumulate 48-bit result: R5:R4:R3:R2:R1:R0 (only need R5:R4:R3 + R2 MSB)
  @REM R1 = p0h + p1l + p2l (carry -> cy1)
  set "cy=00"
  call _xbyte add !p0h! !p1l!
  set "r1=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy! & set "cy=!__!")
  call _xbyte add !r1! !p2l!
  set "r1=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy! & set "cy=!__!")
  @REM R2 = p1h + p2h + p3l + p4l + p5l + cy
  set "cy2=00"
  call _xbyte add !p1h! !p2h!
  set "r2=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy2! & set "cy2=!__!")
  call _xbyte add !r2! !p3l!
  set "r2=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy2! & set "cy2=!__!")
  call _xbyte add !r2! !p4l!
  set "r2=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy2! & set "cy2=!__!")
  call _xbyte add !r2! !p5l!
  set "r2=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy2! & set "cy2=!__!")
  call _xbyte add !r2! !cy!
  set "r2=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy2! & set "cy2=!__!")
  @REM R3 = p3h + p4h + p5h + p6l + p7l + cy2
  set "cy3=00"
  call _xbyte add !p3h! !p4h!
  set "r3=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy3! & set "cy3=!__!")
  call _xbyte add !r3! !p5h!
  set "r3=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy3! & set "cy3=!__!")
  call _xbyte add !r3! !p6l!
  set "r3=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy3! & set "cy3=!__!")
  call _xbyte add !r3! !p7l!
  set "r3=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy3! & set "cy3=!__!")
  call _xbyte add !r3! !cy2!
  set "r3=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy3! & set "cy3=!__!")
  @REM R4 = p6h + p7h + p8l + cy3
  set "cy4=00"
  call _xbyte add !p6h! !p7h!
  set "r4=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy4! & set "cy4=!__!")
  call _xbyte add !r4! !p8l!
  set "r4=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy4! & set "cy4=!__!")
  call _xbyte add !r4! !cy3!
  set "r4=!__!"
  if "!__c!"=="1" (call _xbyte inc !cy4! & set "cy4=!__!")
  @REM R5 = p8h + cy4
  call _xbyte add !p8h! !cy4!
  set "r5=!__!"
  @REM Upper 24 bits as dword: 00:R5:R4:R3
  set "rm=00!r5!!r4!!r3!"
  @REM Check bit 23 (= bit 47 of 48-bit product, means product >= 2.0)
  set "_ch=!rm:~2,1!"
  for %%c in (8 9 A B C D E F) do if "!_ch!"=="%%c" goto :_mul_shr
  @REM Normal: shift left 1 to bring bit 46 to position 23, bring in MSB of R2
  call _xdword shl !rm!
  set "rm=!__!"
  set "_r2h=!r2:~0,1!"
  for %%c in (8 9 A B C D E F) do if "!_r2h!"=="%%c" (
    call _xdword inc !rm!
    set "rm=!__!"
  )
  goto :_mul_pack
:_mul_shr
  @REM Overflow: product >= 2.0, increment exponent
  call _xbyte inc !re!
  set "re=!__!"
  if "!re!"=="00" (endlocal & exit /B 6)
:_mul_pack
  call _mbfs pack !re! !rs! !rm!
  endlocal & set "__=%__%" & exit /B 0


@REM === Division ===
@REM 24-bit mantissa long division: 1 initial comparison + 23 iterations.

:div
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!b:~0,2!"=="00" (endlocal & exit /B 11)
  if "!a:~0,2!"=="00" (endlocal & set "__=00000000" & exit /B 0)
  @REM Result sign
  set "sa=0"& set "sb=0"& set "rs=0"
  for %%c in (8 9 A B C D E F) do (
    if "!a:~2,1!"=="%%c" set "sa=1"
    if "!b:~2,1!"=="%%c" set "sb=1"
  )
  if "!sa!" neq "!sb!" set "rs=1"
  @REM Result exponent: ea - eb + 128
  set "ea=!a:~0,2!"& set "eb=!b:~0,2!"
  call _xword add 00!ea! 0080
  set "esum=!__!"
  call _xword sub !esum! 00!eb!
  set "eres=!__!"
  if "!__c!"=="1" (endlocal & set "__=00000000" & exit /B 0)
  if "!eres!"=="0000" (endlocal & set "__=00000000" & exit /B 0)
  if "!eres:~0,2!" neq "00" (endlocal & exit /B 6)
  set "re=!eres:~2,2!"
  @REM Get mantissas
  call _mbfs getMant !a!
  set "ma=!__!"
  call _mbfs getMant !b!
  set "dsor=!__!"
  @REM Initial bit: check if ma >= dsor
  set "q=00000000"
  call _xdword sub !ma! !dsor!
  if "!__c!" neq "1" goto :_div_firstbit
  @REM ma < dsor: first bit is 0, keep ma as remainder
  set "r=!ma!"
  goto :_div_loop_start
:_div_firstbit
  @REM ma >= dsor: first bit is 1, remainder = ma - dsor
  set "q=00000001"
  set "r=!__!"
:_div_loop_start
  @REM 23 more iterations for fractional bits
  set "_cnt=ABCDEFGHIJKLMNOPQRSTUVW"
:_div_loop
  if "!_cnt!"=="" goto :_div_done
  set "_cnt=!_cnt:~1!"
  @REM Shift remainder left
  call _xdword shl !r!
  set "r=!__!"
  @REM Shift quotient left
  call _xdword shl !q!
  set "q=!__!"
  @REM Compare: remainder >= divisor?
  call _xdword sub !r! !dsor!
  if "!__c!" neq "1" (
    set "r=!__!"
    call _xdword inc !q!
    set "q=!__!"
  )
  goto :_div_loop
:_div_done
  @REM Round-to-nearest.  The quotient loop above truncated the mantissa,
  @REM biasing results ~1 ULP low (1.0/10.0 -> ...CCCC instead of ...CCCD).
  @REM Compute two more quotient bits: g1 = the bit just below the kept
  @REM mantissa, g2 = the next.  Align the mantissa (the integer bit says
  @REM whether a normalize left-shift is needed), then round on the guard.
  call _xdword shl !r!
  set "r=!__!"
  call _xdword sub !r! !dsor!
  set "g1=0"
  if not "!__c!"=="1" set "g1=1"
  if "!g1!"=="1" set "r=!__!"
  call _xdword shl !r!
  set "r=!__!"
  call _xdword sub !r! !dsor!
  set "g2=0"
  if not "!__c!"=="1" set "g2=1"
  if "!g2!"=="1" set "r=!__!"
  set "_intset="
  for %%c in (8 9 A B C D E F) do if "!q:~2,1!"=="%%c" set "_intset=1"
  if defined _intset goto :_div_iset
  @REM quotient < 1: shift left (exp-1); mantissa LSB = g1, guard = g2.
  call _xdword shl !q!
  set "rm=!__!"
  if "!g1!"=="1" call _xdword inc !rm!
  if "!g1!"=="1" set "rm=!__!"
  call _xbyte dec !re!
  set "re=!__!"
  set "guard=!g2!"
  goto :_div_rnd
:_div_iset
  set "rm=!q!"
  set "guard=!g1!"
:_div_rnd
  if "!re!"=="00" (endlocal & set "__=00000000" & exit /B 0)
  if not "!guard!"=="1" goto :_div_pk
  call _xdword inc !rm!
  set "rm=!__!"
  set "_ovf="
  if not "!rm:~0,2!"=="00" set "_ovf=1"
  if defined _ovf call _xdword shr !rm!
  if defined _ovf set "rm=!__!"
  if defined _ovf call _xbyte inc !re!
  if defined _ovf set "re=!__!"
:_div_pk
  call _mbfs pack !re! !rs! !rm!
  endlocal & set "__=%__%" & exit /B 0


@REM === fromDec: decimal string -> MBF single ===
@REM Parses: "3.14", "-100", "1.5E3", ".25", "1E-5"
@REM Algorithm: parse significand + decimal exponent, convert significand
@REM to binary, then mul/div by 10.0 to apply decimal exponent.
@REM Uses set /a at this conversion boundary.

:fromDec
  setlocal EnableDelayedExpansion
  @REM Convert through the accurate DOUBLE fromDec, then round to single
  @REM (round-to-nearest on the first dropped mantissa byte).  The single
  @REM division-by-10 truncated, mis-rounding values such as 0.1, which
  @REM stored 7C4CCCCC instead of 7C4CCCCD.  Double precision is far finer
  @REM than the single rounding step, so the rounded result is correct.
  call _mbfd fromDec %~1
  if errorlevel 1 (endlocal & exit /B !ERRORLEVEL!)
  set "_dd=!__!"
  if "!_dd:~0,2!"=="00" (endlocal & set "__=00000000" & exit /B 0)
  @REM Single = first 4 bytes of the double; the 5th byte is the guard.
  set "_sx=!_dd:~0,8!"
  set /a "_gv=0x!_dd:~8,2!"
  if !_gv! LSS 128 (endlocal & set "__=%_sx%" & exit /B 0)
  @REM Round up: increment the 23-bit fraction, carrying into the exponent
  @REM on overflow.  The sign bit (top of byte 1) is preserved.
  set /a "_ee=0x!_sx:~0,2!"
  set /a "_b1=0x!_sx:~2,2!"
  set /a "_b2=0x!_sx:~4,2!"
  set /a "_b3=0x!_sx:~6,2!"
  set /a "_sgn=_b1 & 128"
  set /a "_frac=(_b1 & 127)*65536 + _b2*256 + _b3"
  set /a "_frac+=1"
  if !_frac! GEQ 8388608 (set /a "_frac=0" & set /a "_ee+=1")
  if !_ee! GTR 255 (endlocal & exit /B 6)
  set /a "_nb1=_sgn + ((_frac>>16) & 127)"
  set /a "_nb2=(_frac>>8) & 255"
  set /a "_nb3=_frac & 255"
  call :_b2h !_ee! _he
  call :_b2h !_nb1! _h1
  call :_b2h !_nb2! _h2
  call :_b2h !_nb3! _h3
  endlocal & set "__=%_he%%_h1%%_h2%%_h3%" & exit /B 0

@REM _b2h BYTE retVar : a 0..255 int to 2 hex chars (module _p_ table).
:_b2h
  set /a "_bh=%~1/16"
  set /a "_bl=%~1%%16"
  for /F "tokens=1,2" %%a in ("!_bh! !_bl!") do set "%~2=!_p_%%a!!_p_%%b!"
  exit /B 0


@REM === toDec: MBF single -> decimal string ===
@REM Avoids _mbfs self-calls (use _xdword/_xbyte ops directly).
@REM Strategy: scale to [1.0, 10.0) via mul/div by 10, extract digits.

:toDec
  setlocal EnableDelayedExpansion
  set "v=%~1"
  @REM Single-precision display.  The single value is exactly
  @REM representable in double, so widen it (append 8 zero hex = 4 zero
  @REM mantissa bytes) and extract 7 significant digits in DOUBLE
  @REM precision.  This avoids the single-precision mul/div-by-10
  @REM extraction error that mis-rendered exact values (73 -> 72.99999,
  @REM 0.1 -> .09999999).  Threshold 7 = switch to E-notation past 7
  @REM integer digits, matching GW single-precision formatting.
  if "!v:~0,2!"=="00" (endlocal & set "__=0" & exit /B 0)
  set "_d16=!v!00000000"
  call _mbfd toDec !_d16! 7 7
  endlocal & set "__=%__%" & exit /B 0


:_start
echo _start@mbfs.bat
