
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
  call :_p "FOR VAR_UNK_I EQ NUM_i0001 TO NUM_i000A EOL" "VAR_UNK_I NUM_i0001 NUM_i000A FOR"
  call :_p "FOR VAR_UNK_I EQ NUM_i0001 TO NUM_i000A STEP NUM_i0002 EOL" "VAR_UNK_I NUM_i0001 NUM_i000A NUM_i0002 FOR"
  call :_p "NEXT VAR_UNK_I EOL" "VAR_UNK_I NEXT"
  call :_p "NEXT EOL" "NEXT"

call %test% "parse.dim"
  call :_p "DIM VAR_UNK_A OPAR NUM_i000A CPAR EOL" "VAR_UNK_A NUM_i000A DIM"

call %test% "parse.rem"
  call :_p "REM REM_48454C4C4F EOL" "REM_48454C4C4F REM"

call %test% "parse.functions"
  call :_p "PRINT ABS OPAR VAR_UNK_X CPAR EOL" "VAR_UNK_X FN_ABS PEND"
  call :_p "PRINT LEN OPAR VAR_STR_A CPAR EOL" "VAR_STR_A FN_LEN PEND"
  call :_p "PRINT LEFT$ OPAR VAR_STR_A COMA NUM_i0003 CPAR EOL" "VAR_STR_A NUM_i0003 FN_LEFT PEND"

call %test% "parse.colon"
  call :_p "CLS COLON BEEP EOL" "CLS BEEP"

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
  if "%ERRORLEVEL%"=="2" (
    set /a passedTests+=1
  ) else (
    echo FAILED: expected parse error for "%~1"
    echo.
    set /a failedTests+=1
  )
  exit /B
