@echo off
@REM FN_ABS: absolute value, preserving type.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
if "!_t!"=="i" (
  @REM Negative ints have bit 15 set; if so, negate.
  set "_d=!_a:~1,1!"
  set "_neg=0"
  for %%c in (8 9 A B C D E F) do if "!_d!"=="%%c" set "_neg=1"
  if "!_neg!"=="1" (
    call %GWSRC%\num\int neg !_a!
  ) else (
    set "__=!_a!"
  )
  goto :_abs_push
)
if "!_t!"=="s" (call %GWSRC%\num\sng abs !_a! & goto :_abs_push)
if "!_t!"=="d" (call %GWSRC%\num\dbl abs !_a! & goto :_abs_push)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 13

:_abs_push
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
