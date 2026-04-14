@echo off
@REM LL(1) table-driven parser
@REM
@REM Input: space-separated token stream (from lexer, no LN__ prefix)
@REM Output: (for now) trace of rule applications
@REM
@REM Usage:
@REM   call parse "PRINT NUM_i0064 PLUS NUM_i00C8 EOL"
@REM   call parse parse "PRINT NUM_i0064 PLUS NUM_i00C8 EOL" __

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


@REM === Main parse function ===
@REM Input: %~1 = token stream (space-separated)
@REM        %~2 = output variable name (optional, prints to stdout if empty)
:parse
  setlocal EnableDelayedExpansion
  set "_input=%~1"
  set "_stack=StmtList $"
  set "_output="
  set "_err="

  @REM Get first token and classify
  for /f "tokens=1*" %%a in ("!_input!") do (
    set "_tok=%%a"
    set "_rest=%%b"
  )
  goto :_classify

@REM === Classify _tok -> _term (inline, no call :label) ===
:_classify
  if "!_tok:~0,4!"=="NUM_" (set "_term=NUM" & goto :_parse_loop)
  if "!_tok:~0,4!"=="VAR_" (set "_term=VAR" & goto :_parse_loop)
  if "!_tok:~0,4!"=="STR_" (set "_term=STR" & goto :_parse_loop)
  if "!_tok:~0,4!"=="REM_" (set "_term=REM_TEXT" & goto :_parse_loop)
  if "!_tok:~0,4!"=="HEX_" (set "_term=NUM" & goto :_parse_loop)
  if "!_tok:~0,4!"=="OCT_" (set "_term=NUM" & goto :_parse_loop)
  if "!_tok!"=="EOL" (set "_term=$" & goto :_parse_loop)
  set "_term=!_tok!"
  goto :_parse_loop

:_parse_loop
  @REM Get stack top
  for /f "tokens=1*" %%a in ("!_stack!") do (
    set "_top=%%a"
    set "_stail=%%b"
  )

  @REM Action marker: emit to output, don't consume input
  set "_tc=!_top:~0,1!"
  if "!_tc!"=="@" (
    set "_output=!_output! !_top:~1!"
    set "_stack=!_stail!"
    goto :_parse_loop
  )

  @REM Done: stack=$, input=$
  if "!_top!"=="$" if "!_term!"=="$" goto :_parse_ok

  @REM Error: stack=$ but input not done (or vice versa)
  if "!_top!"=="$" (set "_err=Unexpected token: !_tok!" & goto :_parse_err)
  if "!_term!"=="$" if "!_top!" neq "$" (
    @REM Check if top is nullable — look up epsilon rule
    call _table lookup !_top! $ _rule
    if errorlevel 1 (set "_err=Unexpected end, expected !_top!" & goto :_parse_err)
    @REM Pop and use epsilon rule
    set "_stack=!_stail!"
    call _table rule !_rule! _rhs
    for /f "tokens=1*" %%a in ("!_rhs!") do set "_rhs=%%b"
    if "!_rhs!" neq "e" (
      @REM Push RHS onto stack (already space-separated)
      set "_stack=!_rhs! !_stail!"
    )
    goto :_parse_loop
  )

  @REM Terminal match: top == current token class
  if "!_top!"=="!_term!" (
    @REM Emit the actual token (with value)
    set "_output=!_output! !_tok!"
    @REM Pop stack
    set "_stack=!_stail!"
    @REM Advance input
    if defined _rest (
      for /f "tokens=1*" %%a in ("!_rest!") do (
        set "_tok=%%a"
        set "_rest=%%b"
      )
    ) else (
      set "_tok=$"
    )
    goto :_classify
  )

  @REM Nonterminal: look up table
  call _table lookup !_top! !_term! _rule
  if errorlevel 1 (
    set "_err=No rule for !_top! with token !_tok! (!_term!)"
    goto :_parse_err
  )

  @REM Get rule RHS
  call _table rule !_rule! _rhs
  for /f "tokens=1*" %%a in ("!_rhs!") do set "_rhs=%%b"

  @REM Pop nonterminal, push RHS (unless epsilon)
  if "!_rhs!"=="e" (
    set "_stack=!_stail!"
  ) else (
    set "_stack=!_rhs! !_stail!"
  )
  goto :_parse_loop

:_parse_ok
  set "_r=!_output:~1!"
  endlocal & (
    if "%~2"=="" (echo %_r%) else (set "%~2=%_r%")
  )
  exit /B 0

:_parse_err
  echo PARSE ERROR: !_err! 1>&2
  echo   Token: !_tok! Stack top: !_top! 1>&2
  endlocal
  exit /B 1


:_start
  setlocal EnableDelayedExpansion
  set "PATH=%~dp0;%~dp0..\stl;%PATH%"
  call _table loadCache "%~dp0_table.dat"
  if errorlevel 1 (echo _table.dat not found. Run _rebuild.bat & exit /B 1)

  echo --- PRINT 1+2 ---
  call :parse "PRINT NUM_i0001 PLUS NUM_i0002 EOL"
  echo.
  echo --- PRINT 1+2*3 ---
  call :parse "PRINT NUM_i0001 PLUS NUM_i0002 MUL NUM_i0003 EOL"
  echo.
  echo --- PRINT A;B,C;1+2 ---
  call :parse "PRINT VAR_UNK_A SEMICOLON VAR_UNK_B COMA VAR_UNK_C SEMICOLON NUM_i0001 PLUS NUM_i0002 EOL"
  echo.
  echo --- A=1+2 ---
  call :parse "VAR_UNK_A EQ NUM_i0001 PLUS NUM_i0002 EOL"
  echo.
  echo --- PRINT -1*2 ---
  call :parse "PRINT MINUS NUM_i0001 MUL NUM_i0002 EOL"
  echo.
  echo --- GOTO 100 ---
  call :parse "GOTO NUM_i0064 EOL"
  echo.
  echo --- IF A THEN 100 ---
  call :parse "IF VAR_UNK_A THEN NUM_i0064 EOL"
  echo.
  echo --- FOR I=1 TO 10 STEP 2 ---
  call :parse "FOR VAR_UNK_I EQ NUM_i0001 TO NUM_i000A STEP NUM_i0002 EOL"
  echo.
  echo --- PRINT ABS(X) ---
  call :parse "PRINT ABS OPAR VAR_UNK_X CPAR EOL"
  echo.
  echo --- PRINT LEFT$(A$,3) ---
  call :parse "PRINT LEFT$ OPAR VAR_STR_A COMA NUM_i0003 CPAR EOL"

  endlocal
