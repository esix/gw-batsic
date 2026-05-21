@echo off
@REM DIV: real division (/).  GW-BASIC always produces at least single
@REM precision — int/int → single (NOT truncated int div; that's \ IDIV).
@REM Propagates num-layer errorlevel (11=Division by zero, 6=Overflow,
@REM 13=Type mismatch).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _b
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call %GWSRC%\exec\_resolve !_b! _b
call %GWSRC%\exec\_promote !_a! !_b!
@REM Promote int → single so / always gives a fractional result.
if "!__t!"=="i" (
  call %GWSRC%\num\sng fromInt !__a!
  set "__a=!__!"
  call %GWSRC%\num\sng fromInt !__b!
  set "__b=!__!"
  set "__t=s"
)
set "_mod="
if "!__t!"=="s" set "_mod=sng"
if "!__t!"=="d" set "_mod=dbl"
if not defined _mod (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
call %GWSRC%\num\!_mod! div !__a! !__b!
set "_e=!ERRORLEVEL!"
if !_e! neq 0 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B %_e%
)
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
