@echo off
@REM CLEAR [size[,stack]] : reset all variables and arrays to their empty/zero
@REM state and close all open files, WITHOUT erasing the program or halting.
@REM The numeric size/stack arguments are accepted and discarded (we don't
@REM model a fixed BASIC data segment).  DEFINT/DEFSNG/DEFDBL/DEFSTR
@REM declarations are kept (they are program directives, not variable values).
setlocal EnableDelayedExpansion
set "_s=%~1"
:_clr_pop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_clr_done
  if "!_v!"=="CLEAR_MRK" goto :_clr_done
  goto :_clr_pop
:_clr_done
set "_savedt=!_deftypes!"
call %GWSRC%\exec\_vars init
call %GWSRC%\exec\_arrays init
call %GWSRC%\exec\_files init
set "_deftypes=!_savedt!"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_deftypes=%_deftypes%" & exit /B 0
