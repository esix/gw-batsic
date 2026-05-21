@echo off
@REM POW: exponentiation (^).  Limited support — non-negative integer
@REM exponent only.  Non-integer or negative exponent → 73 Advanced Feature
@REM (needs LOG/EXP, not implemented yet).
@REM
@REM Computes in the base's type via repeated multiplication.  Integer base
@REM can overflow (16-bit signed) — surfaces as code 6 Overflow.

setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _b
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call %GWSRC%\exec\_resolve !_b! _b
@REM Exponent must be an integer-valued number.
call :_toIntStrict !_b! _expI
if not defined _expI (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 73
)
call %GWSRC%\num\int toDec !_expI!
set "_n=!__!"
if !_n! LSS 0 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 73
)
@REM Pick result type from the base.
set "_ta=!_a:~0,1!"
set "_mod="
if "!_ta!"=="i" set "_mod=int"
if "!_ta!"=="s" set "_mod=sng"
if "!_ta!"=="d" set "_mod=dbl"
if not defined _mod (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
@REM Identity for power 0: 1 in base's type.
if "!_n!"=="0" goto :_pow_zero
@REM Repeated multiply: result = a; for i=2..n: result *= a
set "_r=!_a!"
set /a "_i=1"
:_pow_loop
  if !_i! GEQ !_n! goto :_pow_done
  call %GWSRC%\num\!_mod! mul !_r! !_a!
  set "_e=!ERRORLEVEL!"
  if !_e! neq 0 (
    set "_final=!%_s%!"
    endlocal & set "%~1=%_final%" & exit /B %_e%
  )
  set "_r=!__!"
  set /a "_i+=1"
  goto :_pow_loop
:_pow_done
call %GWSRC%\stl\vec push %_s% !_r!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_pow_zero
@REM Power-0 case at top level so %_final% gets parse-time substituted with
@REM the value set right above the endlocal-line.
if "!_mod!"=="int" set "__=i0001"
if "!_mod!"=="sng" call %GWSRC%\num\sng fromInt i0001
if "!_mod!"=="dbl" call %GWSRC%\num\dbl fromInt i0001
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0


@REM _toIntStrict VALUE retVar — set retVar to int form ONLY if the value is
@REM an integer (int tag, OR float with zero fractional part).  Otherwise
@REM leaves retVar unset.
:_toIntStrict
  setlocal EnableDelayedExpansion
  set "_v=%~1"
  set "_t=!_v:~0,1!"
  if "!_t!"=="i" (endlocal & set "%~2=%_v%" & exit /B 0)
  @REM Float — convert to int then back, see if value preserved.  For now
  @REM accept only when the float was created from an int (simple cases).
  if "!_t!"=="s" (
    call %GWSRC%\num\sng toInt !_v!
    set "_iv=!__!"
    call %GWSRC%\num\sng fromInt !_iv!
    set "_round=!__!"
    if "!_round!"=="!_v!" (endlocal & set "%~2=%_iv%" & exit /B 0)
  )
  if "!_t!"=="d" (
    call %GWSRC%\num\dbl toInt !_v!
    set "_iv=!__!"
    call %GWSRC%\num\dbl fromInt !_iv!
    set "_round=!__!"
    if "!_round!"=="!_v!" (endlocal & set "%~2=%_iv%" & exit /B 0)
  )
  endlocal & exit /B 0
