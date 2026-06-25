@REM Lexer tests
@REM Uses str encode to convert readable text to hex input

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
  @REM ^ (caret) can't be tested via str encode — batch escaping multiplies it
  @REM POW operator is tested directly in parser tests

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

call %test% "lexer.tab.is.whitespace"
  @REM TAB (0x09) is whitespace, like a space.  Fed as raw hex so the literal
  @REM tab is not mangled by cmd's own argument parsing.  "10<TAB>PRINT 5".
  call expect "lexer ParseTxt 3130095052494E542035 __" "LN__10 PRINT NUM_i0005 EOL"
  @REM A tab between two operands also just separates them: "10 1<TAB>+2".
  call expect "lexer ParseTxt 31302031092B32 __" "LN__10 NUM_i0001 PLUS NUM_i0002 EOL"

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
  call :_t "10 A$"              "LN__10 VAR_STR_A EOL"

call %test% "lexer.comment"
  call :_t "10 REM HI"          "LN__10 REM REM_204849 EOL"

call %test% "lexer.printShorthand"
  call :_t "10 ?"               "LN__10 PRINT EOL"

call %test% "lexer.dotted.identifiers"
  call :_t "10 A.B=1"           "LN__10 VAR_UNK_A.B EQ NUM_i0001 EOL"
  call :_t "10 THIS.PERS"       "LN__10 VAR_UNK_THIS.PERS EOL"

call %test% "lexer.reversed.relops"
  call :_t "10 A=>1"            "LN__10 VAR_UNK_A GE NUM_i0001 EOL"
  call :_t "10 A=<1"            "LN__10 VAR_UNK_A LE NUM_i0001 EOL"
  call :_t "10 A><1"            "LN__10 VAR_UNK_A NE NUM_i0001 EOL"

call %test% "lexer.data.unquoted"
  call :_t "10 DATA AB, 12"     "LN__10 DATA STR_4142 COMA NUM_i000C EOL"
  call :_t "10 DATA -5, +7"     "LN__10 DATA NUM_iFFFB COMA NUM_i0007 EOL"
  call :_t "10 DATA A B"        "LN__10 DATA STR_412042 EOL"
  call :_t "10 DATA 1.5, 2E3"   "LN__10 DATA NUM_s80400000 COMA NUM_s8A7A0000 EOL"
  call :_t "10 DATA X: GOTO 10" "LN__10 DATA STR_58 COLON GOTO NUM_i000A EOL"
  call :_t "10 DATA 212-44"     "LN__10 DATA STR_3231322D3434 EOL"

exit /B


@REM === Helper: encode text to hex, run lexer, compare ===
:_t
  call %GWSRC%\str\str encode "%~1" _hex
  call expect "lexer ParseTxt %_hex% __" "%~2"
  exit /B
