@echo off
@REM FN_STRING: STRING$(n, x) - n copies of a single character.  x is either
@REM a number (ASCII code) or a string (its first character is used).
@REM Stack: <n> <x> -> STR_<2hex * n>.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _ch
call %GWSRC%\stl\vec pop %_s% _n
call %GWSRC%\exec\_resolve !_ch! _ch
call %GWSRC%\exec\_resolve !_n! _n
call :_toint !_n! _cnt
if !_cnt! LSS 0 (set "_final=!%_s%!" & endlocal & set "%~1=%_final%" & exit /B 5)
@REM Determine the repeated hex pair from x.
set "_pair="
if "!_ch:~0,4!"=="STR_" (
  set "_body=!_ch:~4!"
  if "!_body!"=="" (set "_final=!%_s%!" & endlocal & set "%~1=%_final%" & exit /B 5)
  set "_pair=!_body:~0,2!"
) else (
  call :_toint !_ch! _code
  if !_code! LSS 0 (set "_final=!%_s%!" & endlocal & set "%~1=%_final%" & exit /B 5)
  if !_code! GTR 255 (set "_final=!%_s%!" & endlocal & set "%~1=%_final%" & exit /B 5)
  set /a "_h1=_code/16"
  set /a "_h2=_code%%16"
  set "_HD=0123456789ABCDEF"
  for %%x in (!_h1!) do set "_d1=!_HD:~%%x,1!"
  for %%y in (!_h2!) do set "_d2=!_HD:~%%y,1!"
  set "_pair=!_d1!!_d2!"
)
set "_out="
set /a "_i=0"
:_st_loop
  if !_i! GEQ !_cnt! goto :_st_done
  set "_out=!_out!!_pair!"
  set /a "_i+=1"
  goto :_st_loop
:_st_done
call %GWSRC%\stl\vec push %_s% STR_!_out!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_toint
  set "_v=%~1"
  set "_t=!_v:~0,1!"
  if "!_t!"=="i" (call %GWSRC%\num\int toDec !_v! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  set "%~2=0"
  exit /B 0
