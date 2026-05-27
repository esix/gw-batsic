@echo off
@REM FN_RND: GW-BASIC RND[(arg)] — next pseudo-random single-precision in [0, 1).
@REM
@REM Stack: arg → result (NUM_s<MBF>).
@REM
@REM GW-BASIC semantics:
@REM   arg > 0  next random number (we always do this)
@REM   arg = 0  return the previous result
@REM   arg < 0  reseed and return that seed's first number
@REM
@REM This is a simplified implementation using cmd.exe's %RANDOM% (0..32767).
@REM The "last value" caching (arg=0) and seeding (arg<0) are best-effort —
@REM since each /R invocation is a fresh process, persistent state isn't
@REM meaningful.  Within a single RUN we keep the last sng result in
@REM _rnd_last so RND(0) can return it.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a

@REM Determine whether arg is positive, zero, or negative.  Only the i-typed
@REM 16-bit case is exercised by RND(0), RND(-N), RND(1).  For sng/dbl the
@REM common literal `1`, `0`, etc. would already be int after parsing.
set "_t=!_a:~0,1!"
set "_argkind=+"
if "!_t!"=="i" (
  set "_lo=!_a:~1!"
  set /a "_iv=0x!_lo!"
  if !_iv! equ 0 set "_argkind=0"
  @REM 16-bit negative: high nibble of hex >= 8.
  set "_hi=!_a:~1,1!"
  for %%c in (8 9 A B C D E F) do if /I "!_hi!"=="%%c" set "_argkind=-"
)

if "!_argkind!"=="0" if defined _rnd_last (
  call %GWSRC%\stl\vec push %_s% !_rnd_last!
  set "_final=!%_s%!"
  endlocal ^
    & set "%~1=%_final%" ^
    & exit /B 0
)

@REM Positive or negative arg, or no _rnd_last yet → generate next number.
@REM Use cmd's %RANDOM% (0..32767).  Scale to 0..9999 to feed a 4-decimal
@REM fraction "0.dddd" — enough precision for sng (which has ~7 sig figs)
@REM and avoids overflowing 32-bit set /a on the intermediate multiply.
set /a "_r=%RANDOM%"
set /a "_n4=_r * 10000 / 32768"
set "_padded=0000!_n4!"
set "_padded=!_padded:~-4!"
call %GWSRC%\num\sng fromDec 0.!_padded!
if errorlevel 1 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
set "_result=!__!"
call %GWSRC%\stl\vec push %_s% !_result!
set "_final=!%_s%!"
endlocal ^
  & set "%~1=%_final%" ^
  & set "_rnd_last=%_result%" ^
  & exit /B 0
