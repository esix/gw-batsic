@echo off
@REM CVD(s$): unpack the first 8 bytes as an MBF double (disk bias 129 -> 128).
setlocal EnableDelayedExpansion
@REM _xbyte calls _xhalf via PATH; add the num dir so the bias inc/dec resolve.
set "PATH=%GWSRC%\num;%PATH%"
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_h="
if "!_a:~0,4!"=="STR_" if not "!_a!"=="STR_" set "_h=!_a:~4!"
set "_ee=!_h:~14,2!"
if "!_ee!"=="00" (
  call %GWSRC%\stl\vec push %_s% d0000000000000000
) else (
  set "_be=!_h:~12,2!!_h:~10,2!!_h:~8,2!!_h:~6,2!!_h:~4,2!!_h:~2,2!!_h:~0,2!"
  call %GWSRC%\num\_xbyte dec !_ee!
  call %GWSRC%\stl\vec push %_s% d!__!!_be!
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
