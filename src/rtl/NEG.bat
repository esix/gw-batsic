@echo off
@REM NEG: pop one value, negate (in its own type), push result.
@REM Propagates the num-layer errorlevel (6=Overflow, 13=Type mismatch).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
set "_mod="
if "!_t!"=="i" set "_mod=int"
if "!_t!"=="s" set "_mod=sng"
if "!_t!"=="d" set "_mod=dbl"
if not defined _mod (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
call %GWSRC%\num\!_mod! neg !_a!
set "_e=!ERRORLEVEL!"
if !_e! neq 0 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B %_e%
)
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
