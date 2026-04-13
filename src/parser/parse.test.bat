
@REM Parser tests use helper :_p to avoid quoting issues
@REM :_p sets _in, calls parse, checks __

call %test% "parse.simple"
  call :_p "PRINT NUM_i0064 EOL" "PRINT NUM_i0064"
  call :_p "END EOL" "END"
  call :_p "STOP EOL" "STOP"
  call :_p "CLS EOL" "CLS"
  call :_p "BEEP EOL" "BEEP"

call %test% "parse.assignment"
  call :_p "VAR_UNK_A EQ NUM_i0001 EOL" "VAR_UNK_A EQ NUM_i0001"
  call :_p "LET VAR_UNK_A EQ NUM_i0001 EOL" "LET VAR_UNK_A EQ NUM_i0001"

call %test% "parse.expr"
  call :_p "PRINT NUM_i0001 PLUS NUM_i0002 EOL" "PRINT NUM_i0001 PLUS NUM_i0002"
  call :_p "PRINT NUM_i0002 MUL NUM_i0003 EOL" "PRINT NUM_i0002 MUL NUM_i0003"
  call :_p "PRINT NUM_i0001 PLUS NUM_i0002 MUL NUM_i0003 EOL" "PRINT NUM_i0001 PLUS NUM_i0002 MUL NUM_i0003"
  call :_p "PRINT OPAR NUM_i0001 PLUS NUM_i0002 CPAR MUL NUM_i0003 EOL" "PRINT OPAR NUM_i0001 PLUS NUM_i0002 CPAR MUL NUM_i0003"
  call :_p "PRINT MINUS NUM_i0001 EOL" "PRINT MINUS NUM_i0001"

call %test% "parse.goto"
  call :_p "GOTO NUM_i0064 EOL" "GOTO NUM_i0064"
  call :_p "GOSUB NUM_i00C8 EOL" "GOSUB NUM_i00C8"

call %test% "parse.if"
  call :_p "IF VAR_UNK_A THEN NUM_i0064 EOL" "IF VAR_UNK_A THEN NUM_i0064"
  call :_p "IF VAR_UNK_A THEN GOTO NUM_i0064 EOL" "IF VAR_UNK_A THEN GOTO NUM_i0064"

call %test% "parse.for"
  call :_p "FOR VAR_UNK_I EQ NUM_i0001 TO NUM_i000A EOL" "FOR VAR_UNK_I EQ NUM_i0001 TO NUM_i000A"
  call :_p "FOR VAR_UNK_I EQ NUM_i0001 TO NUM_i000A STEP NUM_i0002 EOL" "FOR VAR_UNK_I EQ NUM_i0001 TO NUM_i000A STEP NUM_i0002"

call %test% "parse.next"
  call :_p "NEXT VAR_UNK_I EOL" "NEXT VAR_UNK_I"
  call :_p "NEXT EOL" "NEXT"

call %test% "parse.dim"
  call :_p "DIM VAR_UNK_A OPAR NUM_i000A CPAR EOL" "DIM VAR_UNK_A OPAR NUM_i000A CPAR"

call %test% "parse.rem"
  call :_p "REM REM_48454C4C4F EOL" "REM REM_48454C4C4F"

call %test% "parse.colon"
  call :_p "CLS COLON BEEP EOL" "CLS COLON BEEP"

call %test% "parse.print.multi"
  call :_p "PRINT VAR_UNK_A SEMICOLON VAR_UNK_B EOL" "PRINT VAR_UNK_A SEMICOLON VAR_UNK_B"
  call :_p "PRINT VAR_UNK_A COMA VAR_UNK_B EOL" "PRINT VAR_UNK_A COMA VAR_UNK_B"

call %test% "parse.comparison"
  call :_p "IF VAR_UNK_A LT NUM_i0001 THEN END EOL" "IF VAR_UNK_A LT NUM_i0001 THEN END"

call %test% "parse.functions"
  call :_p "PRINT ABS OPAR MINUS NUM_i0001 CPAR EOL" "PRINT ABS OPAR MINUS NUM_i0001 CPAR"
  call :_p "PRINT LEN OPAR VAR_STR_A CPAR EOL" "PRINT LEN OPAR VAR_STR_A CPAR"

exit /B

@REM Helper: parse and check result (no setlocal — counters must propagate)
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
