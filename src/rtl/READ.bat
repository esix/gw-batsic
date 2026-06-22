@echo off
@REM READ: pop targets off the stack down to READ_MRK, reverse to user order,
@REM and for each take the next item from the data queue (file
@REM %GWTEMP%\data.dat, indexed by _data_ptr) and assign it.  A target is
@REM either a scalar VAR_ token or an array-element AREF:NAME:i1[:i2] token.
@REM
@REM Errors:
@REM   4   Out of DATA - queue exhausted
@REM   13  Type mismatch - numeric DATA item into string target or vice versa

setlocal EnableDelayedExpansion
set "_s=%~1"

set "_rev="
:_rd_pop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_rd_popDone
  if "!_v!"=="READ_MRK" goto :_rd_popDone
  if "!_rev!"=="" (set "_rev=!_v!") else (set "_rev=!_rev! !_v!")
  goto :_rd_pop
:_rd_popDone

set "_vars="
for %%v in (!_rev!) do (
  if "!_vars!"=="" (set "_vars=%%v") else (set "_vars=%%v !_vars!")
)

if not defined _data_ptr set "_data_ptr=0"
set "_df=%GWTEMP%\data.dat"
set "_e=0"

for %%v in (!_vars!) do (
  if "!_e!"=="0" call :_takeOne %%v
)

set "_final=!%_s%!"
endlocal ^
  & set "%~1=%_final%" ^
  & set "_data_ptr=%_data_ptr%" ^
  & exit /B %_e%


@REM _takeOne <target> - read the data item at _data_ptr, coerce to the
@REM target's type, assign to a scalar var or array element.  Bumps _data_ptr.
:_takeOne
  set "_var=%~1"
  set "_arr="
  if "!_var:~0,5!"=="AREF:" set "_arr=1"
  set "_arrname=" & set "_aidx="
  if defined _arr call :_parseAref "!_var!"
  @REM Target type.
  if defined _arr (
    call %GWSRC%\exec\_arrays typeof !_arrname! _tp
  ) else (
    call %GWSRC%\exec\_vars typeof !_var! _tp
  )
  @REM Fetch the next data item (line _data_ptr, 0-based).
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
  @REM Type check + numeric coercion to the target type.
  set "_vtp=!_item:~0,1!"
  if "!_item:~0,4!"=="STR_" set "_vtp=t"
  if "!_tp!"=="t" if not "!_vtp!"=="t" (set "_e=13" & exit /B 0)
  if not "!_tp!"=="t" if "!_vtp!"=="t" (set "_e=13" & exit /B 0)
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
  @REM Assign.
  if defined _arr (
    call %GWSRC%\exec\_arrays set !_arrname! !_aidx! !_item!
  ) else (
    call %GWSRC%\exec\_vars set !_var! !_item!
  )
  exit /B 0

@REM _parseAref "AREF:NAME:i1[:i2]" -> sets _arrname (ARR_...) and _aidx (space-sep).
:_parseAref
  set "_pa=%~1"
  set "_rest=!_pa:~5!"
  for /f "tokens=1* delims=:" %%a in ("!_rest!") do (set "_an=%%a" & set "_aidx=%%b")
  set "_aidx=!_aidx::= !"
  set "_arrname=!_an!"
  if "!_an:~0,4!"=="VAR_" set "_arrname=ARR_!_an:~4!"
  exit /B 0
