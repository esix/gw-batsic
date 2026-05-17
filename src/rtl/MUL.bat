@echo off
@REM MUL: pop two values, promote to common numeric type, multiply, push result.
@REM Propagates the num-layer errorlevel (6=Overflow, 13=Type mismatch).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _b
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call %GWSRC%\exec\_resolve !_b! _b
call %GWSRC%\exec\_promote !_a! !_b!
set "_mod="
if "!__t!"=="i" set "_mod=int"
if "!__t!"=="s" set "_mod=sng"
if "!__t!"=="d" set "_mod=dbl"
if not defined _mod (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
call %GWSRC%\num\!_mod! mul !__a! !__b!
set "_e=!ERRORLEVEL!"
if !_e! neq 0 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B %_e%
)
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
