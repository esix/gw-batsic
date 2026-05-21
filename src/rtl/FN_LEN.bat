@echo off
@REM FN_LEN: length of a string in characters.  Stack: STR_<hex> → NUM_i<len>.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
if not "!_a:~0,4!"=="STR_" (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
set "_h=!_a:~4!"
@REM Each char is 2 hex digits; length is half the hex string's length.
set /a "_n=0"
:_len_loop
  if "!_h!"=="" goto :_len_done
  set /a "_n+=1"
  set "_h=!_h:~2!"
  goto :_len_loop
:_len_done
@REM Encode N as tagged 16-bit int.
call %GWSRC%\num\int fromDec !_n!
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
