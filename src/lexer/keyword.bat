@echo off
@REM GW-BASIC keyword token table
@REM Bidirectional mapping: keyword name <-> binary token code (hex)
@REM
@REM MUST call "keyword init" once before using other functions.
@REM This loads the lookup tables into env vars.
@REM
@REM Usage:
@REM   call keyword init                         (load tables - once at startup)
@REM   call keyword isKeyword PRINT              -> errorlevel 0 if keyword
@REM   call keyword toCode PRINT __              -> __ = "91"
@REM   call keyword fromCode 91 __               -> __ = "PRINT"
@REM   call keyword isKeywordStr LEFT$            -> errorlevel 0 if string keyword

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:isKeyword
  setlocal EnableDelayedExpansion
  if defined _c_%~1 (endlocal & exit /B 0)
  endlocal & exit /B 1

:isKeywordStr
  setlocal EnableDelayedExpansion
  if defined _ks_%~1 (endlocal & exit /B 0)
  endlocal & exit /B 1

:toCode
  setlocal EnableDelayedExpansion
  set "r=!_c_%~1!"
  if "!r!"=="" (endlocal & exit /B 1)
  endlocal & set "%~2=%r%" & exit /B 0

:fromCode
  setlocal EnableDelayedExpansion
  set "r=!_k_%~1!"
  if "!r!"=="" (endlocal & exit /B 1)
  endlocal & set "%~2=%r%" & exit /B 0


@REM === Load all lookup tables into env vars ===
:init
  @REM _k_XX = keyword name for token XX (fromCode)
  @REM _c_NAME = token code for keyword NAME (toCode)

  @REM --- Primary statement tokens 0x81-0xC8 ---
  set "_k_81=END"    & set "_c_END=81"
  set "_k_82=FOR"    & set "_c_FOR=82"
  set "_k_83=NEXT"   & set "_c_NEXT=83"
  set "_k_84=DATA"   & set "_c_DATA=84"
  set "_k_85=INPUT"  & set "_c_INPUT=85"
  set "_k_86=DIM"    & set "_c_DIM=86"
  set "_k_87=READ"   & set "_c_READ=87"
  set "_k_88=LET"    & set "_c_LET=88"
  set "_k_89=GOTO"   & set "_c_GOTO=89"
  set "_k_8A=RUN"    & set "_c_RUN=8A"
  set "_k_8B=IF"     & set "_c_IF=8B"
  set "_k_8C=RESTORE"& set "_c_RESTORE=8C"
  set "_k_8D=GOSUB"  & set "_c_GOSUB=8D"
  set "_k_8E=RETURN" & set "_c_RETURN=8E"
  set "_k_8F=REM"    & set "_c_REM=8F"
  set "_k_90=STOP"   & set "_c_STOP=90"
  set "_k_91=PRINT"  & set "_c_PRINT=91"
  set "_k_92=CLEAR"  & set "_c_CLEAR=92"
  set "_k_93=LIST"   & set "_c_LIST=93"
  set "_k_94=NEW"    & set "_c_NEW=94"
  set "_k_95=ON"     & set "_c_ON=95"
  set "_k_96=WAIT"   & set "_c_WAIT=96"
  set "_k_97=DEF"    & set "_c_DEF=97"
  set "_k_98=POKE"   & set "_c_POKE=98"
  set "_k_99=CONT"   & set "_c_CONT=99"
  set "_k_9C=OUT"    & set "_c_OUT=9C"
  set "_k_9D=LPRINT" & set "_c_LPRINT=9D"
  set "_k_9E=LLIST"  & set "_c_LLIST=9E"
  set "_k_A0=WIDTH"  & set "_c_WIDTH=A0"
  set "_k_A1=ELSE"   & set "_c_ELSE=A1"
  set "_k_A2=TRON"   & set "_c_TRON=A2"
  set "_k_A3=TROFF"  & set "_c_TROFF=A3"
  set "_k_A4=SWAP"   & set "_c_SWAP=A4"
  set "_k_A5=ERASE"  & set "_c_ERASE=A5"
  set "_k_A6=EDIT"   & set "_c_EDIT=A6"
  set "_k_A7=ERROR"  & set "_c_ERROR=A7"
  set "_k_A8=RESUME" & set "_c_RESUME=A8"
  set "_k_A9=DELETE" & set "_c_DELETE=A9"
  set "_k_AA=AUTO"   & set "_c_AUTO=AA"
  set "_k_AB=RENUM"  & set "_c_RENUM=AB"
  set "_k_AC=DEFSTR" & set "_c_DEFSTR=AC"
  set "_k_AD=DEFINT" & set "_c_DEFINT=AD"
  set "_k_AE=DEFSNG" & set "_c_DEFSNG=AE"
  set "_k_AF=DEFDBL" & set "_c_DEFDBL=AF"
  set "_k_B0=LINE"   & set "_c_LINE=B0"
  set "_k_B1=WHILE"  & set "_c_WHILE=B1"
  set "_k_B2=WEND"   & set "_c_WEND=B2"
  set "_k_B3=CALL"   & set "_c_CALL=B3"
  set "_k_B5=WRITE"  & set "_c_WRITE=B5"
  set "_k_B6=OPTION" & set "_c_OPTION=B6"
  set "_k_B7=RANDOMIZE"& set "_c_RANDOMIZE=B7"
  set "_k_B8=OPEN"   & set "_c_OPEN=B8"
  set "_k_B9=CLOSE"  & set "_c_CLOSE=B9"
  set "_k_BA=LOAD"   & set "_c_LOAD=BA"
  set "_k_BB=MERGE"  & set "_c_MERGE=BB"
  set "_k_BC=SAVE"   & set "_c_SAVE=BC"
  set "_k_BD=COLOR"  & set "_c_COLOR=BD"
  set "_k_BE=CLS"    & set "_c_CLS=BE"
  set "_k_BF=MOTOR"  & set "_c_MOTOR=BF"
  set "_k_C0=BSAVE"  & set "_c_BSAVE=C0"
  set "_k_C1=BLOAD"  & set "_c_BLOAD=C1"
  set "_k_C2=SOUND"  & set "_c_SOUND=C2"
  set "_k_C3=BEEP"   & set "_c_BEEP=C3"
  set "_k_C4=PSET"   & set "_c_PSET=C4"
  set "_k_C5=PRESET" & set "_c_PRESET=C5"
  set "_k_C6=SCREEN" & set "_c_SCREEN=C6"
  set "_k_C7=KEY"    & set "_c_KEY=C7"
  set "_k_C8=LOCATE" & set "_c_LOCATE=C8"

  @REM --- Sub-keywords 0xC9-0xDB ---
  set "_k_C9=TO"     & set "_c_TO=C9"
  set "_k_CA=THEN"   & set "_c_THEN=CA"
  set "_k_CB=TAB("   & set "_c_TAB(=CB"
  set "_k_CC=STEP"   & set "_c_STEP=CC"
  set "_k_CD=USR"    & set "_c_USR=CD"
  set "_k_CE=FN"     & set "_c_FN=CE"
  set "_k_CF=SPC("   & set "_c_SPC(=CF"
  set "_k_D0=NOT"    & set "_c_NOT=D0"
  set "_k_D1=ERL"    & set "_c_ERL=D1"
  set "_k_D2=ERR"    & set "_c_ERR=D2"
  set "_k_D3=STRING$"& set "_c_STRING$=D3"
  set "_k_D4=USING"  & set "_c_USING=D4"
  set "_k_D5=INSTR"  & set "_c_INSTR=D5"
  set "_k_D7=VARPTR" & set "_c_VARPTR=D7"
  set "_k_D8=CSRLIN" & set "_c_CSRLIN=D8"
  set "_k_D9=POINT"  & set "_c_POINT=D9"
  set "_k_DA=OFF"    & set "_c_OFF=DA"
  set "_k_DB=INKEY$" & set "_c_INKEY$=DB"

  @REM --- Operator keywords 0xEE-0xF4 ---
  set "_k_EE=AND"    & set "_c_AND=EE"
  set "_k_EF=OR"     & set "_c_OR=EF"
  set "_k_F0=XOR"    & set "_c_XOR=F0"
  set "_k_F1=EQV"    & set "_c_EQV=F1"
  set "_k_F2=IMP"    & set "_c_IMP=F2"
  set "_k_F3=MOD"    & set "_c_MOD=F3"

  @REM --- Two-byte tokens: 0xFD prefix (file I/O) ---
  set "_k_FD81=CVI"  & set "_c_CVI=FD81"
  set "_k_FD82=CVS"  & set "_c_CVS=FD82"
  set "_k_FD83=CVD"  & set "_c_CVD=FD83"
  set "_k_FD84=MKI$" & set "_c_MKI$=FD84"
  set "_k_FD85=MKS$" & set "_c_MKS$=FD85"
  set "_k_FD86=MKD$" & set "_c_MKD$=FD86"
  set "_k_FD87=EXTERR"& set "_c_EXTERR=FD87"

  @REM --- Two-byte tokens: 0xFE prefix (disk/system) ---
  set "_k_FE81=FILES" & set "_c_FILES=FE81"
  set "_k_FE82=FIELD" & set "_c_FIELD=FE82"
  set "_k_FE83=SYSTEM"& set "_c_SYSTEM=FE83"
  set "_k_FE84=NAME"  & set "_c_NAME=FE84"
  set "_k_FE85=LSET"  & set "_c_LSET=FE85"
  set "_k_FE86=RSET"  & set "_c_RSET=FE86"
  set "_k_FE87=KILL"  & set "_c_KILL=FE87"
  set "_k_FE88=PUT"   & set "_c_PUT=FE88"
  set "_k_FE89=GET"   & set "_c_GET=FE89"
  set "_k_FE8A=RESET" & set "_c_RESET=FE8A"
  set "_k_FE8B=COMMON"& set "_c_COMMON=FE8B"
  set "_k_FE8C=CHAIN" & set "_c_CHAIN=FE8C"
  set "_k_FE8D=DATE$" & set "_c_DATE$=FE8D"
  set "_k_FE8E=TIME$" & set "_c_TIME$=FE8E"
  set "_k_FE8F=PAINT" & set "_c_PAINT=FE8F"
  set "_k_FE90=COM"   & set "_c_COM=FE90"
  set "_k_FE91=CIRCLE"& set "_c_CIRCLE=FE91"
  set "_k_FE92=DRAW"  & set "_c_DRAW=FE92"
  set "_k_FE93=PLAY"  & set "_c_PLAY=FE93"
  set "_k_FE94=TIMER" & set "_c_TIMER=FE94"
  set "_k_FE95=ERDEV" & set "_c_ERDEV=FE95"
  set "_k_FE96=IOCTL" & set "_c_IOCTL=FE96"
  set "_k_FE97=CHDIR" & set "_c_CHDIR=FE97"
  set "_k_FE98=MKDIR" & set "_c_MKDIR=FE98"
  set "_k_FE99=RMDIR" & set "_c_RMDIR=FE99"
  set "_k_FE9A=SHELL" & set "_c_SHELL=FE9A"
  set "_k_FE9B=ENVIRON"& set "_c_ENVIRON=FE9B"
  set "_k_FE9C=VIEW"  & set "_c_VIEW=FE9C"
  set "_k_FE9D=WINDOW"& set "_c_WINDOW=FE9D"
  set "_k_FE9E=PMAP"  & set "_c_PMAP=FE9E"
  set "_k_FE9F=PALETTE"& set "_c_PALETTE=FE9F"
  set "_k_FEA0=LCOPY" & set "_c_LCOPY=FEA0"
  set "_k_FEA1=CALLS" & set "_c_CALLS=FEA1"
  set "_k_FEA5=PCOPY" & set "_c_PCOPY=FEA5"
  set "_k_FEA7=LOCK"  & set "_c_LOCK=FEA7"
  set "_k_FEA8=UNLOCK"& set "_c_UNLOCK=FEA8"

  @REM --- Two-byte tokens: 0xFF prefix (functions) ---
  set "_k_FF81=LEFT$" & set "_c_LEFT$=FF81"
  set "_k_FF82=RIGHT$"& set "_c_RIGHT$=FF82"
  set "_k_FF83=MID$"  & set "_c_MID$=FF83"
  set "_k_FF84=SGN"   & set "_c_SGN=FF84"
  set "_k_FF85=INT"   & set "_c_INT=FF85"
  set "_k_FF86=ABS"   & set "_c_ABS=FF86"
  set "_k_FF87=SQR"   & set "_c_SQR=FF87"
  set "_k_FF88=RND"   & set "_c_RND=FF88"
  set "_k_FF89=SIN"   & set "_c_SIN=FF89"
  set "_k_FF8A=LOG"   & set "_c_LOG=FF8A"
  set "_k_FF8B=EXP"   & set "_c_EXP=FF8B"
  set "_k_FF8C=COS"   & set "_c_COS=FF8C"
  set "_k_FF8D=TAN"   & set "_c_TAN=FF8D"
  set "_k_FF8E=ATN"   & set "_c_ATN=FF8E"
  set "_k_FF8F=FRE"   & set "_c_FRE=FF8F"
  set "_k_FF90=INP"   & set "_c_INP=FF90"
  set "_k_FF91=POS"   & set "_c_POS=FF91"
  set "_k_FF92=LEN"   & set "_c_LEN=FF92"
  set "_k_FF93=STR$"  & set "_c_STR$=FF93"
  set "_k_FF94=VAL"   & set "_c_VAL=FF94"
  set "_k_FF95=ASC"   & set "_c_ASC=FF95"
  set "_k_FF96=CHR$"  & set "_c_CHR$=FF96"
  set "_k_FF97=PEEK"  & set "_c_PEEK=FF97"
  set "_k_FF98=SPACE$"& set "_c_SPACE$=FF98"
  set "_k_FF99=OCT$"  & set "_c_OCT$=FF99"
  set "_k_FF9A=HEX$"  & set "_c_HEX$=FF9A"
  set "_k_FF9B=LPOS"  & set "_c_LPOS=FF9B"
  set "_k_FF9C=CINT"  & set "_c_CINT=FF9C"
  set "_k_FF9D=CSNG"  & set "_c_CSNG=FF9D"
  set "_k_FF9E=CDBL"  & set "_c_CDBL=FF9E"
  set "_k_FF9F=FIX"   & set "_c_FIX=FF9F"
  set "_k_FFA0=PEN"   & set "_c_PEN=FFA0"
  set "_k_FFA1=STICK" & set "_c_STICK=FFA1"
  set "_k_FFA2=STRIG" & set "_c_STRIG=FFA2"
  set "_k_FFA3=EOF"   & set "_c_EOF=FFA3"
  set "_k_FFA4=LOC"   & set "_c_LOC=FFA4"
  set "_k_FFA5=LOF"   & set "_c_LOF=FFA5"
  set "_k_FFA6=VARPTR$"& set "_c_VARPTR$=FFA6"

  @REM --- String function keywords ---
  set "_ks_STRING$=1"& set "_ks_INKEY$=1"& set "_ks_MKI$=1"& set "_ks_MKS$=1"
  set "_ks_MKD$=1"& set "_ks_LEFT$=1"& set "_ks_RIGHT$=1"& set "_ks_MID$=1"
  set "_ks_STR$=1"& set "_ks_CHR$=1"& set "_ks_SPACE$=1"& set "_ks_OCT$=1"
  set "_ks_HEX$=1"& set "_ks_DATE$=1"& set "_ks_TIME$=1"& set "_ks_VARPTR$=1"
  set "_ks_ENVIRON=1"& set "_ks_IOCTL=1"

  exit /B 0


:_start
  call :init
  echo keyword.bat - GW-BASIC keyword token table loaded
