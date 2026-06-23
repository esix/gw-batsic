@echo off
@REM FN call: bind args to the stored params, evaluate the body, return the
@REM result.  Stack: name ARG_MRK a1 a2 ...  ->  result.  Params are real
@REM variables temporarily overwritten and restored (GW dummy-variable model).
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_args="
:_apop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_adone
  if "!_v!"=="ARG_MRK" goto :_adone
  call %GWSRC%\exec\_resolve !_v! _rv
  set "_args=!_rv! !_args!"
  goto :_apop
:_adone
call %GWSRC%\stl\vec pop %_s% _name
set "_def="
if exist "%GWTEMP%\deffns.dat" for /f "usebackq tokens=1*" %%a in ("%GWTEMP%\deffns.dat") do (
  if /I "%%a"=="!_name!" set "_def=%%b"
)
if not defined _def (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 5
)
for /f "tokens=1*" %%a in ("!_def!") do (set "_np=%%a" & set "_rest=%%b")
set "_plist="
set "_i=0"
:_psplit
  if !_i! GEQ !_np! goto :_pdone
  for /f "tokens=1*" %%p in ("!_rest!") do (set "_plist=!_plist! %%p" & set "_rest=%%q")
  set /a "_i+=1"
  goto :_psplit
:_pdone
set "_argq=!_args!"
set "_savedq="
for %%p in (!_plist!) do (
  call %GWSRC%\exec\_vars get %%p _sv
  if not defined _sv set "_sv=STR_"
  set "_savedq=!_savedq! !_sv!"
  for /f "tokens=1*" %%x in ("!_argq!") do (call %GWSRC%\exec\_vars set %%p %%x & set "_argq=%%y")
)
call %GWSRC%\exec\exec evalExpr "!_rest!" _result
set "_ce=!ERRORLEVEL!"
set "_savedr=!_savedq!"
for %%p in (!_plist!) do (
  for /f "tokens=1*" %%x in ("!_savedr!") do (call %GWSRC%\exec\_vars set %%p %%x & set "_savedr=%%y")
)
if not defined _result set "_result=i0000"
call %GWSRC%\stl\vec push %_s% !_result!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B %_ce%
