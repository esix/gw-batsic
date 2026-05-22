@echo off
@REM INPUT: pop vars off the stack until the INPUT_MRK sentinel, prompt for
@REM input, split a single typed line on commas, and assign one value to
@REM each var (in user-declaration order).
@REM
@REM Prompt: a leading "? " is appended only if the user did NOT supply a
@REM "..."; prompt (PROMPT sets _input_prompted=1).  GW-BASIC's exact rule
@REM (comma vs semicolon after prompt) isn't reproduced.
@REM
@REM Errors:
@REM   13  Type mismatch — non-numeric input piece for a numeric var
@REM   13  Type mismatch — fewer pieces than vars

setlocal EnableDelayedExpansion
set "_s=%~1"

@REM Collect vars in reverse pop order, then reverse → user order.
set "_rev="
:_inp_pop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_inp_popDone
  if "!_v!"=="INPUT_MRK" goto :_inp_popDone
  if "!_rev!"=="" (set "_rev=!_v!") else (set "_rev=!_rev! !_v!")
  goto :_inp_pop
:_inp_popDone

set "_vars="
for %%v in (!_rev!) do (
  if "!_vars!"=="" (set "_vars=%%v") else (set "_vars=%%v !_vars!")
)

@REM Print "? " unless the user's prompt already covered it.
if not defined _input_prompted <nul set /p "=? "
set "_input_prompted="

@REM Read one input line.
set "_line="
set /p "_line="

@REM Walk the vars; for each, take the next comma-separated piece and assign.
set "_rest=!_line!"
set "_e=0"
set "_pending=!_vars!"
:_inp_vloop
  if "!_pending!"=="" goto :_inp_done
  if not "!_e!"=="0" goto :_inp_done
  for /f "tokens=1*" %%a in ("!_pending!") do (set "_var=%%a" & set "_pending=%%b")
  call :_takeField "!_rest!" _piece _rest
  if not defined _piece (set "_e=13" & goto :_inp_done)
  call %GWSRC%\exec\_vars typeof !_var! _tp
  if "!_tp!"=="t" goto :_inp_setStr
  goto :_inp_setNum

:_inp_setStr
  call %GWSRC%\str\str encodeRaw "!_piece!" _ph
  call %GWSRC%\exec\_vars set !_var! STR_!_ph!
  goto :_inp_vloop

:_inp_setNum
  if "!_tp!"=="i" call %GWSRC%\num\int fromDec !_piece!
  if "!_tp!"=="s" call %GWSRC%\num\sng fromDec !_piece!
  if "!_tp!"=="d" call %GWSRC%\num\dbl fromDec !_piece!
  if errorlevel 1 (set "_e=13" & goto :_inp_done)
  call %GWSRC%\exec\_vars set !_var! !__!
  goto :_inp_vloop

:_inp_done
set "_final=!%_s%!"
endlocal ^
  & set "%~1=%_final%" ^
  & set "_print_col=0" ^
  & set "_input_prompted=" ^
  & exit /B %_e%


@REM _takeField "STR" pieceVar restVar
@REM Split STR at the first comma; trim surrounding spaces from the field.
:_takeField
  setlocal EnableDelayedExpansion
  set "_in=%~1"
  if "!_in!"=="" (endlocal & set "%~2=" & set "%~3=" & exit /B 0)
  set "_p="
  set "_r=!_in!"
:_tf_loop
  if "!_r!"=="" goto :_tf_done
  set "_c=!_r:~0,1!"
  set "_r=!_r:~1!"
  if "!_c!"=="," goto :_tf_done
  set "_p=!_p!!_c!"
  goto :_tf_loop
:_tf_done
:_tf_lstrip
  if defined _p if "!_p:~0,1!"==" " (set "_p=!_p:~1!" & goto :_tf_lstrip)
:_tf_rstrip
  if defined _p if "!_p:~-1!"==" " (set "_p=!_p:~0,-1!" & goto :_tf_rstrip)
  if not defined _p (endlocal & set "%~2=" & set "%~3=%_r%" & exit /B 0)
  endlocal & set "%~2=%_p%" & set "%~3=%_r%" & exit /B 0
