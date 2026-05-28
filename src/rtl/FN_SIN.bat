@echo off
@REM FN_SIN: sin(x), single precision, via Taylor series.
@REM
@REM Range reduce x to [0, π/2], then Taylor:
@REM   sin(z) = z - z³/3! + z⁵/5! - z⁷/7! + ...
@REM 6 terms give ~7 sig figs for z in [0, π/2].
@REM
@REM Reduction steps:
@REM   y = x - 2π·trunc(x/2π)             y in (-2π, 2π)
@REM   if y < 0:  y = y + 2π              y in [0, 2π)
@REM   quadrant pick:
@REM     [0,    π/2]:  z = y;       sign = +
@REM     [π/2,  π  ]:  z = π - y;   sign = +
@REM     [π,    3π/2]: z = y - π;   sign = -
@REM     [3π/2, 2π ]:  z = 2π - y;  sign = -
@REM
@REM Pure batch, ~5 s per call.
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

@REM --- constants ---
call %GWSRC%\num\sng fromDec 3.141593
set "_PI=!__!"
call %GWSRC%\num\sng fromDec 6.283185
set "_TWO_PI=!__!"
call %GWSRC%\num\sng fromDec 1.570796
set "_PI_2=!__!"
call %GWSRC%\num\sng fromDec 4.712389
set "_3PI_2=!__!"

@REM --- range reduce: y = x - 2π * trunc(x / 2π) ---
call %GWSRC%\num\sng div !_x! !_TWO_PI!
set "_q=!__!"
call %GWSRC%\num\sng toInt !_q!
set "_qi=!__!"
call %GWSRC%\num\sng fromInt !_qi!
set "_qs=!__!"
call %GWSRC%\num\sng mul !_qs! !_TWO_PI!
set "_qs2pi=!__!"
call %GWSRC%\num\sng sub !_x! !_qs2pi!
set "_y=!__!"

@REM Shift y to [0, 2π) if negative.
set "_yhn=!_y:~3,1!"
set "_yneg="
for %%c in (8 9 A B C D E F) do if /I "!_yhn!"=="%%c" set "_yneg=1"
if defined _yneg (
  call %GWSRC%\num\sng add !_y! !_TWO_PI!
  set "_y=!__!"
)

@REM --- quadrant analysis ---
set "_sign=+"
set "_z=!_y!"
call %GWSRC%\num\sng cmp !_y! !_PI_2!
if "!__!"=="1" (
  call %GWSRC%\num\sng cmp !_y! !_PI!
  if "!__!"=="1" (
    call %GWSRC%\num\sng cmp !_y! !_3PI_2!
    if "!__!"=="1" (
      @REM y in [3π/2, 2π]
      set "_sign=-"
      call %GWSRC%\num\sng sub !_TWO_PI! !_y!
      set "_z=!__!"
    ) else (
      @REM y in [π, 3π/2]
      set "_sign=-"
      call %GWSRC%\num\sng sub !_y! !_PI!
      set "_z=!__!"
    )
  ) else (
    @REM y in [π/2, π]
    call %GWSRC%\num\sng sub !_PI! !_y!
    set "_z=!__!"
  )
)

@REM --- Taylor: sum = z, term = z, iterate ---
call %GWSRC%\num\sng mul !_z! !_z!
set "_z2=!__!"
call %GWSRC%\num\sng neg !_z2!
set "_nz2=!__!"

set "_sum=!_z!"
set "_term=!_z!"
@REM Denominators (2n)(2n+1) for n=1..6.
for %%d in (6 20 42 72 110 156) do (
  call %GWSRC%\num\sng mul !_term! !_nz2!
  set "_term=!__!"
  call %GWSRC%\num\sng fromDec %%d
  call %GWSRC%\num\sng div !_term! !__!
  set "_term=!__!"
  call %GWSRC%\num\sng add !_sum! !_term!
  set "_sum=!__!"
)

if "!_sign!"=="-" (
  call %GWSRC%\num\sng neg !_sum!
  set "_sum=!__!"
)

call %GWSRC%\stl\vec push %_s% !_sum!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
