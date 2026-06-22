@echo off
@REM INPUT: pop vars off the stack until the INPUT_MRK sentinel, prompt for
@REM input, split a single typed line on commas, and assign one value to
@REM each var (in user-declaration order).
@REM
@REM Prompt: "? " is appended after the user prompt (or alone for bare
@REM INPUT).  Only the comma form INPUT "p", V suppresses it: PROMPT_NQ
@REM sets _input_prompted=2, the semicolon form's PROMPT sets 1.
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

@REM Read one input line — from a file channel (INPUT #n) or the console.
@REM _input_fh, when set (by @IFILE_SET), names the file handle to read from.
if defined _input_fh goto :_inp_fromfile
@REM Print "? " after the prompt (GW-BASIC appends it for the bare and
@REM semicolon forms; only the comma form INPUT "p", V suppresses it -
@REM PROMPT_NQ signals that with _input_prompted=2).
if not "!_input_prompted!"=="2" <nul set /p "=? "
set "_input_prompted="
set "_line="
set /p "_line="
set "_rest=!_line!"
goto :_inp_haveline
:_inp_fromfile
call %GWSRC%\exec\_files readseq !_input_fh! _lh _feof
set "_resthex="
set "_efeof="
if "!_feof!"=="1" (set "_efeof=1") else (set "_resthex=!_lh!")

:_inp_haveline
@REM Walk the vars; for each, take the next comma-separated piece and assign.
set "_e=0"
if defined _efeof set "_e=62"
set "_pending=!_vars!"
:_inp_vloop
  if "!_pending!"=="" goto :_inp_done
  if not "!_e!"=="0" goto :_inp_done
  for /f "tokens=1*" %%a in ("!_pending!") do (set "_var=%%a" & set "_pending=%%b")
  set "_fhex="
  if defined _input_fh goto :_inp_filefield
  call :_takeField "!_rest!" _piece _rest
  if not defined _piece (set "_e=13" & goto :_inp_done)
  goto :_inp_target
:_inp_filefield
  @REM File source: refill from the next line when the current one is spent,
  @REM then take a comma-delimited field at the HEX level (handles quoted
  @REM fields and commas inside quotes; see _takeFieldHex).
  if "!_resthex!"=="" (
    call %GWSRC%\exec\_files readseq !_input_fh! _resthex _feof2
    if "!_feof2!"=="1" (set "_e=62" & goto :_inp_done)
  )
  call :_takeFieldHex "!_resthex!" _fhex _resthex
  set "_piece="
  if defined _fhex call %GWSRC%\str\str decode !_fhex! _piece
:_inp_target
  @REM An array-element target arrives as AREF:NAME:i1[:i2] (see AREF.bat).
  set "_arr="
  if "!_var:~0,5!"=="AREF:" set "_arr=1"
  set "_arrname=" & set "_aidx="
  if defined _arr call :_parseAref "!_var!"
  if defined _arr (call %GWSRC%\exec\_arrays typeof !_arrname! _tp) else (call %GWSRC%\exec\_vars typeof !_var! _tp)
  if "!_tp!"=="t" goto :_inp_setStr
  goto :_inp_setNum

:_inp_setStr
  @REM File fields already carry case-correct hex; reuse it directly.
  if defined _input_fh (set "_ph=!_fhex!") else (call %GWSRC%\str\str encodeRaw "!_piece!" _ph)
  if defined _arr (call %GWSRC%\exec\_arrays set !_arrname! !_aidx! STR_!_ph!) else (call %GWSRC%\exec\_vars set !_var! STR_!_ph!)
  goto :_inp_vloop

:_inp_setNum
  if "!_tp!"=="i" call %GWSRC%\num\int fromDec !_piece!
  if "!_tp!"=="s" call %GWSRC%\num\sng fromDec !_piece!
  if "!_tp!"=="d" call %GWSRC%\num\dbl fromDec !_piece!
  if errorlevel 1 (set "_e=13" & goto :_inp_done)
  if defined _arr (call %GWSRC%\exec\_arrays set !_arrname! !_aidx! !__!) else (call %GWSRC%\exec\_vars set !_var! !__!)
  goto :_inp_vloop

:_inp_done
set "_final=!%_s%!"
endlocal ^
  & set "%~1=%_final%" ^
  & set "_print_col=0" ^
  & set "_input_prompted=" ^
  & set "_input_fh=" ^
  & exit /B %_e%


@REM _takeFieldHex LINEHEX fieldHexVar restHexVar — extract one comma-delimited
@REM field from a line's hex (20=space, 2C=comma, 22=quote).  A leading-quoted
@REM field is read to its closing quote with quotes stripped (commas inside are
@REM literal); otherwise read to the next comma and right-trim spaces.
:_takeFieldHex
  setlocal EnableDelayedExpansion
  set "_h=%~1"
:_tfh_lskip
  if "!_h:~0,2!"=="20" (set "_h=!_h:~2!" & goto :_tfh_lskip)
  if "!_h:~0,2!"=="22" goto :_tfh_quoted
  set "_f="
:_tfh_uloop
  if "!_h!"=="" goto :_tfh_udone
  set "_b=!_h:~0,2!"
  if "!_b!"=="2C" (set "_h=!_h:~2!" & goto :_tfh_udone)
  set "_f=!_f!!_b!"
  set "_h=!_h:~2!"
  goto :_tfh_uloop
:_tfh_udone
  if "!_f:~-2!"=="20" (set "_f=!_f:~0,-2!" & goto :_tfh_udone)
  endlocal & set "%~2=%_f%" & set "%~3=%_h%" & exit /B 0
:_tfh_quoted
  set "_h=!_h:~2!"
  set "_f="
:_tfh_qloop
  if "!_h!"=="" (endlocal & set "%~2=%_f%" & set "%~3=" & exit /B 0)
  set "_b=!_h:~0,2!"
  set "_h=!_h:~2!"
  if "!_b!"=="22" goto :_tfh_qskip
  set "_f=!_f!!_b!"
  goto :_tfh_qloop
:_tfh_qskip
  if "!_h!"=="" goto :_tfh_qdone
  set "_b=!_h:~0,2!"
  set "_h=!_h:~2!"
  if not "!_b!"=="2C" goto :_tfh_qskip
:_tfh_qdone
  endlocal & set "%~2=%_f%" & set "%~3=%_h%" & exit /B 0

@REM _parseAref "AREF:NAME:i1[:i2]" -> sets _arrname (ARR_...) and _aidx (space-sep).
:_parseAref
  set "_pa=%~1"
  set "_rest2=!_pa:~5!"
  for /f "tokens=1* delims=:" %%a in ("!_rest2!") do (set "_an=%%a" & set "_aidx=%%b")
  set "_aidx=!_aidx::= !"
  set "_arrname=!_an!"
  if "!_an:~0,4!"=="VAR_" set "_arrname=ARR_!_an:~4!"
  exit /B 0

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
