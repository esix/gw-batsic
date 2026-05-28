@echo off
@REM FN_SQR: SQR(n) — square root, single precision, via Newton's method.
@REM
@REM Iteration: x_{n+1} = (x_n + N/x_n) / 2
@REM Starting from x_0 = N, the iteration roughly doubles correct digits per
@REM step, so ~10 iterations are plenty for single precision (~7 sig figs).
@REM
@REM "Divide by 2" is done by decrementing the MBF exponent byte (cheaper
@REM than a full `sng div`).
@REM
@REM Pure batch, no shell-out — slow but research-clean.
@REM
@REM Stack: NUM_<n> → NUM_s<MBF>.  Errors: 5 (negative), 13 (bad type).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a

@REM Coerce input to sng.  int → sng via fromInt; dbl → sng via toDec round-trip.
set "_t=!_a:~0,1!"
set "_n="
if "!_t!"=="s" set "_n=!_a!"
if "!_t!"=="i" (call %GWSRC%\num\sng fromInt !_a! & set "_n=!__!")
if "!_t!"=="d" (
  call %GWSRC%\num\dbl toDec !_a!
  call %GWSRC%\num\sng fromDec !__!
  set "_n=!__!"
)
if not defined _n (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)

@REM Zero: SQR(0) = 0.  MBF zero has exponent byte 00.  (Emit outside the
@REM if-block — an in-block `endlocal & set "%~1=%_final%"` would expand
@REM %_final% at parse time, before assignment, giving an empty result.)
if "!_n:~1,2!"=="00" (
  set "_x=s00000000"
  goto :_sqr_emit
)

@REM Negative → "Illegal function call" (err 5).
@REM Sign is the high bit of byte 2; in our hex layout that's the high nibble
@REM of position 3 (since byte 1 starts at hex index 1, byte 2 at index 3).
set "_hn=!_n:~3,1!"
set "_neg="
for %%c in (8 9 A B C D E F) do if /I "!_hn!"=="%%c" set "_neg=1"
if defined _neg (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 5
)

@REM Newton iteration.  Initial guess: x = N itself (always positive here).
set "_x=!_n!"
for /L %%i in (1,1,10) do (
  call %GWSRC%\num\sng div !_n! !_x!
  call %GWSRC%\num\sng add !_x! !__!
  call :_half !__! _x
)

:_sqr_emit
call %GWSRC%\stl\vec push %_s% !_x!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0


@REM --- _half VAL retVar ---
@REM In-place "divide by 2" on a sng MBF value by decrementing the exponent
@REM byte.  Underflow (exponent reaches 0) flushes to zero.
:_half
  setlocal EnableDelayedExpansion
  set "_v=%~1"
  set "_eb=!_v:~1,2!"
  if "!_eb!"=="00" (endlocal & set "%~2=s00000000" & exit /B 0)
  set /a "_e=0x!_eb! - 1"
  if !_e! lss 1 (endlocal & set "%~2=s00000000" & exit /B 0)
  set "_hd=0123456789ABCDEF"
  set /a "_h1=_e / 16"
  set /a "_h2=_e %% 16"
  for %%a in (!_h1!) do for %%b in (!_h2!) do set "_eb=!_hd:~%%a,1!!_hd:~%%b,1!"
  set "_rest=!_v:~3!"
  endlocal & set "%~2=s%_eb%%_rest%" & exit /B 0
