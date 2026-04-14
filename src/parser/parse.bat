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
    @REM Only emit value tokens (NUM_, VAR_, STR_, REM_), skip structural noise
    set "_tp=!_tok:~0,4!"
    if "!_tp!"=="NUM_" set "_output=!_output! !_tok!"
    if "!_tp!"=="VAR_" set "_output=!_output! !_tok!"
    if "!_tp!"=="STR_" set "_output=!_output! !_tok!"
    if "!_tp!"=="REM_" set "_output=!_output! !_tok!"
    if "!_tp!"=="HEX_" set "_output=!_output! !_tok!"
    if "!_tp!"=="OCT_" set "_output=!_output! !_tok!"
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
  echo Syntax error: !_err! 1>&2
  endlocal
  exit /B 2


:_start
  if not defined GWSRC set "GWSRC=%~dp0.."
  set "PATH=%~dp0;%~dp0..\stl;%GWSRC%\num;%PATH%"
  call _table loadCache "%~dp0_table.dat"
  if errorlevel 1 (echo _table.dat not found. Run _rebuild.bat & exit /B 1)
  call %GWSRC%\lexer\keyword init
  echo GW-BASIC Parser. Enter a line to parse. Empty line to quit.
:_repl
  call %GWSRC%\str\str input "> " _hex
  if errorlevel 1 goto :_repl_end
  setlocal EnableDelayedExpansion
  @REM Run lexer
  call %GWSRC%\lexer\lexer ParseTxt !_hex! _tokens
  @REM Strip LN__ token if present
  set "_first="
  for /f "tokens=1*" %%a in ("!_tokens!") do (
    set "_first=%%a"
    set "_rest=%%b"
  )
  if "!_first:~0,4!"=="LN__" (
    echo [line !_first:~4!]
    set "_tokens=!_rest!"
  ) else (
    set "_tokens=!_tokens!"
  )
  @REM Run parser
  set "_result="
  call :parse "!_tokens!" _result
  if not errorlevel 1 (
    if defined _result echo !_result!
  ) else (
    echo Error !ERRORLEVEL! 1>&2
  )
  set "_result="
  endlocal
  goto :_repl
:_repl_end
