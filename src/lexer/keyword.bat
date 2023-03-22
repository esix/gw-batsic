@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start


:isKeyword id
  if "%~1"=="ABS"       exit /b 0
  if "%~1"=="ASC"       exit /b 0
  if "%~1"=="ATN"       exit /b 0
  if "%~1"=="ABS"       exit /b 0
  if "%~1"=="AUTO"      exit /b 0
  if "%~1"=="BEEP"      exit /b 0
  if "%~1"=="BLOAD"     exit /b 0
  if "%~1"=="BSAVE"     exit /b 0
  if "%~1"=="CALL"      exit /b 0
  if "%~1"=="CDBL"      exit /b 0
  if "%~1"=="CHAIN"     exit /b 0
  if "%~1"=="CHDIR"     exit /b 0
  if "%~1"=="CINT"      exit /b 0
  if "%~1"=="CIRCLE"    exit /b 0
  if "%~1"=="CLEAR"     exit /b 0
  if "%~1"=="CLOSE"     exit /b 0
  if "%~1"=="CLS"       exit /b 0
  if "%~1"=="COLOR"     exit /b 0
  if "%~1"=="COM"       exit /b 0
  if "%~1"=="COMMON"    exit /b 0
  if "%~1"=="CONT"      exit /b 0
  if "%~1"=="COS"       exit /b 0
  if "%~1"=="CSNG"      exit /b 0
  if "%~1"=="CSRLIN"    exit /b 0
  if "%~1"=="CVD"       exit /b 0
  if "%~1"=="CVI"       exit /b 0
  if "%~1"=="CVS"       exit /b 0
  if "%~1"=="DATA"      exit /b 0
  if "%~1"=="DEF"       exit /b 0
  if "%~1"=="DEFINT"    exit /b 0
  if "%~1"=="DEFDBL"    exit /b 0
  if "%~1"=="DEFSNG"    exit /b 0
  if "%~1"=="DEFSTR"    exit /b 0
  if "%~1"=="DELETE"    exit /b 0
  if "%~1"=="DIM"       exit /b 0
  if "%~1"=="DRAW"      exit /b 0

  if "%~1"=="EDIT"      exit /b 0
  if "%~1"=="END"       exit /b 0
  if "%~1"=="ENVIRON"   exit /b 0
  if "%~1"=="EOF"       exit /b 0
  if "%~1"=="ERASE"     exit /b 0
  if "%~1"=="ERDEV"     exit /b 0
  if "%~1"=="ERL"       exit /b 0
  if "%~1"=="ERR"       exit /b 0
  if "%~1"=="ERROR"     exit /b 0
  if "%~1"=="EXP"       exit /b 0
  if "%~1"=="EXTERR"    exit /b 0

  if "%~1"=="FIELD"     exit /b 0
  if "%~1"=="FILES"     exit /b 0
  if "%~1"=="FIX"       exit /b 0
  if "%~1"=="FN"        exit /b 0
  if "%~1"=="FOR"       exit /b 0
  if "%~1"=="FRE"       exit /b 0

  if "%~1"=="GET"       exit /b 0
  if "%~1"=="GOSUB"     exit /b 0
  if "%~1"=="GOTO"      exit /b 0

  if "%~1"=="IF"        exit /b 0
  if "%~1"=="INP"       exit /b 0
  if "%~1"=="INPUT"     exit /b 0
  if "%~1"=="INSTR"     exit /b 0
  if "%~1"=="INT"       exit /b 0
  if "%~1"=="IOCTL"     exit /b 0

  if "%~1"=="KEY"       exit /b 0
  if "%~1"=="KILL"      exit /b 0

  if "%~1"=="LEN"       exit /b 0
  if "%~1"=="LET"       exit /b 0
  if "%~1"=="LINE"      exit /b 0
  if "%~1"=="LIST"      exit /b 0
  if "%~1"=="LLIST"     exit /b 0
  if "%~1"=="LOAD"      exit /b 0
  if "%~1"=="LOC"       exit /b 0
  if "%~1"=="LOCATE"    exit /b 0
  if "%~1"=="LOCK"      exit /b 0
  if "%~1"=="LOF"       exit /b 0
  if "%~1"=="LOG"       exit /b 0
  if "%~1"=="LPOS"      exit /b 0
  if "%~1"=="LPRINT"    exit /b 0
  if "%~1"=="LSET"      exit /b 0

  if "%~1"=="MERGE"     exit /b 0
  if "%~1"=="MKDIR"     exit /b 0

  if "%~1"=="NAME"      exit /b 0
  if "%~1"=="NEW"       exit /b 0
  if "%~1"=="NEXT"      exit /b 0

  if "%~1"=="ON"        exit /b 0
  if "%~1"=="OPEN"      exit /b 0
  :: OPTION BASE Statement      :: base is not keyword!!!
  if "%~1"=="OUT"       exit /b 0

  if "%~1"=="PAINT"     exit /b 0
  if "%~1"=="PALETTE"   exit /b 0
  if "%~1"=="PCOPY"     exit /b 0
  if "%~1"=="PEEK"      exit /b 0
  if "%~1"=="PEN"       exit /b 0
  if "%~1"=="PLAY"      exit /b 0
  if "%~1"=="PMAP"      exit /b 0
  if "%~1"=="POINT"     exit /b 0
  if "%~1"=="POKE"      exit /b 0
  if "%~1"=="POS"       exit /b 0
  if "%~1"=="PRESET"    exit /b 0
  if "%~1"=="PSET"      exit /b 0
  if "%~1"=="PRINT"     exit /b 0
  if "%~1"=="PUT"       exit /b 0

  if "%~1"=="RANDOMIZE" exit /b 0
  if "%~1"=="READ"      exit /b 0
  if "%~1"=="REM"       exit /b 0
  if "%~1"=="RENUM"     exit /b 0
  if "%~1"=="RESET"     exit /b 0
  if "%~1"=="RESTORE"   exit /b 0
  if "%~1"=="RESUME"    exit /b 0
  if "%~1"=="RETURN"    exit /b 0
  if "%~1"=="MDIR"      exit /b 0
  if "%~1"=="RND"       exit /b 0
  if "%~1"=="RSET"      exit /b 0
  if "%~1"=="RUN"       exit /b 0

  if "%~1"=="SAVE"      exit /b 0
  if "%~1"=="SCREEN"    exit /b 0
  if "%~1"=="SEG"       exit /b 0
  if "%~1"=="SGN"       exit /b 0
  if "%~1"=="SHELL"     exit /b 0
  if "%~1"=="SIN"       exit /b 0
  if "%~1"=="SOUND"     exit /b 0
  if "%~1"=="SPC"       exit /b 0
  if "%~1"=="SQR"       exit /b 0
  if "%~1"=="STICK"     exit /b 0
  if "%~1"=="STOP"      exit /b 0
  if "%~1"=="STRIG"     exit /b 0
  if "%~1"=="SWAP"      exit /b 0
  if "%~1"=="SYSTEM"    exit /b 0

  if "%~1"=="TAB"       exit /b 0
  if "%~1"=="TAN"       exit /b 0
  if "%~1"=="THEN"       exit /b 0
  if "%~1"=="TIMER"     exit /b 0
  if "%~1"=="TROFF"     exit /b 0
  if "%~1"=="TRON"      exit /b 0

  if "%~1"=="UNLOCK"    exit /b 0
  if "%~1"=="USING"     exit /b 0
  if "%~1"=="USR"       exit /b 0


  if "%~1"=="VAL"       exit /b 0
  if "%~1"=="VARPTR"    exit /b 0
  if "%~1"=="VIEW"      exit /b 0

  if "%~1"=="WAIT"      exit /b 0
  if "%~1"=="WHILE"     exit /b 0
  if "%~1"=="WEND"      exit /b 0
  if "%~1"=="WIDTH"     exit /b 0
  if "%~1"=="WINDOW"    exit /b 0
  if "%~1"=="WRITE"     exit /b 0
exit /b 1


:isKeywordStr id
  if "%~1"=="CHR"       exit /b 0
  if "%~1"=="DATE"      exit /b 0
  if "%~1"=="ENVIRON"   exit /b 0
  if "%~1"=="ERDEV"     exit /b 0
  if "%~1"=="HEX"       exit /b 0
  if "%~1"=="INKEY"     exit /b 0
  if "%~1"=="INPUT"     exit /b 0
  if "%~1"=="IOCTL"     exit /b 0
  if "%~1"=="LEFT"      exit /b 0
  if "%~1"=="MID"       exit /b 0
  if "%~1"=="MID"       exit /b 0
  if "%~1"=="MKD"       exit /b 0
  if "%~1"=="MKI"       exit /b 0
  if "%~1"=="MKS"       exit /b 0
  if "%~1"=="OCT"       exit /b 0
  if "%~1"=="RIGHT"     exit /b 0
  if "%~1"=="SPACE"     exit /b 0
  if "%~1"=="STR"       exit /b 0
  if "%~1"=="STRING"    exit /b 0
  if "%~1"=="TIME"      exit /b 0
  if "%~1"=="VARPTR"    exit /b 0
exit /b 1


:isKeywordDbl id
  if "%~1"=="INPUT"     exit /b 0
  if "%~1"=="PRINT"     exit /b 0
  if "%~1"=="WRITE"     exit /b 0
exit /b 1


:_start
  echo keyword