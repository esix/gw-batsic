@echo off
@REM SWAP a, b : exchange the values of two variables (scalars or array
@REM elements).  Stack (bottom->top): ref1 ref2, each a VAR_ token or an
@REM AREF:NAME:idx array-element L-value.  Read both, then cross-assign.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _r2
call %GWSRC%\stl\vec pop %_s% _r1
call :_swread "!_r1!" _v1
call :_swread "!_r2!" _v2
call :_swwrite "!_r1!" "!_v2!"
call :_swwrite "!_r2!" "!_v1!"
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_swread
  set "_ref=%~1"
  if "!_ref:~0,5!"=="AREF:" (
    call :_paref "!_ref!"
    call %GWSRC%\exec\_arrays get !_arrnm! !_aidx! _rv
  ) else (
    call %GWSRC%\exec\_vars get !_ref! _rv
  )
  set "%~2=!_rv!"
  exit /B 0

:_swwrite
  set "_ref=%~1"
  set "_wv=%~2"
  if "!_ref:~0,5!"=="AREF:" (
    call :_paref "!_ref!"
    call %GWSRC%\exec\_arrays set !_arrnm! !_aidx! !_wv!
  ) else (
    call %GWSRC%\exec\_vars set !_ref! !_wv!
  )
  exit /B 0

:_paref
  set "_pa=%~1"
  set "_rest=!_pa:~5!"
  for /f "tokens=1* delims=:" %%a in ("!_rest!") do (set "_an=%%a" & set "_aidx=%%b")
  set "_aidx=!_aidx::= !"
  set "_arrnm=!_an!"
  if "!_an:~0,4!"=="VAR_" set "_arrnm=ARR_!_an:~4!"
  exit /B 0
