@echo off
@REM MKS$(n): pack a number as a 4-byte MBF disk single (mantissa LE, exp last,
@REM exponent bias 129 = our internal 128 + 1).
setlocal EnableDelayedExpansion
@REM _xbyte calls _xhalf via PATH; add the num dir so the bias inc/dec resolve.
set "PATH=%GWSRC%\num;%PATH%"
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
set "_sh="
if "!_t!"=="s" set "_sh=!_a:~1!"
if "!_t!"=="i" (call %GWSRC%\num\int toDec !_a! & call %GWSRC%\num\sng fromDec !__! & set "_sh=!__:~1!")
if "!_t!"=="d" (call %GWSRC%\num\dbl toDec !_a! & call %GWSRC%\num\sng fromDec !__! & set "_sh=!__:~1!")
set "_ee=!_sh:~0,2!"
if "!_ee!"=="00" (
  call %GWSRC%\stl\vec push %_s% STR_00000000
) else (
  set "_m2=!_sh:~2,2!" & set "_m1=!_sh:~4,2!" & set "_m0=!_sh:~6,2!"
  call %GWSRC%\num\_xbyte inc !_ee!
  call %GWSRC%\stl\vec push %_s% STR_!_m0!!_m1!!_m2!!__!
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
