@echo off
@REM FN_EXP: e^x, single precision.
@REM
@REM Argument reduction:  x = k·ln2 + r,  k = trunc(x/ln2),  r in (-ln2, ln2)
@REM   e^x = 2^k · e^r
@REM e^r via Taylor (|r| < ln2 ≈ 0.693, converges fast):
@REM   e^r = 1 + r + r²/2! + r³/3! + ... (8 terms)
@REM 2^k is applied by adding k to the MBF exponent byte.
@REM
@REM Stack: NUM_<n> → NUM_s<exp>.
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

call %GWSRC%\num\sng fromDec 0.693147
set "_LN2=!__!"

@REM k = trunc(x / ln2)
call %GWSRC%\num\sng div !_x! !_LN2!
call %GWSRC%\num\sng toInt !__!
set "_ki=!__!"
call %GWSRC%\num\int toDec !_ki!
set "_kdec=!__!"

@REM r = x - k·ln2
call %GWSRC%\num\sng fromInt !_ki!
call %GWSRC%\num\sng mul !__! !_LN2!
call %GWSRC%\num\sng sub !_x! !__!
set "_r=!__!"

@REM e^r via Taylor: sum = 1, term = 1, term *= r/n each step.
call %GWSRC%\num\sng fromDec 1
set "_sum=!__!"
set "_term=!__!"
set "_n=1"
:_exp_loop
  if !_n! GTR 8 goto :_exp_done
  call %GWSRC%\num\sng mul !_term! !_r!
  set "_term=!__!"
  call %GWSRC%\num\sng fromDec !_n!
  call %GWSRC%\num\sng div !_term! !__!
  set "_term=!__!"
  call %GWSRC%\num\sng add !_sum! !_term!
  set "_sum=!__!"
  set /a "_n+=1"
  goto :_exp_loop
:_exp_done

@REM Apply 2^k by shifting the exponent byte of _sum by k.
call :_scalePow2 !_sum! !_kdec! _result

call %GWSRC%\stl\vec push %_s% !_result!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0


@REM --- _scalePow2 VAL K retVar : multiply sng VAL by 2^K via exponent byte ---
:_scalePow2
  setlocal EnableDelayedExpansion
  set "_v=%~1"
  set "_k=%~2"
  if "!_v:~1,2!"=="00" (endlocal & set "%~3=s00000000" & exit /B 0)
  set /a "_e=0x!_v:~1,2! + _k"
  if !_e! LEQ 0 (endlocal & set "%~3=s00000000" & exit /B 0)
  if !_e! GTR 255 (endlocal & set "%~3=!_v!" & exit /B 0)
  set "_hd=0123456789ABCDEF"
  set /a "_h1=_e / 16"
  set /a "_h2=_e %% 16"
  for %%a in (!_h1!) do for %%b in (!_h2!) do set "_eb=!_hd:~%%a,1!!_hd:~%%b,1!"
  set "_rest=!_v:~3!"
  endlocal & set "%~3=s%_eb%%_rest%" & exit /B 0
