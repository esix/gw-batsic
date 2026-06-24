
@REM Parser tests — clean postfix output (values + actions only)

call %test% "parse.simple"
  call :_p "END EOL" "END"
  call :_p "STOP EOL" "STOP"
  call :_p "CLS EOL" "CLS"
  call :_p "BEEP EOL" "BEEP"
  call :_p "RETURN EOL" "RETURN"

call %test% "parse.print"
  call :_p "PRINT NUM_i0064 EOL" "NUM_i0064 PEND"
  call :_p "PRINT VAR_UNK_A SEMICOLON VAR_UNK_B EOL" "VAR_UNK_A PSEMI VAR_UNK_B PEND"
  call :_p "PRINT VAR_UNK_A COMA VAR_UNK_B EOL" "VAR_UNK_A PTAB VAR_UNK_B PEND"

call %test% "parse.assignment"
  call :_p "VAR_UNK_A EQ NUM_i0001 EOL" "VAR_UNK_A NUM_i0001 ASSIGN"
  call :_p "LET VAR_UNK_A EQ NUM_i0001 EOL" "VAR_UNK_A NUM_i0001 ASSIGN"

call %test% "parse.expr.arith"
  call :_p "PRINT NUM_i0001 PLUS NUM_i0002 EOL" "NUM_i0001 NUM_i0002 ADD PEND"
  call :_p "PRINT NUM_i0002 MUL NUM_i0003 EOL" "NUM_i0002 NUM_i0003 MUL PEND"
  call :_p "PRINT NUM_i0001 PLUS NUM_i0002 MUL NUM_i0003 EOL" "NUM_i0001 NUM_i0002 NUM_i0003 MUL ADD PEND"
  call :_p "PRINT MINUS NUM_i0001 EOL" "NUM_i0001 NEG PEND"

call %test% "parse.expr.parens"
  call :_p "PRINT OPAR NUM_i0001 PLUS NUM_i0002 CPAR MUL NUM_i0003 EOL" "NUM_i0001 NUM_i0002 ADD NUM_i0003 MUL PEND"

call %test% "parse.comparison"
  call :_p "IF VAR_UNK_A LT NUM_i0001 THEN NUM_i0064 EOL" "VAR_UNK_A NUM_i0001 CMP_LT IF NUM_i0064 IF_GOTO ENDIF"
  call :_p "IF VAR_UNK_A GE VAR_UNK_B THEN NUM_i0064 EOL" "VAR_UNK_A VAR_UNK_B CMP_GE IF NUM_i0064 IF_GOTO ENDIF"

call %test% "parse.goto"
  call :_p "GOTO NUM_i0064 EOL" "NUM_i0064 GOTO"
  call :_p "GOSUB NUM_i0064 EOL" "NUM_i0064 GOSUB"

call %test% "parse.if"
  call :_p "IF VAR_UNK_A THEN NUM_i0064 EOL" "VAR_UNK_A IF NUM_i0064 IF_GOTO ENDIF"
  call :_p "IF VAR_UNK_A THEN GOTO NUM_i0064 EOL" "VAR_UNK_A IF NUM_i0064 GOTO ENDIF"

call %test% "parse.for"
  @REM No STEP → grammar emits FOR_DEFAULT_STEP marker, which pushes i0001 at run time.
  call :_p "FOR VAR_UNK_I EQ NUM_i0001 TO NUM_i000A EOL" "VAR_UNK_I NUM_i0001 NUM_i000A FOR_DEFAULT_STEP FOR"
  call :_p "FOR VAR_UNK_I EQ NUM_i0001 TO NUM_i000A STEP NUM_i0002 EOL" "VAR_UNK_I NUM_i0001 NUM_i000A NUM_i0002 FOR"
  call :_p "NEXT VAR_UNK_I EOL" "VAR_UNK_I NEXT"
  call :_p "NEXT EOL" "NEXT"

call %test% "parse.dim"
  call :_p "DIM VAR_UNK_A OPAR NUM_i000A CPAR EOL" "VAR_UNK_A ARR_START NUM_i000A DIM"

call %test% "parse.rem"
  call :_p "REM REM_48454C4C4F EOL" "REM_48454C4C4F REM"

call %test% "parse.functions"
  call :_p "PRINT ABS OPAR VAR_UNK_X CPAR EOL" "VAR_UNK_X FN_ABS PEND"
  call :_p "PRINT LEN OPAR VAR_STR_A CPAR EOL" "VAR_STR_A FN_LEN PEND"
  call :_p "PRINT LEFT$ OPAR VAR_STR_A COMA NUM_i0003 CPAR EOL" "VAR_STR_A NUM_i0003 FN_LEFT PEND"

call %test% "parse.colon"
  call :_p "CLS COLON BEEP EOL" "CLS BEEP"

call %test% "parse.colon.assign"
  call :_p "VAR_UNK_A EQ NUM_i0001 COLON VAR_UNK_B EQ NUM_i0002 COLON PRINT VAR_UNK_A PLUS VAR_UNK_B EOL" "VAR_UNK_A NUM_i0001 ASSIGN VAR_UNK_B NUM_i0002 ASSIGN VAR_UNK_A VAR_UNK_B ADD PEND"

call %test% "parse.expr.arith.more"
  call :_p "PRINT VAR_UNK_A MINUS VAR_UNK_B EOL"    "VAR_UNK_A VAR_UNK_B SUB PEND"
  call :_p "PRINT VAR_UNK_A DIV VAR_UNK_B EOL"      "VAR_UNK_A VAR_UNK_B DIV PEND"
  call :_p "PRINT VAR_UNK_A POW VAR_UNK_B EOL"      "VAR_UNK_A VAR_UNK_B POW PEND"
  call :_p "PRINT VAR_UNK_A IDIV VAR_UNK_B EOL"     "VAR_UNK_A VAR_UNK_B IDIV PEND"
  call :_p "PRINT VAR_UNK_A MOD VAR_UNK_B EOL"      "VAR_UNK_A VAR_UNK_B MOD PEND"
  call :_p "PRINT NUM_i0001 PLUS NUM_i0002 MINUS NUM_i0003 EOL" "NUM_i0001 NUM_i0002 ADD NUM_i0003 SUB PEND"
  call :_p "PRINT NUM_i0002 POW NUM_i0003 EOL"      "NUM_i0002 NUM_i0003 POW PEND"

call %test% "parse.expr.logical"
  call :_p "PRINT VAR_UNK_A AND VAR_UNK_B EOL"      "VAR_UNK_A VAR_UNK_B AND PEND"
  call :_p "PRINT VAR_UNK_A OR VAR_UNK_B EOL"       "VAR_UNK_A VAR_UNK_B OR PEND"
  call :_p "PRINT NOT VAR_UNK_A EOL"                "VAR_UNK_A NOT PEND"

call %test% "parse.comparison.all"
  call :_p "IF VAR_UNK_A EQ VAR_UNK_B THEN NUM_i000A EOL" "VAR_UNK_A VAR_UNK_B CMP_EQ IF NUM_i000A IF_GOTO ENDIF"
  call :_p "IF VAR_UNK_A NE VAR_UNK_B THEN NUM_i000A EOL" "VAR_UNK_A VAR_UNK_B CMP_NE IF NUM_i000A IF_GOTO ENDIF"
  call :_p "IF VAR_UNK_A LE VAR_UNK_B THEN NUM_i000A EOL" "VAR_UNK_A VAR_UNK_B CMP_LE IF NUM_i000A IF_GOTO ENDIF"
  call :_p "IF VAR_UNK_A GT VAR_UNK_B THEN NUM_i000A EOL" "VAR_UNK_A VAR_UNK_B CMP_GT IF NUM_i000A IF_GOTO ENDIF"

call %test% "parse.if.else"
  call :_p "IF VAR_UNK_A THEN NUM_i000A ELSE NUM_i0014 EOL" "VAR_UNK_A IF NUM_i000A IF_GOTO ELSE NUM_i0014 IF_GOTO ENDIF"

call %test% "parse.array.dim"
  call :_p "DIM VAR_UNK_A OPAR NUM_i0003 COMA NUM_i0004 CPAR EOL"                         "VAR_UNK_A ARR_START NUM_i0003 NUM_i0004 DIM"
  call :_p "DIM VAR_UNK_A OPAR VAR_UNK_N CPAR EOL"                                        "VAR_UNK_A ARR_START VAR_UNK_N DIM"
  call :_p "DIM VAR_UNK_A OPAR NUM_i0003 CPAR COMA VAR_UNK_B OPAR NUM_i0004 CPAR EOL"     "VAR_UNK_A ARR_START NUM_i0003 DIM VAR_UNK_B ARR_START NUM_i0004 DIM"

call %test% "parse.array.read"
  call :_p "PRINT VAR_UNK_A OPAR NUM_i0001 CPAR EOL"                  "VAR_UNK_A ARR_START NUM_i0001 AIDX PEND"
  call :_p "PRINT VAR_UNK_A OPAR NUM_i0001 COMA NUM_i0002 CPAR EOL"   "VAR_UNK_A ARR_START NUM_i0001 NUM_i0002 AIDX PEND"

call %test% "parse.array.write"
  call :_p "VAR_UNK_A OPAR NUM_i0001 CPAR EQ NUM_i0005 EOL"  "VAR_UNK_A ARR_START NUM_i0001 NUM_i0005 ASSIGN_ARR"
  call :_p "VAR_UNK_A OPAR NUM_i0001 COMA NUM_i0002 CPAR EQ NUM_i0063 EOL" "VAR_UNK_A ARR_START NUM_i0001 NUM_i0002 NUM_i0063 ASSIGN_ARR"

call %test% "parse.strings"
  call :_p "PRINT STR_48454C4C4F EOL"        "STR_48454C4C4F PEND"
  call :_p "VAR_STR_A EQ STR_4849 EOL"       "VAR_STR_A STR_4849 ASSIGN"

call %test% "parse.var.types"
  call :_p "VAR_INT_A EQ NUM_i0005 EOL"      "VAR_INT_A NUM_i0005 ASSIGN"
  call :_p "VAR_SNG_A EQ NUM_i0005 EOL"      "VAR_SNG_A NUM_i0005 ASSIGN"
  call :_p "VAR_DBL_A EQ NUM_i0005 EOL"      "VAR_DBL_A NUM_i0005 ASSIGN"
  call :_p "VAR_STR_A EQ STR_4849 EOL"       "VAR_STR_A STR_4849 ASSIGN"

call %test% "parse.while"
  call :_p "WHILE VAR_UNK_A LT NUM_i000A EOL" "VAR_UNK_A NUM_i000A CMP_LT WHILE"
  call :_p "WEND EOL"                          "WEND"

call %test% "parse.error"
  call :_pe "PLUS EOL"

call %test% "parse.print.juxtaposed"
  call :_p "PRINT STR_58 NUM_i0001 EOL" "STR_58 PSEMI NUM_i0001 PEND"
  call :_p "PRINT STR_58 VAR_UNK_A STR_59 EOL" "STR_58 PSEMI VAR_UNK_A PSEMI STR_59 PEND"
  call :_p "PRINT TAB( NUM_i0005 CPAR STR_58 EOL" "NUM_i0005 FN_TAB PSEMI STR_58 PEND"

call %test% "parse.print.zones"
  call :_p "PRINT COMA NUM_i0005 EOL" "PZONE NUM_i0005 PEND"
  call :_p "PRINT NUM_i0001 COMA COMA NUM_i0002 EOL" "NUM_i0001 PTAB PZONE NUM_i0002 PEND"
  call :_p "PRINT COMA COMA EOL" "PZONE PZONE"

call %test% "parse.run.statements"
  call :_p "RUN EOL" "RUN"
  call :_p "RUN NUM_i0064 EOL" "NUM_i0064 RUN_LINE"
  call :_p "RUN STR_4142 EOL" "STR_4142 RUN_FILE"
  call :_p "RUN STR_4142 COMA VAR_UNK_R EOL" "STR_4142 VAR_UNK_R RUN_ROPT RUN_FILE"
  call :_p "RUN VAR_STR_P EOL" "VAR_STR_P RUN_FILE"
  call :_p "SAVE STR_4142 EOL" "STR_4142 SAVE"
  call :_p "SAVE STR_4142 COMA VAR_UNK_A EOL" "STR_4142 VAR_UNK_A SAVE"
  call :_p "SYSTEM EOL" "SYSTEM"
  call :_p "NEW EOL" "NEW"
  call :_p "LPRINT NUM_i0001 EOL" "NUM_i0001 PEND"

call %test% "parse.input.prompt.forms"
  call :_p "INPUT STR_41 SEMICOLON VAR_STR_N EOL" "STR_41 PROMPT INPUT_MARK VAR_STR_N INPUT"
  call :_p "INPUT STR_41 COMA VAR_STR_N EOL" "STR_41 PROMPT_NQ INPUT_MARK VAR_STR_N INPUT"

call %test% "parse.locate.forms"
  call :_p "LOCATE NUM_i0017 COMA NUM_i0001 EOL" "LOC_MARK NUM_i0017 NUM_i0001 LOCATE"
  call :_p "LOCATE COMA NUM_i0034 EOL" "LOC_MARK LOC_NIL NUM_i0034 LOCATE"
  call :_p "LOCATE COMA COMA NUM_i0000 EOL" "LOC_MARK LOC_NIL LOC_NIL NUM_i0000 LOCATE"
  call :_p "LOCATE NUM_i0003 COMA NUM_i0001 COMA NUM_i0001 EOL" "LOC_MARK NUM_i0003 NUM_i0001 NUM_i0001 LOCATE"

call %test% "parse.key.string"
  call :_p "KEY OFF EOL" "KEY_OFF"
  call :_p "KEY ON EOL" "KEY_ON"
  call :_p "PRINT STRING$ OPAR NUM_i000A COMA NUM_i002A CPAR EOL" "NUM_i000A NUM_i002A FN_STRING PEND"

call %test% "parse.color.forms"
  call :_p "COLOR NUM_i0007 EOL" "COL_MARK NUM_i0007 COLOR"
  call :_p "COLOR NUM_i0007 COMA NUM_i0000 EOL" "COL_MARK NUM_i0007 NUM_i0000 COLOR"
  call :_p "COLOR NUM_i0007 COMA NUM_i0000 COMA NUM_i0000 EOL" "COL_MARK NUM_i0007 NUM_i0000 NUM_i0000 COLOR"
  call :_p "COLOR COMA NUM_i0007 EOL" "COL_MARK COL_NIL NUM_i0007 COLOR"

call %test% "parse.on.goto.gosub"
  call :_p "ON VAR_UNK_X GOTO NUM_i000A COMA NUM_i0014 EOL" "VAR_UNK_X ON_GOTO NUM_i000A NUM_i0014 ON_END"
  call :_p "ON VAR_UNK_X GOSUB NUM_i0064 EOL" "VAR_UNK_X ON_GOSUB NUM_i0064 ON_END"
  call :_p "ON VAR_UNK_A PLUS NUM_i0001 GOTO NUM_i000A EOL" "VAR_UNK_A NUM_i0001 ADD ON_GOTO NUM_i000A ON_END"

call %test% "parse.inkey"
  call :_p "PRINT INKEY$ EOL" "FN_INKEY PEND"
  call :_p "VAR_STR_A EQ INKEY$ EOL" "VAR_STR_A FN_INKEY ASSIGN"

call %test% "parse.print.using"
  call :_p "PRINT USING STR_232323 SEMICOLON NUM_i002A EOL" "STR_232323 PU_MARK NUM_i002A PRINT_USING PU_NL"
  call :_p "PRINT USING STR_232323 SEMICOLON NUM_i002A SEMICOLON EOL" "STR_232323 PU_MARK NUM_i002A PRINT_USING"
  call :_p "PRINT USING STR_2323 SEMICOLON VAR_UNK_X COMA VAR_UNK_Y EOL" "STR_2323 PU_MARK VAR_UNK_X VAR_UNK_Y PRINT_USING PU_NL"
  call :_p "LPRINT USING STR_2323 SEMICOLON VAR_UNK_X EOL" "STR_2323 PU_MARK VAR_UNK_X PRINT_USING PU_NL"

exit /B

:_p
  set /a numTests+=1
  call parse parse "%~1" __
  set "_e=%ERRORLEVEL%"
  if "%__%"=="%~2" (
    set /a passedTests+=1
  ) else (
    echo FAILED: parse "%~1"
    echo   Expected: %~2
    echo        Got: %__%  err=%_e%
    echo.
    set /a failedTests+=1
  )
  exit /B

:_pe
  set /a numTests+=1
  call parse parse "%~1" __ 2>nul
  if "%ERRORLEVEL%"=="2" (
    set /a passedTests+=1
  ) else (
    echo FAILED: expected parse error for "%~1"
    echo.
    set /a failedTests+=1
  )
  exit /B
