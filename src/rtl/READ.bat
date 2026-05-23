@echo off
@REM READ: pop vars off the stack down to READ_MRK, reverse to user order,
@REM and for each var take the next item from the data queue (file
@REM %GWTEMP%\data.dat, indexed by _data_ptr) and assign it.
@REM
@REM Errors:
@REM   4   Out of DATA — queue exhausted
@REM   13  Type mismatch — numeric DATA item assigned to string var or vice versa

setlocal EnableDelayedExpansion
set "_s=%~1"

@REM Collect vars in reverse pop order.
set "_rev="
:_rd_pop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_rd_popDone
  if "!_v!"=="READ_MRK" goto :_rd_popDone
  if "!_rev!"=="" (set "_rev=!_v!") else (set "_rev=!_rev! !_v!")
  goto :_rd_pop
:_rd_popDone

@REM Reverse to user order.
set "_vars="
for %%v in (!_rev!) do (
  if "!_vars!"=="" (set "_vars=%%v") else (set "_vars=%%v !_vars!")
)

if not defined _data_ptr set "_data_ptr=0"
set "_df=%GWTEMP%\data.dat"
set "_e=0"

@REM Walk vars and pull successive items from the data queue.
for %%v in (!_vars!) do (
  if "!_e!"=="0" call :_takeOne %%v
)

set "_final=!%_s%!"
endlocal ^
  & set "%~1=%_final%" ^
  & set "_data_ptr=%_data_ptr%" ^
  & exit /B %_e%


@REM _takeOne <varname> — read the data item at index _data_ptr from data.dat,
@REM convert to var's type, assign.  Increments _data_ptr.  Sets _e=4 if EOF.
:_takeOne
  set "_var=%~1"
  @REM Find the line at index _data_ptr (0-based) in _df.
  set "_idx=0"
  set "_item="
  set "_srcL="
  for /f "usebackq tokens=1,* delims= " %%a in ("!_df!") do (
    if "!_idx!"=="!_data_ptr!" (
      if not defined _item (set "_srcL=%%a" & set "_item=%%b")
    )
    set /a "_idx+=1"
  )
  if not defined _item (set "_e=4" & exit /B 0)
  set /a "_data_ptr+=1"
  @REM Assign — coerce type to the var's type via _vars set's existing logic.
  @REM But _vars set doesn't type-coerce; ASSIGN does.  Do it inline.
  call %GWSRC%\exec\_vars typeof !_var! _tp
  set "_vtp=!_item:~0,1!"
  if "!_item:~0,4!"=="STR_" set "_vtp=t"
  if "!_tp!"=="t" if not "!_vtp!"=="t" (set "_e=13" & exit /B 0)
  if not "!_tp!"=="t" if "!_vtp!"=="t" (set "_e=13" & exit /B 0)
  @REM Numeric coercion.
  if "!_tp!"=="i" if not "!_vtp!"=="i" (
    if "!_vtp!"=="s" (call %GWSRC%\num\sng toInt !_item! & set "_item=!__!")
    if "!_vtp!"=="d" (call %GWSRC%\num\dbl toInt !_item! & set "_item=!__!")
  )
  if "!_tp!"=="s" if not "!_vtp!"=="s" (
    if "!_vtp!"=="i" (call %GWSRC%\num\sng fromInt !_item! & set "_item=!__!")
    if "!_vtp!"=="d" (call %GWSRC%\num\dbl toDec !_item! & call %GWSRC%\num\sng fromDec !__! & set "_item=!__!")
  )
  if "!_tp!"=="d" if not "!_vtp!"=="d" (
    if "!_vtp!"=="i" (call %GWSRC%\num\dbl fromInt !_item! & set "_item=!__!")
    if "!_vtp!"=="s" (call %GWSRC%\num\sng toDec !_item! & call %GWSRC%\num\dbl fromDec !__! & set "_item=!__!")
  )
  call %GWSRC%\exec\_vars set !_var! !_item!
  exit /B 0
