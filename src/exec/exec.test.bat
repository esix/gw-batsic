@REM Executor tests
@REM Each test: encode → lex → parse → execute, check output

call %test% "exec.calc.add"
  call :_run "PRINT 1+2" " 3"

call %test% "exec.calc.mul"
  call :_run "PRINT 3*4+5" " 17"

call %test% "exec.calc.sub"
  call :_run "PRINT 100-37" " 63"

call %test% "exec.calc.div"
  call :_run "PRINT 10/3" " 3"

call %test% "exec.calc.neg"
  call :_run "PRINT -42" " -42"

call %test% "exec.calc.parens"
  call :_run "PRINT (2+3)*4" " 20"

call %test% "exec.vars.assign"
  @REM Init vars, assign, then print
  @REM Default type is single, so 10 is stored as sng and displayed as 10.
  call %GWSRC%\exec\_vars init
  call :_exec "VAR_UNK_A NUM_i000A ASSIGN"
  call :_run "PRINT A" " 10"

call %test% "exec.vars.assign.int"
  @REM Explicit integer variable — use postfix directly (% can't go through str encode)
  call %GWSRC%\exec\_vars init
  call :_exec "VAR_INT_A NUM_i000A ASSIGN"
  call :_rexec "VAR_INT_A PEND" " 10"

call %test% "exec.vars.namespace"
  @REM I and I! are the same var (default single)
  @REM I% is a different var
  call %GWSRC%\exec\_vars init
  call :_exec "VAR_UNK_I NUM_i0005 ASSIGN"
  call :_exec "VAR_INT_I NUM_i0063 ASSIGN"
  @REM I! should be 5 (stored as single)
  @REM I% should be 99

call %test% "exec.vars.expr"
  @REM Use explicit integer vars for clean output
  call %GWSRC%\exec\_vars init
  call %GWSRC%\exec\_vars defrange A Z i
  call :_exec "VAR_UNK_X NUM_i0005 ASSIGN"
  call :_run "PRINT X+1" " 6"

call %test% "exec.vars.typeof"
  call %GWSRC%\exec\_vars init
  call expect "%GWSRC%\exec\_vars typeof VAR_UNK_A __" "s"
  call expect "%GWSRC%\exec\_vars typeof VAR_INT_A __" "i"
  call expect "%GWSRC%\exec\_vars typeof VAR_STR_A __" "t"

call %test% "exec.vars.defrange"
  call %GWSRC%\exec\_vars init
  call %GWSRC%\exec\_vars defrange A M i
  call expect "%GWSRC%\exec\_vars typeof VAR_UNK_A __" "i"
  call expect "%GWSRC%\exec\_vars typeof VAR_UNK_N __" "s"

exit /B


@REM Helper: full pipeline — encode, lex, parse, execute, capture output
:_run
  set /a numTests+=1
  setlocal EnableDelayedExpansion
  call %GWSRC%\str\str encode "%~1" _hex
  call %GWSRC%\lexer\lexer ParseTxt !_hex! _tokens
  @REM Strip LN__ if present
  set "_first="
  for /f "tokens=1*" %%a in ("!_tokens!") do (
    set "_first=%%a"
    set "_rest=%%b"
  )
  if "!_first:~0,4!"=="LN__" set "_tokens=!_rest!"
  call %GWSRC%\parser\parse parse "!_tokens!" _postfix
  if errorlevel 1 (
    echo FAILED: parse error for "%~1"
    echo.
    endlocal & set /a failedTests+=1
    exit /B
  )
  @REM Capture exec output
  call %GWSRC%\exec\exec run "!_postfix!" > "%GWTEMP%\_test.out" 2>&1
  set /p "_got=" < "%GWTEMP%\_test.out"
  if "!_got!"=="%~2" (
    endlocal & set /a passedTests+=1
  ) else (
    echo FAILED: "%~1"
    echo   Expected: %~2
    echo        Got: !_got!
    echo.
    endlocal & set /a failedTests+=1
  )
  exit /B

@REM Helper: execute postfix directly and check output
:_rexec
  set /a numTests+=1
  setlocal EnableDelayedExpansion
  call %GWSRC%\exec\exec run "%~1" > "%GWTEMP%\_test.out" 2>&1
  set /p "_got=" < "%GWTEMP%\_test.out"
  if "!_got!"=="%~2" (
    endlocal & set /a passedTests+=1
  ) else (
    echo FAILED: exec "%~1"
    echo   Expected: %~2
    echo        Got: !_got!
    echo.
    endlocal & set /a failedTests+=1
  )
  exit /B

@REM Helper: execute postfix directly (for setup like assignments)
:_exec
  setlocal EnableDelayedExpansion
  call %GWSRC%\exec\exec run "%~1"
  endlocal
  exit /B
