@REM Lexer tests
@REM Input is hex-encoded ASCII. Helper :_hex converts readable text.
@REM Each call to expect runs: lexer ParseTxt <hex> __

call %test% "lexer.numbers"
  call :_t "10 100 + 200"       "LN__10 NUM_i0064 PLUS NUM_i00C8 EOL"
  call :_t "10 0"               "LN__10 NUM_i0000 EOL"
  call :_t "10 1"               "LN__10 NUM_i0001 EOL"
  call :_t "10 32767"           "LN__10 NUM_i7FFF EOL"

call %test% "lexer.operators"
  call :_t "10 1+2"             "LN__10 NUM_i0001 PLUS NUM_i0002 EOL"
  call :_t "10 1-2"             "LN__10 NUM_i0001 MINUS NUM_i0002 EOL"
  call :_t "10 1*2"             "LN__10 NUM_i0001 MUL NUM_i0002 EOL"
  call :_t "10 1/2"             "LN__10 NUM_i0001 DIV NUM_i0002 EOL"
  call :_t "10 7\2"             "LN__10 NUM_i0007 IDIV NUM_i0002 EOL"
  call :_t "10 2^3"             "LN__10 NUM_i0002 POW NUM_i0003 EOL"

call %test% "lexer.comparison"
  call :_t "10 A=1"             "LN__10 VAR_UNK_A EQ NUM_i0001 EOL"
  call :_t "10 A<1"             "LN__10 VAR_UNK_A LT NUM_i0001 EOL"
  call :_t "10 A>1"             "LN__10 VAR_UNK_A GT NUM_i0001 EOL"
  call :_t "10 A<=1"            "LN__10 VAR_UNK_A LE NUM_i0001 EOL"
  call :_t "10 A>=1"            "LN__10 VAR_UNK_A GE NUM_i0001 EOL"
  call :_t "10 A<>1"            "LN__10 VAR_UNK_A NE NUM_i0001 EOL"

call %test% "lexer.delimiters"
  call :_t "10 (1,2)"           "LN__10 OPAR NUM_i0001 COMA NUM_i0002 CPAR EOL"
  call :_t "10 A;B"             "LN__10 VAR_UNK_A SEMICOLON VAR_UNK_B EOL"
  call :_t "10 A:B"             "LN__10 VAR_UNK_A COLON VAR_UNK_B EOL"

call %test% "lexer.keywords"
  call :_t "10 PRINT"           "LN__10 PRINT EOL"
  call :_t "10 GOTO 20"         "LN__10 GOTO NUM_i0014 EOL"
  call :_t "10 IF A THEN 20"    "LN__10 IF VAR_UNK_A THEN NUM_i0014 EOL"
  call :_t "10 FOR I=1 TO 10"   "LN__10 FOR VAR_UNK_I EQ NUM_i0001 TO NUM_i000A EOL"
  call :_t "10 DIM A(10)"       "LN__10 DIM VAR_UNK_A OPAR NUM_i000A CPAR EOL"

call %test% "lexer.variables"
  call :_t "10 A"               "LN__10 VAR_UNK_A EOL"
  call :_t "10 AB"              "LN__10 VAR_UNK_AB EOL"
  call :_t "10 A1"              "LN__10 VAR_UNK_A1 EOL"

call %test% "lexer.strings"
  @REM "HI" = hex 48 49
  call :_t "10 A$"              "LN__10 VAR_STR_A EOL"

call %test% "lexer.comment"
  @REM REM text -> REM_hex_encoded
  @REM ' text -> REM_hex_encoded
  @REM "10 REM HI" -> REM + REM_2048 49 (space H I)
  call :_t "10 REM HI"          "LN__10 REM REM_204849 EOL"

call %test% "lexer.printShorthand"
  call :_t "10 ?"               "LN__10 PRINT EOL"

exit /B


@REM === Helper: convert ASCII text to hex, run lexer, compare result ===
:_t
  setlocal EnableDelayedExpansion
  set "text=%~1"
  set "expected=%~2"
  set "hex="
  set /a "_p=0"
:_t_loop
  set "_ch=!text:~%_p%,1!"
  if "!_ch!"=="" goto :_t_run
  @REM Convert char to hex pair
  set "_hx="
  if "!_ch!"==" " set "_hx=20"
  if "!_ch!"=="0" set "_hx=30"
  if "!_ch!"=="1" set "_hx=31"
  if "!_ch!"=="2" set "_hx=32"
  if "!_ch!"=="3" set "_hx=33"
  if "!_ch!"=="4" set "_hx=34"
  if "!_ch!"=="5" set "_hx=35"
  if "!_ch!"=="6" set "_hx=36"
  if "!_ch!"=="7" set "_hx=37"
  if "!_ch!"=="8" set "_hx=38"
  if "!_ch!"=="9" set "_hx=39"
  if "!_ch!"=="A" set "_hx=41"
  if "!_ch!"=="B" set "_hx=42"
  if "!_ch!"=="C" set "_hx=43"
  if "!_ch!"=="D" set "_hx=44"
  if "!_ch!"=="E" set "_hx=45"
  if "!_ch!"=="F" set "_hx=46"
  if "!_ch!"=="G" set "_hx=47"
  if "!_ch!"=="H" set "_hx=48"
  if "!_ch!"=="I" set "_hx=49"
  if "!_ch!"=="J" set "_hx=4A"
  if "!_ch!"=="K" set "_hx=4B"
  if "!_ch!"=="L" set "_hx=4C"
  if "!_ch!"=="M" set "_hx=4D"
  if "!_ch!"=="N" set "_hx=4E"
  if "!_ch!"=="O" set "_hx=4F"
  if "!_ch!"=="P" set "_hx=50"
  if "!_ch!"=="Q" set "_hx=51"
  if "!_ch!"=="R" set "_hx=52"
  if "!_ch!"=="S" set "_hx=53"
  if "!_ch!"=="T" set "_hx=54"
  if "!_ch!"=="U" set "_hx=55"
  if "!_ch!"=="V" set "_hx=56"
  if "!_ch!"=="W" set "_hx=57"
  if "!_ch!"=="X" set "_hx=58"
  if "!_ch!"=="Y" set "_hx=59"
  if "!_ch!"=="Z" set "_hx=5A"
  if "!_ch!"=="+" set "_hx=2B"
  if "!_ch!"=="-" set "_hx=2D"
  if "!_ch!"=="*" set "_hx=2A"
  if "!_ch!"=="/" set "_hx=2F"
  if "!_ch!"=="\" set "_hx=5C"
  if "!_ch!"=="=" set "_hx=3D"
  if "!_ch!"=="(" set "_hx=28"
  if "!_ch!"==")" set "_hx=29"
  if "!_ch!"=="," set "_hx=2C"
  if "!_ch!"==";" set "_hx=3B"
  if "!_ch!"==":" set "_hx=3A"
  if "!_ch!"=="." set "_hx=2E"
  if "!_ch!"=="?" set "_hx=3F"
  if "!_ch!"=="'" set "_hx=27"
  if "!_ch!"=="$" set "_hx=24"
  if "!_ch!"=="^" set "_hx=5E"
  if "!_ch!"=="#" set "_hx=23"
  if "!_ch!"=="<" set "_hx=3C"
  if "!_ch!"==">" set "_hx=3E"
  set "hex=!hex!!_hx!"
  set /a "_p+=1"
  goto :_t_loop
:_t_run
  endlocal & call expect "lexer ParseTxt %hex% __" "%~2"
  exit /B
