@echo off
@REM Hex-to-decimal lookup (set once on entry, used by binary ops)
set "_s_0=0"& set "_s_1=1"& set "_s_2=2"& set "_s_3=3"& set "_s_4=4"& set "_s_5=5"& set "_s_6=6"& set "_s_7=7"
set "_s_8=8"& set "_s_9=9"& set "_s_A=10"& set "_s_B=11"& set "_s_C=12"& set "_s_D=13"& set "_s_E=14"& set "_s_F=15"
@REM Decimal-to-hex lookup
set "_p_0=0"& set "_p_1=1"& set "_p_2=2"& set "_p_3=3"& set "_p_4=4"& set "_p_5=5"& set "_p_6=6"& set "_p_7=7"
set "_p_8=8"& set "_p_9=9"& set "_p_10=A"& set "_p_11=B"& set "_p_12=C"& set "_p_13=D"& set "_p_14=E"& set "_p_15=F"
if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:check v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  if "!v:~1,1!" neq "" endlocal & exit /B 1
  for %%l in (0 1 2 3 4 5 6 7 8 9 A B C D E F) do (
    if "!v!"=="%%l" endlocal & exit /B 0
  )
  endlocal & exit /B 1


:serialize v ret
  setlocal EnableDelayedExpansion
  set "v=%~1"
  set "r=!_s_%v%!"
  if "!r!"=="" endlocal & exit /B 1
  endlocal & set "%~2=%r%" & exit /B 0


:parse dec ret
  setlocal EnableDelayedExpansion
  set "d=%~1"
  set "r=!_p_%d%!"
  if "!r!"=="" endlocal & exit /B 1
  endlocal & set "%~2=%r%" & exit /B 0


@REM === Unary ops: goto-dispatch tables (no call :label needed) ===

:inc v
  goto :_inc_%~1
:_inc_0
  set "__=1"& set "__c="& exit /B 0
:_inc_1
  set "__=2"& set "__c="& exit /B 0
:_inc_2
  set "__=3"& set "__c="& exit /B 0
:_inc_3
  set "__=4"& set "__c="& exit /B 0
:_inc_4
  set "__=5"& set "__c="& exit /B 0
:_inc_5
  set "__=6"& set "__c="& exit /B 0
:_inc_6
  set "__=7"& set "__c="& exit /B 0
:_inc_7
  set "__=8"& set "__c="& exit /B 0
:_inc_8
  set "__=9"& set "__c="& exit /B 0
:_inc_9
  set "__=A"& set "__c="& exit /B 0
:_inc_A
  set "__=B"& set "__c="& exit /B 0
:_inc_B
  set "__=C"& set "__c="& exit /B 0
:_inc_C
  set "__=D"& set "__c="& exit /B 0
:_inc_D
  set "__=E"& set "__c="& exit /B 0
:_inc_E
  set "__=F"& set "__c="& exit /B 0
:_inc_F
  set "__=0"& set "__c=1"& exit /B 0


:dec v
  goto :_dec_%~1
:_dec_0
  set "__=F"& set "__c=1"& exit /B 0
:_dec_1
  set "__=0"& set "__c="& exit /B 0
:_dec_2
  set "__=1"& set "__c="& exit /B 0
:_dec_3
  set "__=2"& set "__c="& exit /B 0
:_dec_4
  set "__=3"& set "__c="& exit /B 0
:_dec_5
  set "__=4"& set "__c="& exit /B 0
:_dec_6
  set "__=5"& set "__c="& exit /B 0
:_dec_7
  set "__=6"& set "__c="& exit /B 0
:_dec_8
  set "__=7"& set "__c="& exit /B 0
:_dec_9
  set "__=8"& set "__c="& exit /B 0
:_dec_A
  set "__=9"& set "__c="& exit /B 0
:_dec_B
  set "__=A"& set "__c="& exit /B 0
:_dec_C
  set "__=B"& set "__c="& exit /B 0
:_dec_D
  set "__=C"& set "__c="& exit /B 0
:_dec_E
  set "__=D"& set "__c="& exit /B 0
:_dec_F
  set "__=E"& set "__c="& exit /B 0


:inv v
  goto :_not_%~1
:_not_0
  set "__=F"& exit /B 0
:_not_1
  set "__=E"& exit /B 0
:_not_2
  set "__=D"& exit /B 0
:_not_3
  set "__=C"& exit /B 0
:_not_4
  set "__=B"& exit /B 0
:_not_5
  set "__=A"& exit /B 0
:_not_6
  set "__=9"& exit /B 0
:_not_7
  set "__=8"& exit /B 0
:_not_8
  set "__=7"& exit /B 0
:_not_9
  set "__=6"& exit /B 0
:_not_A
  set "__=5"& exit /B 0
:_not_B
  set "__=4"& exit /B 0
:_not_C
  set "__=3"& exit /B 0
:_not_D
  set "__=2"& exit /B 0
:_not_E
  set "__=1"& exit /B 0
:_not_F
  set "__=0"& exit /B 0


:shr v
  goto :_shr_%~1
:_shr_0
  set "__=0"& set "__c="& exit /B 0
:_shr_1
  set "__=0"& set "__c=1"& exit /B 0
:_shr_2
  set "__=1"& set "__c="& exit /B 0
:_shr_3
  set "__=1"& set "__c=1"& exit /B 0
:_shr_4
  set "__=2"& set "__c="& exit /B 0
:_shr_5
  set "__=2"& set "__c=1"& exit /B 0
:_shr_6
  set "__=3"& set "__c="& exit /B 0
:_shr_7
  set "__=3"& set "__c=1"& exit /B 0
:_shr_8
  set "__=4"& set "__c="& exit /B 0
:_shr_9
  set "__=4"& set "__c=1"& exit /B 0
:_shr_A
  set "__=5"& set "__c="& exit /B 0
:_shr_B
  set "__=5"& set "__c=1"& exit /B 0
:_shr_C
  set "__=6"& set "__c="& exit /B 0
:_shr_D
  set "__=6"& set "__c=1"& exit /B 0
:_shr_E
  set "__=7"& set "__c="& exit /B 0
:_shr_F
  set "__=7"& set "__c=1"& exit /B 0


:shl v
  goto :_shl_%~1
:_shl_0
  set "__=0"& set "__c="& exit /B 0
:_shl_1
  set "__=2"& set "__c="& exit /B 0
:_shl_2
  set "__=4"& set "__c="& exit /B 0
:_shl_3
  set "__=6"& set "__c="& exit /B 0
:_shl_4
  set "__=8"& set "__c="& exit /B 0
:_shl_5
  set "__=A"& set "__c="& exit /B 0
:_shl_6
  set "__=C"& set "__c="& exit /B 0
:_shl_7
  set "__=E"& set "__c="& exit /B 0
:_shl_8
  set "__=0"& set "__c=1"& exit /B 0
:_shl_9
  set "__=2"& set "__c=1"& exit /B 0
:_shl_A
  set "__=4"& set "__c=1"& exit /B 0
:_shl_B
  set "__=6"& set "__c=1"& exit /B 0
:_shl_C
  set "__=8"& set "__c=1"& exit /B 0
:_shl_D
  set "__=A"& set "__c=1"& exit /B 0
:_shl_E
  set "__=C"& set "__c=1"& exit /B 0
:_shl_F
  set "__=E"& set "__c=1"& exit /B 0


@REM === addc / subc: delegates to inc / dec via goto ===

:addc v c
  if "%~2"=="1" goto :inc
  set "__=%~1"& set "__c="& exit /B 0

:subc v c
  if "%~2"=="1" goto :dec
  set "__=%~1"& set "__c="& exit /B 0


@REM === Binary ops: env-var lookup tables + set /a ===
@REM Uses _s_ (hex->dec) and _p_ (dec->hex) tables set at file entry.
@REM No call :label — only env var indirection via !_s_%v%! pattern.

:add
  setlocal EnableDelayedExpansion
  set "v1=%~1"& set "v2=%~2"
  set /a "d=!_s_%v1%!+!_s_%v2%!"
  set "c="
  if !d! GEQ 16 set /a "d=d-16" & set "c=1"
  set "r=!_p_%d%!"
  endlocal & set "__=%r%" & set "__c=%c%" & exit /B 0


:sub
  setlocal EnableDelayedExpansion
  set "v1=%~1"& set "v2=%~2"
  set /a "d=!_s_%v1%!-!_s_%v2%!"
  set "c="
  if !d! LSS 0 set /a "d=d+16" & set "c=1"
  set "r=!_p_%d%!"
  endlocal & set "__=%r%" & set "__c=%c%" & exit /B 0


:mul
  setlocal EnableDelayedExpansion
  set "v1=%~1"& set "v2=%~2"
  set /a "d=!_s_%v1%!*!_s_%v2%!"
  set /a "h=d/16"& set /a "l=d%%16"
  set "rh=!_p_%h%!"& set "rl=!_p_%l%!"
  endlocal & set "__=%rh%%rl%" & exit /B 0


:and
  setlocal EnableDelayedExpansion
  set "v1=%~1"& set "v2=%~2"
  set /a "d=!_s_%v1%!&!_s_%v2%!"
  set "r=!_p_%d%!"
  endlocal & set "__=%r%" & exit /B 0


:or
  setlocal EnableDelayedExpansion
  set "v1=%~1"& set "v2=%~2"
  set /a "d=!_s_%v1%!|!_s_%v2%!"
  set "r=!_p_%d%!"
  endlocal & set "__=%r%" & exit /B 0


:xor
  setlocal EnableDelayedExpansion
  set "v1=%~1"& set "v2=%~2"
  set /a "d1=!_s_%v1%!"& set /a "d2=!_s_%v2%!"
  set /a "d=(d1|d2)-(d1&d2)"
  set "r=!_p_%d%!"
  endlocal & set "__=%r%" & exit /B 0


:_start
echo _start@xhalf.bat
