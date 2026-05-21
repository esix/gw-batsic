@echo off
@REM Shared comparison kernel for CMP_EQ / CMP_LT / CMP_GT / CMP_LE / CMP_GE / CMP_NE.
@REM
@REM Pops two values, promotes to a common numeric type (int < single < double),
@REM compares, and pushes the GW-BASIC boolean result:
@REM   true   = -1   (all bits set in 16-bit int → "iFFFF")
@REM   false  =  0   ("i0000")
@REM
@REM Args:
@REM   %1 = stack-var name (e.g. _stk)
@REM   %2 = comparison op: EQ / LT / GT / LE / GE / NE
@REM
@REM String comparison is not implemented yet — STR vs STR returns Type Mismatch
@REM (13).  Mixed STR / numeric is also Type Mismatch.

setlocal EnableDelayedExpansion
set "_s=%~1"
set "_op=%~2"
call %GWSRC%\stl\vec pop %_s% _b
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call %GWSRC%\exec\_resolve !_b! _b

@REM String compare: both STR_, lexicographic on the underlying bytes.
@REM Mixed string vs numeric → 13 Type mismatch.
set "_aIsStr="
set "_bIsStr="
if "!_a:~0,4!"=="STR_" set "_aIsStr=1"
if "!_b:~0,4!"=="STR_" set "_bIsStr=1"
if defined _aIsStr if defined _bIsStr (
  call :_strCmp "!_a:~4!" "!_b:~4!" _c
  goto :_cmp_apply
)
if defined _aIsStr (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
if defined _bIsStr (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)

call %GWSRC%\exec\_promote !_a! !_b!
set "_mod="
if "!__t!"=="i" set "_mod=int"
if "!__t!"=="s" set "_mod=sng"
if "!__t!"=="d" set "_mod=dbl"
if not defined _mod (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
call %GWSRC%\num\!_mod! cmp !__a! !__b!
set "_c=!__!"

:_cmp_apply
@REM _c is "0" (equal), "1" (a > b), or "2" (a < b)
set "_r=0"
if "!_op!"=="EQ" if "!_c!"=="0" set "_r=-1"
if "!_op!"=="NE" if not "!_c!"=="0" set "_r=-1"
if "!_op!"=="LT" if "!_c!"=="2" set "_r=-1"
if "!_op!"=="GT" if "!_c!"=="1" set "_r=-1"
if "!_op!"=="LE" if not "!_c!"=="1" set "_r=-1"
if "!_op!"=="GE" if not "!_c!"=="2" set "_r=-1"
if "!_r!"=="-1" (set "_v=iFFFF") else (set "_v=i0000")
call %GWSRC%\stl\vec push %_s% !_v!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0


@REM _strCmp "HEX_A" "HEX_B" retVar
@REM Lexicographic byte compare of two hex strings.  Returns "0" eq, "1" a>b,
@REM "2" a<b.  Compares 2 hex chars (one byte) at a time so length differences
@REM work correctly: "abc" > "ab" because the third byte exists on left only.
:_strCmp
  setlocal EnableDelayedExpansion
  set "_ha=%~1"
  set "_hb=%~2"
  set "_r=0"
:_sc_loop
  set "_xa=!_ha:~0,2!"
  set "_xb=!_hb:~0,2!"
  if "!_xa!"=="" if "!_xb!"=="" goto :_sc_done
  if "!_xa!"=="" (set "_r=2" & goto :_sc_done)
  if "!_xb!"=="" (set "_r=1" & goto :_sc_done)
  if not "!_xa!"=="!_xb!" (
    set /a "_va=0x!_xa!"
    set /a "_vb=0x!_xb!"
    if !_va! GTR !_vb! (set "_r=1") else (set "_r=2")
    goto :_sc_done
  )
  set "_ha=!_ha:~2!"
  set "_hb=!_hb:~2!"
  goto :_sc_loop
:_sc_done
  endlocal & set "%~3=%_r%" & exit /B 0
