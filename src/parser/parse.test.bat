
@REM Parser tests — verify postfix output with @actions

call %test% "parse.simple"
  call :_p "END EOL" "END END"
  call :_p "STOP EOL" "STOP STOP"
  call :_p "CLS EOL" "CLS CLS"
  call :_p "BEEP EOL" "BEEP BEEP"
  call :_p "RETURN EOL" "RETURN RETURN"

call %test% "parse.print"
  call :_p "PRINT NUM_i0064 EOL" "PRINT NUM_i0064 PEND"
  call :_p "PRINT VAR_UNK_A SEMICOLON VAR_UNK_B EOL" "PRINT VAR_UNK_A SEMICOLON PSEMI VAR_UNK_B PEND"
  call :_p "PRINT VAR_UNK_A COMA VAR_UNK_B EOL" "PRINT VAR_UNK_A COMA PTAB VAR_UNK_B PEND"

call %test% "parse.assignment"
  call :_p "VAR_UNK_A EQ NUM_i0001 EOL" "VAR_UNK_A EQ NUM_i0001 ASSIGN"
  call :_p "LET VAR_UNK_A EQ NUM_i0001 EOL" "LET VAR_UNK_A EQ NUM_i0001 ASSIGN"

call %test% "parse.expr.arith"
  call :_p "PRINT NUM_i0001 PLUS NUM_i0002 EOL" "PRINT NUM_i0001 PLUS NUM_i0002 ADD PEND"
  call :_p "PRINT NUM_i0001 PLUS NUM_i0002 MUL NUM_i0003 EOL" "PRINT NUM_i0001 PLUS NUM_i0002 MUL NUM_i0003 MUL ADD PEND"
  call :_p "PRINT MINUS NUM_i0001 EOL" "PRINT MINUS NUM_i0001 NEG PEND"

call %test% "parse.goto"
  call :_p "GOTO NUM_i0064 EOL" "GOTO NUM_i0064 GOTO"
  call :_p "GOSUB NUM_i0064 EOL" "GOSUB NUM_i0064 GOSUB"

call %test% "parse.if"
  call :_p "IF VAR_UNK_A THEN NUM_i0064 EOL" "IF VAR_UNK_A IF THEN NUM_i0064 IF_GOTO ENDIF"
  call :_p "IF VAR_UNK_A THEN GOTO NUM_i0064 EOL" "IF VAR_UNK_A IF THEN GOTO NUM_i0064 GOTO ENDIF"

call %test% "parse.for"
  call :_p "FOR VAR_UNK_I EQ NUM_i0001 TO NUM_i000A EOL" "FOR VAR_UNK_I EQ NUM_i0001 TO NUM_i000A FOR"
  call :_p "NEXT VAR_UNK_I EOL" "NEXT VAR_UNK_I NEXT"
  call :_p "NEXT EOL" "NEXT NEXT"

call %test% "parse.dim"
  call :_p "DIM VAR_UNK_A OPAR NUM_i000A CPAR EOL" "DIM VAR_UNK_A OPAR NUM_i000A CPAR DIM"

call %test% "parse.rem"
  call :_p "REM REM_48454C4C4F EOL" "REM REM_48454C4C4F REM"

call %test% "parse.functions"
  call :_p "PRINT ABS OPAR VAR_UNK_X CPAR EOL" "PRINT ABS OPAR VAR_UNK_X CPAR FN_ABS PEND"
  call :_p "PRINT LEN OPAR VAR_STR_A CPAR EOL" "PRINT LEN OPAR VAR_STR_A CPAR FN_LEN PEND"

call %test% "parse.colon"
  call :_p "CLS COLON BEEP EOL" "CLS CLS COLON BEEP BEEP"

call %test% "parse.error"
  call :_pe "PLUS EOL"

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
  if errorlevel 1 (
    set /a passedTests+=1
  ) else (
    echo FAILED: expected parse error for "%~1"
    echo.
    set /a failedTests+=1
  )
  exit /B
