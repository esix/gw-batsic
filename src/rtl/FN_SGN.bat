@echo off
@REM FN_SGN: sign — returns -1 / 0 / 1 as integer.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
set "_r=0"
if "!_t!"=="i" (
  if "!_a:~1!"=="0000" set "_r=0"
  if not "!_a:~1!"=="0000" (
    set "_d=!_a:~1,1!"
    set "_neg="
    for %%c in (8 9 A B C D E F) do if "!_d!"=="%%c" set "_neg=1"
    if defined _neg (set "_r=-1") else (set "_r=1")
  )
  goto :_sgn_push
)
if "!_t!"=="s" (
  if "!_a:~1!"=="00000000" (set "_r=0" & goto :_sgn_push)
  set "_d=!_a:~3,1!"
  set "_neg="
  for %%c in (8 9 A B C D E F) do if "!_d!"=="%%c" set "_neg=1"
  if defined _neg (set "_r=-1") else (set "_r=1")
  goto :_sgn_push
)
if "!_t!"=="d" (
  if "!_a:~1!"=="0000000000000000" (set "_r=0" & goto :_sgn_push)
  set "_d=!_a:~3,1!"
  set "_neg="
  for %%c in (8 9 A B C D E F) do if "!_d!"=="%%c" set "_neg=1"
  if defined _neg (set "_r=-1") else (set "_r=1")
  goto :_sgn_push
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 13

:_sgn_push
call %GWSRC%\num\int fromDec !_r!
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
