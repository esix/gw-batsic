@echo off
@REM ON_END: finish an ON n GOTO/GOSUB.  Pop the line-number list back to the
@REM ON_MARK sentinel, pick the n-th entry (1-based; n=0 or n>count falls
@REM through with no jump, per GW-BASIC), then GOTO or GOSUB it.
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_rev="
:_pop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_popdone
  if "!_v!"=="ON_MARK" goto :_popdone
  set "_rev=!_rev! !_v!"
  goto :_pop
:_popdone
@REM _rev is reversed (lineN..line1); flip to positional order and pick n-th.
set "_list="
for %%a in (!_rev!) do set "_list=%%a !_list!"
set "_target="
set "_i=0"
for %%a in (!_list!) do (
  set /a "_i+=1"
  if "!_i!"=="!_on_idx!" set "_target=%%a"
)
@REM Convert the chosen line-number token to a decimal line number.
set "_nl="
if defined _target (
  set "_tp=!_target:~0,1!"
  if "!_tp!"=="i" (call %GWSRC%\num\int toDec !_target! & set "_nl=!__!")
  if "!_tp!"=="s" (call %GWSRC%\num\sng toDec !_target! & set "_nl=!__!")
  if "!_tp!"=="d" (call %GWSRC%\num\dbl toDec !_target! & set "_nl=!__!")
)
@REM GOSUB mode: push the natural-next line as the return address.
set "_gs=!_gosub_stack!"
set "_dopush="
if defined _nl if "!_on_mode!"=="GOSUB" set "_dopush=1"
if defined _dopush call %GWSRC%\stl\vec push _gs !_next_line!
@REM Decide the next line: jump target if in range, else unchanged (fall through).
set "_newnext=!_next_line!"
if defined _nl set "_newnext=!_nl!"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_next_line=%_newnext%" & set "_gosub_stack=%_gs%" & set "_on_idx=" & set "_on_mode=" & exit /B 0
