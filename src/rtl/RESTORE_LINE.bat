@echo off
@REM RESTORE_LINE: pop a line number, set _data_ptr to the first DATA item
@REM whose source line is >= that number.  If no such item, leave the pointer
@REM past the end (next READ will get Out of DATA).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _t
call %GWSRC%\exec\_resolve !_t! _t
set "_tp=!_t:~0,1!"
if "!_tp!"=="i" call %GWSRC%\num\int toDec !_t!
if "!_tp!"=="s" call %GWSRC%\num\sng toDec !_t!
if "!_tp!"=="d" call %GWSRC%\num\dbl toDec !_t!
set "_target=!__!"

set "_df=%GWTEMP%\data.dat"
set "_idx=0"
set "_found="
for /f "usebackq tokens=1,* delims= " %%a in ("!_df!") do (
  if not defined _found if %%a GEQ !_target! set "_found=!_idx!"
  set /a "_idx+=1"
)
if not defined _found set "_found=!_idx!"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_data_ptr=%_found%" & exit /B 0
