@echo off
@REM MKD$(n): pack a number as an 8-byte MBF disk double (mantissa LE, exp last, bias 129).
setlocal EnableDelayedExpansion
@REM _xbyte calls _xhalf via PATH; add the num dir so the bias inc/dec resolve.
set "PATH=%GWSRC%\num;%PATH%"
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_t=!_a:~0,1!"
set "_dh="
if "!_t!"=="d" set "_dh=!_a:~1!"
if "!_t!"=="i" (call %GWSRC%\num\int toDec !_a! & call %GWSRC%\num\dbl fromDec !__! & set "_dh=!__:~1!")
if "!_t!"=="s" (call %GWSRC%\num\sng toDec !_a! & call %GWSRC%\num\dbl fromDec !__! & set "_dh=!__:~1!")
set "_ee=!_dh:~0,2!"
if "!_ee!"=="00" (
  call %GWSRC%\stl\vec push %_s% STR_0000000000000000
) else (
  set "_mm=!_dh:~2!"
  set "_le=!_mm:~12,2!!_mm:~10,2!!_mm:~8,2!!_mm:~6,2!!_mm:~4,2!!_mm:~2,2!!_mm:~0,2!"
  call %GWSRC%\num\_xbyte inc !_ee!
  call %GWSRC%\stl\vec push %_s% STR_!_le!!__!
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
