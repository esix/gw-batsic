@echo off
@REM FN_INT: floor (round toward -infinity).  Differs from FIX for negatives
@REM with a fractional part: INT(-3.7) = -4, FIX(-3.7) = -3.
@REM Result type matches input.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
if "!_t!"=="i" (set "__=!_a!" & goto :_int_push)

@REM Float path: truncate toward zero, then subtract 1 if the original was
@REM negative and the trunc isn't equal to it (i.e. had a fractional part).
if "!_t!"=="s" (
  call %GWSRC%\num\sng toInt !_a!
  set "_iv=!__!"
  call %GWSRC%\num\sng fromInt !_iv!
  set "_round=!__!"
  @REM Check sign + fractional-part presence.
  if not "!_round!"=="!_a!" (
    set "_d=!_a:~3,1!"
    set "_neg="
    for %%c in (8 9 A B C D E F) do if "!_d!"=="%%c" set "_neg=1"
    if defined _neg (
      @REM Decrement int by 1, then back to sng.
      call %GWSRC%\num\int sub !_iv! i0001
      set "_iv=!__!"
      call %GWSRC%\num\sng fromInt !_iv!
    )
  )
  goto :_int_push
)
if "!_t!"=="d" (
  call %GWSRC%\num\dbl toInt !_a!
  set "_iv=!__!"
  call %GWSRC%\num\dbl fromInt !_iv!
  set "_round=!__!"
  if not "!_round!"=="!_a!" (
    set "_d=!_a:~3,1!"
    set "_neg="
    for %%c in (8 9 A B C D E F) do if "!_d!"=="%%c" set "_neg=1"
    if defined _neg (
      call %GWSRC%\num\int sub !_iv! i0001
      set "_iv=!__!"
      call %GWSRC%\num\dbl fromInt !_iv!
    )
  )
  goto :_int_push
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 13

:_int_push
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
