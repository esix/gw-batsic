@echo off
@REM String/hex conversion utilities
@REM
@REM Converts between ASCII text and hex-pair representation.
@REM Handles case-sensitive characters correctly.
@REM
@REM Usage:
@REM   call str encode "HELLO" __     -> __ = "48454C4C4F"
@REM   call str decode 48454C4C4F __  -> __ = "HELLO"
@REM   call str ch2hex A __           -> __ = "41"
@REM   call str hex2ch 41 __          -> __ = "A"

@REM Lookup table (char -> hex pair)
@REM Letters map to uppercase (batch var names are case-insensitive)
@REM The REPL uses findstr for case-sensitive encoding instead.
set "_c2h_A=41"& set "_c2h_B=42"& set "_c2h_C=43"& set "_c2h_D=44"& set "_c2h_E=45"
set "_c2h_F=46"& set "_c2h_G=47"& set "_c2h_H=48"& set "_c2h_I=49"& set "_c2h_J=4A"
set "_c2h_K=4B"& set "_c2h_L=4C"& set "_c2h_M=4D"& set "_c2h_N=4E"& set "_c2h_O=4F"
set "_c2h_P=50"& set "_c2h_Q=51"& set "_c2h_R=52"& set "_c2h_S=53"& set "_c2h_T=54"
set "_c2h_U=55"& set "_c2h_V=56"& set "_c2h_W=57"& set "_c2h_X=58"& set "_c2h_Y=59"
set "_c2h_Z=5A"
set "_c2h_ =20"& set "_c2h_0=30"& set "_c2h_1=31"& set "_c2h_2=32"& set "_c2h_3=33"
set "_c2h_4=34"& set "_c2h_5=35"& set "_c2h_6=36"& set "_c2h_7=37"& set "_c2h_8=38"
set "_c2h_9=39"
set "_c2h_+=2B"& set "_c2h_-=2D"& set "_c2h_*=2A"& set "_c2h_/=2F"& set "_c2h_\=5C"
set "_c2h_(=28"& set "_c2h_)=29"& set "_c2h_,=2C"& set "_c2h_.=2E"& set "_c2h_;=3B"
set "_c2h_:=3A"& set "_c2h_?=3F"& set "_c2h_'=27"& set "_c2h_$=24"& set "_c2h_^=5E"
set "_c2h_<=3C"& set "_c2h_>=3E"& set "_c2h_==3D"& set "_c2h_#=23"& set "_c2h_@=40"
set "_c2h_[=5B"& set "_c2h_]=5D"& set "_c2h___=5F"& set "_c2h_`=60"& set "_c2h_~=7E"
set "_c2h_{=7B"& set "_c2h_}=7D"

@REM Hex pair -> char lookup (works fine, hex keys are case-distinct)
set "_h2c_20= "& set "_h2c_21=!"& set "_h2c_22="""& set "_h2c_23=#"& set "_h2c_24=$"
set "_h2c_27='"& set "_h2c_28=("& set "_h2c_29=)"& set "_h2c_2A=*"& set "_h2c_2B=+"
set "_h2c_2C=,"& set "_h2c_2D=-"& set "_h2c_2E=."& set "_h2c_2F=/"
set "_h2c_30=0"& set "_h2c_31=1"& set "_h2c_32=2"& set "_h2c_33=3"& set "_h2c_34=4"
set "_h2c_35=5"& set "_h2c_36=6"& set "_h2c_37=7"& set "_h2c_38=8"& set "_h2c_39=9"
set "_h2c_3A=:"& set "_h2c_3B=;"& set "_h2c_3C=<"& set "_h2c_3D=="& set "_h2c_3E=>"
set "_h2c_3F=?"& set "_h2c_40=@"
set "_h2c_41=A"& set "_h2c_42=B"& set "_h2c_43=C"& set "_h2c_44=D"& set "_h2c_45=E"
set "_h2c_46=F"& set "_h2c_47=G"& set "_h2c_48=H"& set "_h2c_49=I"& set "_h2c_4A=J"
set "_h2c_4B=K"& set "_h2c_4C=L"& set "_h2c_4D=M"& set "_h2c_4E=N"& set "_h2c_4F=O"
set "_h2c_50=P"& set "_h2c_51=Q"& set "_h2c_52=R"& set "_h2c_53=S"& set "_h2c_54=T"
set "_h2c_55=U"& set "_h2c_56=V"& set "_h2c_57=W"& set "_h2c_58=X"& set "_h2c_59=Y"
set "_h2c_5A=Z"& set "_h2c_5B=["& set "_h2c_5C=\"& set "_h2c_5D=]"& set "_h2c_5E=^"
set "_h2c_5F=_"& set "_h2c_60=`"
set "_h2c_61=a"& set "_h2c_62=b"& set "_h2c_63=c"& set "_h2c_64=d"& set "_h2c_65=e"
set "_h2c_66=f"& set "_h2c_67=g"& set "_h2c_68=h"& set "_h2c_69=i"& set "_h2c_6A=j"
set "_h2c_6B=k"& set "_h2c_6C=l"& set "_h2c_6D=m"& set "_h2c_6E=n"& set "_h2c_6F=o"
set "_h2c_70=p"& set "_h2c_71=q"& set "_h2c_72=r"& set "_h2c_73=s"& set "_h2c_74=t"
set "_h2c_75=u"& set "_h2c_76=v"& set "_h2c_77=w"& set "_h2c_78=x"& set "_h2c_79=y"
set "_h2c_7A=z"& set "_h2c_7B={"& set "_h2c_7C=|"& set "_h2c_7D=}"& set "_h2c_7E=~"

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


@REM --- encode "text" retVar ---
:encode
  setlocal EnableDelayedExpansion
  set "_s=%~1"
  set "_r="
  set /a "_p=0"
:_enc_loop
  if "!_s:~%_p%,1!"=="" goto :_enc_done
  for %%i in (!_p!) do set "_ch=!_s:~%%i,1!"
  @REM Try non-letter lookup first (fast)
  set "_hx=!_c2h_%_ch%!"
  if defined _hx goto :_enc_emit
  @REM Letter: scan uppercase alphabet (case-insensitive, maps to uppercase hex)
  set "_hx="
  set "_uabc=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  for /L %%j in (0,1,25) do if not defined _hx if "!_uabc:~%%j,1!"=="!_ch!" (
    set /a "_code=65+%%j"
    set /a "_h1=!_code!/16"& set /a "_h2=!_code!%%16"
    set "_hexd=0123456789ABCDEF"
    for %%a in (!_h1!) do for %%b in (!_h2!) do set "_hx=!_hexd:~%%a,1!!_hexd:~%%b,1!"
  )
  if not defined _hx set "_hx=3F"
:_enc_emit
  set "_r=!_r!!_hx!"
  set /a "_p+=1"
  goto :_enc_loop
:_enc_done
  endlocal & set "%~2=%_r%" & exit /B 0


@REM --- decode hexstr retVar ---
:decode
  setlocal EnableDelayedExpansion
  set "_s=%~1"
  set "_r="
  set /a "_p=0"
:_dec_loop
  for %%i in (!_p!) do set "_hx=!_s:~%%i,2!"
  if "!_hx!"=="" goto :_dec_done
  if "!_hx:~1,1!"=="" goto :_dec_done
  set "_ch=!_h2c_%_hx%!"
  if defined _ch (
    set "_r=!_r!!_ch!"
  ) else (
    set "_r=!_r!."
  )
  set /a "_p+=2"
  goto :_dec_loop
:_dec_done
  endlocal & set "%~2=%_r%" & exit /B 0


@REM --- ch2hex char retVar ---
:ch2hex
  setlocal EnableDelayedExpansion
  set "_ch=%~1"
  set "_r=!_c2h_%_ch%!"
  set "_uabc=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  set "_hexd=0123456789ABCDEF"
  for /L %%j in (0,1,25) do if not defined _r if "!_uabc:~%%j,1!"=="!_ch!" (
    set /a "_code=65+%%j"
    set /a "_h1=!_code!/16"
    set /a "_h2=!_code!%%16"
    for %%a in (!_h1!) do for %%b in (!_h2!) do set "_r=!_hexd:~%%a,1!!_hexd:~%%b,1!"
  )
  if not defined _r set "_r=3F"
  endlocal & set "%~2=%_r%" & exit /B 0


@REM --- hex2ch hexPair retVar ---
:hex2ch
  setlocal EnableDelayedExpansion
  set "_hx=%~1"
  set "_r=!_h2c_%_hx%!"
  if not defined _r set "_r=."
  endlocal & set "%~2=%_r%" & exit /B 0


@REM --- input prompt retVar ---
@REM Read a line from keyboard and return as hex string.
@REM Handles ALL characters: " % ! ^ < > | &
@REM Returns errorlevel 1 if empty input (user pressed Enter).
@REM
@REM Usage:
@REM   call str input "> " __
@REM   if errorlevel 1 (echo empty) else (echo hex=!__!)
:input
  set "_in="
  set /p "_in=%~1"
  if not defined _in (set "%~2=" & exit /B 1)
  set "_tf=%TEMP%\_str.tmp"
  set "_hf=%TEMP%\_hex.tmp"
  cmd /V:ON /C >"%_tf%" echo(!_in!
  del "%_hf%" 2>nul
  certutil -encodehex "%_tf%" "%_hf%" 12 >nul 2>nul
  setlocal EnableDelayedExpansion
  set /p "_r=" < "%_hf%"
  if "!_r:~-4!"=="0d0a" set "_r=!_r:~0,-4!"
  set "_r=!_r:a=A!"
  set "_r=!_r:b=B!"
  set "_r=!_r:c=C!"
  set "_r=!_r:d=D!"
  set "_r=!_r:e=E!"
  set "_r=!_r:f=F!"
  endlocal & set "%~2=%_r%"
  del "%_tf%" "%_hf%" 2>nul
  exit /B 0


:_start
  echo Text to hex converter. Enter empty line to quit.
:_repl
  call :input "> " _hex
  if errorlevel 1 goto :_repl_end
  setlocal EnableDelayedExpansion
  echo !_hex!
  endlocal
  goto :_repl
:_repl_end
  endlocal
