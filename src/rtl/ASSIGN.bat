@echo off
@REM ASSIGN: pop value and variable ref, convert to variable's type, store
@REM Stack: ... varname value → ...
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _val
call %GWSRC%\stl\vec pop %_s% _var
@REM Resolve value if it's a variable reference
call %GWSRC%\exec\_resolve !_val! _val
@REM Determine target variable type
call %GWSRC%\exec\_vars typeof !_var! _tp
@REM Convert value to target type if needed
set "_vtp=!_val:~0,1!"
if "!_tp!"=="i" if "!_vtp!" neq "i" (
  @REM Convert to integer: sng/dbl → toInt
  if "!_vtp!"=="s" (
    call %GWSRC%\num\sng toInt !_val!
    set "_val=!__!"
  ) else if "!_vtp!"=="d" (
    call %GWSRC%\num\dbl toInt !_val!
    set "_val=!__!"
  )
)
if "!_tp!"=="s" if "!_vtp!" neq "s" (
  @REM Convert to single: int → fromInt
  if "!_vtp!"=="i" (
    call %GWSRC%\num\sng fromInt !_val!
    set "_val=!__!"
  )
)
if "!_tp!"=="d" if "!_vtp!" neq "d" (
  @REM Convert to double: int → fromInt
  if "!_vtp!"=="i" (
    call %GWSRC%\num\dbl fromInt !_val!
    set "_val=!__!"
  )
)
call %GWSRC%\exec\_vars set !_var! !_val!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
