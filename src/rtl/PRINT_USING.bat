@echo off
@REM PRINT_USING: render values against a GW-BASIC PRINT USING format string.
@REM Stack: <fmt> PU_MARK <v1> <v2> ... -> formatted text (no newline).
@REM Numeric fields (# . , with $$ float-dollar and ** asterisk fill), string
@REM fields (\ \, !, &), literal text and _ escape.  The format is reused
@REM (restarted) while values remain.  Exponential (^^^^) and trailing-sign
@REM forms are not implemented.  Works in hex pairs (literal bytes pass
@REM through untouched); the assembled output hex is emitted via certutil.
@REM Format walking consumes pairs off the FRONT of _fhex so every substring
@REM uses a constant offset (delayed expansion is correct inside if-blocks;
@REM percent %var% offsets would expand at parse time and break).
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_rev="
:_pop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_popdone
  if "!_v!"=="PU_MARK" goto :_popdone
  @REM Resolve each value: a bare variable reaches here as its VAR_ token, which
  @REM _renderNum/_strBody would otherwise treat as 0 (or empty).  Literals and
  @REM pre-evaluated expressions pass through _resolve unchanged.
  call %GWSRC%\exec\_resolve !_v! _v
  set "_rev=!_rev! !_v!"
  goto :_pop
:_popdone
set "_vals="
for %%a in (!_rev!) do set "_vals=%%a !_vals!"
call %GWSRC%\stl\vec pop %_s% _fmt
call %GWSRC%\exec\_resolve !_fmt! _fmt
set "_forig="
if "!_fmt:~0,4!"=="STR_" set "_forig=!_fmt:~4!"

set "_out="
:_restart
  set "_consumed=0"
  set "_fhex=!_forig!"
:_walk
  if "!_fhex!"=="" goto :_passEnd
  set "_pair=!_fhex:~0,2!"
  if "!_pair!"=="23" goto :_numField
  if "!_fhex:~0,4!"=="2424" goto :_numField
  if "!_fhex:~0,4!"=="2A2A" goto :_numField
  if "!_pair!"=="5C" goto :_strBackslash
  if "!_pair!"=="21" goto :_strBang
  if "!_pair!"=="26" goto :_strAmp
  if "!_pair!"=="5F" (
    set "_fhex=!_fhex:~2!"
    set "_lit=!_fhex:~0,2!"
    set "_fhex=!_fhex:~2!"
    set "_out=!_out!!_lit!"
    goto :_walk
  )
  set "_out=!_out!!_pair!"
  set "_fhex=!_fhex:~2!"
  goto :_walk
:_passEnd
  if defined _vals if not "!_consumed!"=="0" goto :_restart
  goto :_emit

@REM ---- numeric field ----
:_numField
  if not defined _vals goto :_emit
  set "_dollar=" & set "_star=" & set "_ihash=0" & set "_dhash=0"
  set "_point=" & set "_comma=" & set "_w=0"
:_nf_pre
  set "_c=!_fhex:~0,2!"
  if "!_c!"=="24" (set "_dollar=1" & set /a "_w+=1" & set "_fhex=!_fhex:~2!" & goto :_nf_pre)
  if "!_c!"=="2A" (set "_star=1" & set /a "_w+=1" & set "_fhex=!_fhex:~2!" & goto :_nf_pre)
:_nf_body
  set "_c=!_fhex:~0,2!"
  if "!_c!"=="23" (
    if defined _point (set /a "_dhash+=1") else (set /a "_ihash+=1")
    set /a "_w+=1" & set "_fhex=!_fhex:~2!" & goto :_nf_body
  )
  if "!_c!"=="2C" (set "_comma=1" & set /a "_w+=1" & set "_fhex=!_fhex:~2!" & goto :_nf_body)
  if "!_c!"=="2E" (
    if not defined _point (set "_point=1" & set /a "_w+=1" & set "_fhex=!_fhex:~2!" & goto :_nf_body)
  )
  call :_shiftVal
  call :_renderNum "!_curval!"
  set "_out=!_out!!_rh!"
  set "_consumed=1"
  goto :_walk

@REM _renderNum tagged -> _rh (hex of the rendered, width-justified number)
:_renderNum
  call :_toDecStr "%~1"
  @REM Split _ds into integer/fraction WITHOUT for/f (which would skip an
  @REM empty leading token for values <1 like ".09999999").
  set "_ip=" & set "_fp=" & set "_seen=" & set "_tmp=!_ds!"
:_rn_split
  if "!_tmp!"=="" goto :_rn_splitdone
  set "_ch=!_tmp:~0,1!" & set "_tmp=!_tmp:~1!"
  if "!_ch!"=="." (set "_seen=1" & goto :_rn_split)
  if defined _seen (set "_fp=!_fp!!_ch!") else (set "_ip=!_ip!!_ch!")
  goto :_rn_split
:_rn_splitdone
  if "!_ip!"=="" set "_ip=0"
  call :_round
  set "_ig=!_ip!"
  if defined _comma call :_commas "!_ip!" _ig
  set "_body=!_ig!"
  if defined _point set "_body=!_body!.!_fp!"
  if defined _dollar set "_body=$!_body!"
  if "!_sign!"=="-" set "_body=-!_body!"
  call :_len "!_body!" _bl
  if !_bl! GTR !_w! (
    call :_t2h "%%!_body!" _rh
    exit /B 0
  )
  set /a "_padn=_w-_bl"
  set "_fill= "
  if defined _star set "_fill=*"
  set "_pad="
  set /a "_i=0"
:_rn_pad
  if !_i! GEQ !_padn! goto :_rn_paddone
  set "_pad=!_pad!!_fill!"
  set /a "_i+=1"
  goto :_rn_pad
:_rn_paddone
  call :_t2h "!_pad!!_body!" _rh
  exit /B 0

@REM _round: round _fp to _dhash digits, carry into _ip.
:_round
  if "!_dhash!"=="0" (
    set "_roundup="
    if defined _fp (
      set "_fd=!_fp:~0,1!"
      if not "!_fd!"=="" if !_fd! GEQ 5 set "_roundup=1"
    )
    set "_fp="
    if defined _roundup call :_incDec "!_ip!" _ip
    exit /B 0
  )
  call :_len "!_fp!" _fl
  if !_fl! LEQ !_dhash! (
    set "_i=!_fl!"
    goto :_rd_pad
  )
  for %%n in (!_dhash!) do set "_kept=!_fp:~0,%%n!"
  for %%n in (!_dhash!) do set "_rd=!_fp:~%%n,1!"
  if !_rd! GEQ 5 (
    set "_comb=!_ip!!_kept!"
    call :_incDec "!_comb!" _comb
    call :_len "!_comb!" _cl
    set /a "_ipl=_cl-_dhash"
    for %%n in (!_ipl!) do set "_ip=!_comb:~0,%%n!"
    for %%n in (!_ipl!) do set "_fp=!_comb:~%%n!"
  ) else (
    set "_fp=!_kept!"
  )
  exit /B 0
:_rd_pad
  if !_i! GEQ !_dhash! exit /B 0
  set "_fp=!_fp!0"
  set /a "_i+=1"
  goto :_rd_pad

@REM _incDec STR -> retVar : increment a decimal digit string by 1 (carry).
:_incDec
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  set "_r=" & set "_carry=1"
:_inc_loop
  if "!_n!"=="" goto :_inc_done
  set "_d=!_n:~-1!"
  set "_n=!_n:~0,-1!"
  set /a "_sum=_d+_carry"
  if !_sum! GEQ 10 (set /a "_sum-=10" & set "_carry=1") else (set "_carry=0")
  set "_r=!_sum!!_r!"
  goto :_inc_loop
:_inc_done
  if "!_carry!"=="1" set "_r=1!_r!"
  endlocal & set "%~2=%_r%" & exit /B 0

@REM _commas STR -> retVar : group integer digits with commas.
:_commas
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  set "_r=" & set "_k=0"
:_cm_loop
  if "!_n!"=="" goto :_cm_done
  set "_d=!_n:~-1!"
  set "_n=!_n:~0,-1!"
  set /a "_k+=1"
  if !_k! GTR 3 (set "_r=,!_r!" & set "_k=1")
  set "_r=!_d!!_r!"
  goto :_cm_loop
:_cm_done
  endlocal & set "%~2=%_r%" & exit /B 0

@REM ---- string fields ----
:_strBackslash
  if not defined _vals goto :_emit
  set "_fhex=!_fhex:~2!"
  set "_inner=0"
:_sb_scan
  set "_c=!_fhex:~0,2!"
  if "!_c!"=="" goto :_sb_w
  set "_fhex=!_fhex:~2!"
  if "!_c!"=="5C" goto :_sb_w
  set /a "_inner+=1"
  goto :_sb_scan
:_sb_w
  set /a "_w=_inner+2"
  call :_shiftVal
  call :_strBody "!_curval!" _sh
  call :_strFit "!_sh!" !_w! _fit
  set "_out=!_out!!_fit!"
  set "_consumed=1"
  goto :_walk

:_strBang
  if not defined _vals goto :_emit
  set "_fhex=!_fhex:~2!"
  call :_shiftVal
  call :_strBody "!_curval!" _sh
  set "_out=!_out!!_sh:~0,2!"
  set "_consumed=1"
  goto :_walk

:_strAmp
  if not defined _vals goto :_emit
  set "_fhex=!_fhex:~2!"
  call :_shiftVal
  call :_strBody "!_curval!" _sh
  set "_out=!_out!!_sh!"
  set "_consumed=1"
  goto :_walk

@REM _strBody tagged -> retVar : hex body of a STR_ value ("" if not a string)
:_strBody
  set "_sv=%~1"
  if "!_sv:~0,4!"=="STR_" (set "%~2=!_sv:~4!") else (set "%~2=")
  exit /B 0

@REM _strFit hex width -> retVar : left-justify hex to width pairs, pad 20.
:_strFit
  setlocal EnableDelayedExpansion
  set "_h=%~1" & set "_wd=%~2"
  set "_r=" & set "_i=0"
:_sf_loop
  if !_i! GEQ !_wd! goto :_sf_done
  set "_pp=!_h:~0,2!"
  if "!_pp!"=="" (set "_r=!_r!20") else (set "_r=!_r!!_pp!" & set "_h=!_h:~2!")
  set /a "_i+=1"
  goto :_sf_loop
:_sf_done
  endlocal & set "%~3=%_r%" & exit /B 0

@REM ---- helpers ----
:_shiftVal
  for /f "tokens=1*" %%a in ("!_vals!") do (set "_curval=%%a" & set "_vals=%%b")
  exit /B 0

@REM _toDecStr tagged -> sets _sign (- or empty) and _ds (digits with .)
:_toDecStr
  set "_v=%~1"
  set "_t=!_v:~0,1!"
  set "__="
  if "!_t!"=="i" call %GWSRC%\num\int toDec !_v!
  if "!_t!"=="s" call %GWSRC%\num\sng toDec !_v!
  if "!_t!"=="d" call %GWSRC%\num\dbl toDec !_v!
  set "_d=!__!"
:_tds_lstrip
  if "!_d:~0,1!"==" " (set "_d=!_d:~1!" & goto :_tds_lstrip)
  set "_sign="
  if "!_d:~0,1!"=="-" (set "_sign=-" & set "_d=!_d:~1!")
  set "_ds=!_d!"
  exit /B 0

:_len
  setlocal EnableDelayedExpansion
  set "_x=%~1" & set /a "_n=0"
:_len_l
  if "!_x!"=="" (endlocal & set "%~2=%_n%" & exit /B 0)
  set "_x=!_x:~1!" & set /a "_n+=1"
  goto :_len_l

@REM _t2h TEXT -> retVar : hex of a string over [0-9 .,$*%+-]
:_t2h
  setlocal EnableDelayedExpansion
  set "_x=%~1" & set "_h="
:_t2h_l
  if "!_x!"=="" (endlocal & set "%~2=%_h%" & exit /B 0)
  set "_c=!_x:~0,1!" & set "_x=!_x:~1!"
  set "_hp="
  if "!_c!"==" " set "_hp=20"
  if "!_c!"=="." set "_hp=2E"
  if "!_c!"=="," set "_hp=2C"
  if "!_c!"=="$" set "_hp=24"
  if "!_c!"=="*" set "_hp=2A"
  if "!_c!"=="%%" set "_hp=25"
  if "!_c!"=="+" set "_hp=2B"
  if "!_c!"=="-" set "_hp=2D"
  if not defined _hp for %%d in (0 1 2 3 4 5 6 7 8 9) do if "!_c!"=="%%d" set "_hp=3%%d"
  set "_h=!_h!!_hp!"
  goto :_t2h_l

:_emit
  if defined _out call %GWSRC%\str\str decodePrint !_out! NONL
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 0
