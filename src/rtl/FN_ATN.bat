@echo off
@REM FN_ATN: arctan(x), principal value in (-π/2, π/2), single precision.
@REM
@REM atan is odd → work on |x|, reapply the sign at the end.
@REM For a > 1 use atan(a) = π/2 - atan(1/a) to bring the argument to [0,1].
@REM Half-angle reduction (one sqrt) shrinks it further:
@REM   atan(a) = 2·atan( a / (1 + sqrt(1+a²)) )
@REM For a in [0,1] the reduced argument is ≤ tan(π/8) ≈ 0.414, where the
@REM series atan(t) = t - t³/3 + t⁵/5 - ... converges in ~7 terms.
@REM
@REM Stack: NUM_<n> → NUM_s<atan>.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a

set "_t=!_a:~0,1!"
set "_x="
if "!_t!"=="s" set "_x=!_a!"
if "!_t!"=="i" (call %GWSRC%\num\sng fromInt !_a! & set "_x=!__!")
if "!_t!"=="d" (
  call %GWSRC%\num\dbl toDec !_a!
  call %GWSRC%\num\sng fromDec !__!
  set "_x=!__!"
)
if not defined _x (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)

@REM Zero shortcut.  (Push + emit must happen outside this if-block: an
@REM `endlocal & set "%~1=%_final%"` here would expand %_final% at block
@REM parse time, before it's assigned — yielding an empty result.)
if "!_x:~1,2!"=="00" (
  set "_res=s00000000"
  goto :_atn_emit
)

@REM Sign, then absolute value.
set "_neg="
set "_hn=!_x:~3,1!"
for %%c in (8 9 A B C D E F) do if /I "!_hn!"=="%%c" set "_neg=1"
call %GWSRC%\num\sng abs !_x!
set "_av=!__!"

call %GWSRC%\num\sng fromDec 1
set "_one=!__!"

@REM Reciprocal for a > 1.
set "_recip="
call %GWSRC%\num\sng cmp !_av! !_one!
if "!__!"=="1" (
  set "_recip=1"
  call %GWSRC%\num\sng div !_one! !_av!
  set "_av=!__!"
)

@REM Half-angle: h = a / (1 + sqrt(1 + a²)).
call %GWSRC%\num\sng mul !_av! !_av!
call %GWSRC%\num\sng add !__! !_one!
set "_scratch=!__!"
call %GWSRC%\rtl\FN_SQR _scratch
call %GWSRC%\stl\vec pop _scratch _sq
call %GWSRC%\num\sng add !_sq! !_one!
set "_denom=!__!"
call %GWSRC%\num\sng div !_av! !_denom!
set "_h=!__!"

@REM Taylor on h:  sum = h, term = h, factor -h².
call %GWSRC%\num\sng mul !_h! !_h!
call %GWSRC%\num\sng neg !__!
set "_nh2=!__!"
set "_sum=!_h!"
set "_term=!_h!"
for %%k in (3 5 7 9 11 13) do (
  call %GWSRC%\num\sng mul !_term! !_nh2!
  set "_term=!__!"
  call %GWSRC%\num\sng fromDec %%k
  call %GWSRC%\num\sng div !_term! !__!
  call %GWSRC%\num\sng add !_sum! !__!
  set "_sum=!__!"
)

@REM Undo half-angle: atan(a) = 2·sum.
call %GWSRC%\num\sng fromDec 2
call %GWSRC%\num\sng mul !_sum! !__!
set "_res=!__!"

@REM Undo reciprocal: atan(a) = π/2 - atan(1/a).
if defined _recip (
  call %GWSRC%\num\sng fromDec 1.570796
  call %GWSRC%\num\sng sub !__! !_res!
  set "_res=!__!"
)

@REM Reapply sign.
if defined _neg (
  call %GWSRC%\num\sng neg !_res!
  set "_res=!__!"
)

:_atn_emit
call %GWSRC%\stl\vec push %_s% !_res!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
