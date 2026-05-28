@echo off
@REM FN_LOG: ln(x), natural logarithm, single precision.
@REM
@REM Decompose the MBF value x = m · 2^e with m in [1, 2):
@REM   the exponent byte EE encodes e = EE - 128, and m is x with its
@REM   exponent byte forced to 0x80.
@REM Then ln(x) = ln(m) + e·ln2.
@REM ln(m) via the fast atanh series (t = (m-1)/(m+1), m in [1,2) → t small):
@REM   ln(m) = 2·(t + t³/3 + t⁵/5 + t⁷/7 + ...)
@REM
@REM Stack: NUM_<n> → NUM_s<ln>.  Err 5 if x <= 0.
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

@REM x <= 0 → Illegal function call.  Zero: exponent byte 00.  Negative: high
@REM nibble of byte 2 set.
if "!_x:~1,2!"=="00" (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 5
)
set "_hn=!_x:~3,1!"
for %%c in (8 9 A B C D E F) do if /I "!_hn!"=="%%c" (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 5
)

@REM e = EE - 128 ; m = x with exponent byte set to 0x80.
set /a "_e=0x!_x:~1,2! - 128"
set "_m=s80!_x:~3!"

@REM t = (m - 1) / (m + 1)
call %GWSRC%\num\sng fromDec 1
set "_one=!__!"
call %GWSRC%\num\sng sub !_m! !_one!
set "_mm1=!__!"
call %GWSRC%\num\sng add !_m! !_one!
set "_mp1=!__!"
call %GWSRC%\num\sng div !_mm1! !_mp1!
set "_tt=!__!"

@REM t² for the series step.
call %GWSRC%\num\sng mul !_tt! !_tt!
set "_t2=!__!"

@REM sum = t + t³/3 + t⁵/5 + ...   term starts at t.
set "_sum=!_tt!"
set "_term=!_tt!"
for %%k in (3 5 7 9 11 13) do (
  call %GWSRC%\num\sng mul !_term! !_t2!
  set "_term=!__!"
  call %GWSRC%\num\sng fromDec %%k
  call %GWSRC%\num\sng div !_term! !__!
  call %GWSRC%\num\sng add !_sum! !__!
  set "_sum=!__!"
)

@REM ln(m) = 2 · sum
call %GWSRC%\num\sng fromDec 2
call %GWSRC%\num\sng mul !_sum! !__!
set "_lnm=!__!"

@REM ln(x) = ln(m) + e·ln2
call %GWSRC%\num\sng fromDec 0.693147
set "_LN2=!__!"
call %GWSRC%\num\int fromDec !_e!
call %GWSRC%\num\sng fromInt !__!
call %GWSRC%\num\sng mul !__! !_LN2!
call %GWSRC%\num\sng add !_lnm! !__!
set "_res=!__!"

call %GWSRC%\stl\vec push %_s% !_res!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
