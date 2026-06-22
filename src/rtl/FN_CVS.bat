@echo off
@REM CVS(s$): unpack the first 4 bytes as an MBF single (disk bias 129 -> 128).
setlocal EnableDelayedExpansion
@REM _xbyte calls _xhalf via PATH; add the num dir so the bias inc/dec resolve.
set "PATH=%GWSRC%\num;%PATH%"
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
set "_h="
if "!_a:~0,4!"=="STR_" if not "!_a!"=="STR_" set "_h=!_a:~4!"
set "_m0=!_h:~0,2!" & set "_m1=!_h:~2,2!" & set "_m2=!_h:~4,2!" & set "_ee=!_h:~6,2!"
if "!_ee!"=="00" (
  call %GWSRC%\stl\vec push %_s% s00000000
) else (
  call %GWSRC%\num\_xbyte dec !_ee!
  call %GWSRC%\stl\vec push %_s% s!__!!_m2!!_m1!!_m0!
)
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
