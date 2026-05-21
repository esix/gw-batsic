@echo off
@REM Postfix executor — stack machine for GW-BASIC
@REM
@REM Input: postfix token stream (from parser)
@REM Walks tokens left to right:
@REM   NUM_*/VAR_*/STR_* → push value onto stack
@REM   anything else     → call RTL action (src/rtl/ACTION.bat)
@REM
@REM Stack is a space-separated env var (_stk), managed via stl/vec.

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:run
  setlocal EnableDelayedExpansion
  set "_postfix=%~1"
  set "_stk="
  set "_err=0"
  @REM Skip state for IF/ELSE/ENDIF control flow within one line.
  @REM   _skipMode = "ELSE_OR_ENDIF"  (set by IF when condition is false)
  @REM             = "ENDIF"          (set by ELSE after THEN body executed)
  @REM   _skipDepth tracks nested IFs encountered while skipping.
  set "_skipMode="
  set "_skipDepth=0"
  @REM _cur_line is set by the caller (RUN loop sets it per line; REPL sets 65535)
  if not defined _cur_line set "_cur_line=65535"

:_run_loop
  if not defined _postfix goto :_run_end
  if "!_postfix!"=="" goto :_run_end
  if !_err! neq 0 goto :_run_end
  for /f "tokens=1*" %%a in ("!_postfix!") do (
    set "_tok=%%a"
    set "_postfix=%%b"
  )

  @REM ---- Skip mode: scan forward to matching ELSE / ENDIF ----
  if defined _skipMode (
    if "!_tok!"=="IF" (
      set /a "_skipDepth+=1"
      goto :_run_loop
    )
    if "!_tok!"=="ENDIF" (
      if !_skipDepth! GTR 0 (
        set /a "_skipDepth-=1"
        goto :_run_loop
      )
      set "_skipMode="
      goto :_run_loop
    )
    if "!_tok!"=="ELSE" (
      if !_skipDepth! GTR 0 goto :_run_loop
      if "!_skipMode!"=="ELSE_OR_ENDIF" set "_skipMode="
      goto :_run_loop
    )
    goto :_run_loop
  )

  @REM ---- Normal mode ----
  set "_tp=!_tok:~0,4!"
  if "!_tp!"=="NUM_" (
    call %GWSRC%\stl\vec push _stk !_tok:~4!
    goto :_run_loop
  )
  if "!_tp!"=="VAR_" (
    @REM TODO: look up variable value
    call %GWSRC%\stl\vec push _stk !_tok!
    goto :_run_loop
  )
  if "!_tp!"=="STR_" (
    call %GWSRC%\stl\vec push _stk !_tok!
    goto :_run_loop
  )
  if "!_tp!"=="REM_" (
    @REM Comment: ignore
    goto :_run_loop
  )

  @REM IF / ELSE / ENDIF / IF_GOTO are control-flow markers handled inline.
  if "!_tok!"=="IF" (
    @REM Pop condition; falsy → skip to ELSE or ENDIF.
    call %GWSRC%\stl\vec pop _stk _cond
    call %GWSRC%\exec\_resolve !_cond! _cond
    call :_isTruthy !_cond! _t
    if "!_t!"=="0" (
      set "_skipMode=ELSE_OR_ENDIF"
      set "_skipDepth=0"
    )
    goto :_run_loop
  )
  if "!_tok!"=="ELSE" (
    @REM Reached naturally after THEN body — skip to ENDIF.
    set "_skipMode=ENDIF"
    set "_skipDepth=0"
    goto :_run_loop
  )
  if "!_tok!"=="ENDIF" (
    goto :_run_loop
  )
  if "!_tok!"=="IF_GOTO" (
    @REM Pop line number, set _next_line — same as GOTO.
    call %GWSRC%\stl\vec pop _stk _t
    call %GWSRC%\exec\_resolve !_t! _t
    set "_tt=!_t:~0,1!"
    if "!_tt!"=="i" call %GWSRC%\num\int toDec !_t!
    if "!_tt!"=="s" call %GWSRC%\num\sng toDec !_t!
    if "!_tt!"=="d" call %GWSRC%\num\dbl toDec !_t!
    set "_next_line=!__!"
    goto :_run_loop
  )

  @REM Action: call RTL handler
  if exist "%GWSRC%\rtl\!_tok!.bat" (
    call %GWSRC%\rtl\!_tok!.bat _stk
    set "_err=!ERRORLEVEL!"
    goto :_run_loop
  )
  @REM Unimplemented in this build → "Advanced Feature" (code 73).
  echo RTL: unknown action !_tok! 1>&2
  set "_err=73"
  goto :_run_loop

:_run_end
  @REM On real error, capture ERR / ERL.  Code 99 is the END/STOP flow-control
  @REM signal — not a user-visible error, so don't surface it via ERR.
  if !_err! neq 0 if !_err! neq 99 (
    set "_err_code=!_err!"
    set "_err_line=!_cur_line!"
  )

  @REM Propagate flow-control + error state back to caller
  endlocal ^
    & set "_next_line=%_next_line%" ^
    & set "_gosub_stack=%_gosub_stack%" ^
    & set "_for_vars=%_for_vars%" ^
    & set "_for_limits=%_for_limits%" ^
    & set "_for_steps=%_for_steps%" ^
    & set "_for_lines=%_for_lines%" ^
    & set "_while_stack=%_while_stack%" ^
    & set "_err_code=%_err_code%" ^
    & set "_err_line=%_err_line%" ^
    & exit /B %_err%


@REM --- _isTruthy VALUE retVar: 1 if numeric value is non-zero, else 0 ---
@REM Used by IF.  STR is treated as truthy if non-empty (GW-BASIC actually
@REM rejects this as Type Mismatch, but we mirror the int-or-real cases.)
:_isTruthy
  setlocal EnableDelayedExpansion
  set "_v=%~1"
  set "_t=!_v:~0,1!"
  set "_r=0"
  if "!_t!"=="i" if not "!_v:~1!"=="0000" set "_r=1"
  if "!_t!"=="s" if not "!_v:~1!"=="00000000" set "_r=1"
  if "!_t!"=="d" if not "!_v:~1!"=="0000000000000000" set "_r=1"
  endlocal & set "%~2=%_r%" & exit /B 0


@REM --- runProgram: execute the stored program from lowest line number ---
@REM Iterates lines via _next_line; RTLs (GOTO/GOSUB/RETURN) override it.
:runProgram
  setlocal EnableDelayedExpansion
  set "_gosub_stack="
  @REM FOR loop stacks: parallel — same depth, popped together.
  set "_for_vars="
  set "_for_limits="
  set "_for_steps="
  set "_for_lines="
  @REM WHILE loop stack: just line numbers (re-evaluate cond on each iteration).
  set "_while_stack="
  @REM RUN clears error state
  set "_err_code=0"
  set "_err_line=0"
  @REM Find the lowest line number from sorted program.dat
  set "_first="
  for /f "usebackq tokens=1 delims= " %%k in (`sort "%GWTEMP%\program.dat"`) do (
    if not defined _first set "_first=%%k"
  )
  if not defined _first goto :_runProg_done
  call :_keyToLn !_first! _next_line

:_runProg_loop
  if not defined _next_line goto :_runProg_done
  if "!_next_line!"=="" goto :_runProg_done
  call %GWSRC%\exec\_program get !_next_line! _line_tokens
  if not defined _line_tokens (
    @REM "Undefined line number" — error code 8.  Reported against the line
    @REM that issued the jump (still in _cur_line from the previous iteration);
    @REM in direct mode it's 65535.
    set "_err_code=8"
    if not defined _cur_line set "_cur_line=65535"
    set "_err_line=!_cur_line!"
    goto :_runProg_done
  )
  @REM Strip leading LN__nnn token
  for /f "tokens=1*" %%a in ("!_line_tokens!") do set "_line_tokens=%%b"
  @REM Set current line number (for ERL on error)
  set "_cur_line=!_next_line!"
  @REM Compute the natural-next line (smallest key > current); RTLs may override
  call :_naturalNext !_next_line! _next_line
  call %GWSRC%\parser\parse parse "!_line_tokens!" _postfix
  if errorlevel 1 (
    @REM Parser failure → Syntax error (code 2) at this line
    set "_err_code=2"
    set "_err_line=!_cur_line!"
    goto :_runProg_done
  )
  call :run "!_postfix!"
  set "_e=!ERRORLEVEL!"
  if !_e! neq 0 (
    if !_e! equ 99 (
      @REM END / STOP — graceful halt, no error
      set "_err_code=0"
      goto :_runProg_done
    )
    goto :_runProg_done
  )
  goto :_runProg_loop

:_runProg_done
  @REM Print canonical error message if a real error halted the run.
  if !_err_code! neq 0 call :_printErr !_err_code! !_err_line!
  @REM Propagate error state to caller (so ERR / ERL can be read in REPL after RUN)
  endlocal & set "_err_code=%_err_code%" & set "_err_line=%_err_line%" & exit /B 0


@REM --- _printErr CODE LINE: print GW-BASIC-style error message ---
@REM   "<Message>"             when LINE is 65535 (direct mode) or empty
@REM   "<Message> in <LINE>"   when LINE is a program line
@REM Message text comes from src/gwerror.bat (Appendix A from the GW-BASIC
@REM manual).  If the code is unknown, prints "Unprintable error".
:_printErr
  setlocal EnableDelayedExpansion
  set "_c=%~1"
  set "_l=%~2"
  set "_msg="
  call %GWSRC%\gwerror ErrorCodeToString !_c! _msg
  if not defined _msg set "_msg=Unprintable error"
  if "!_l!"=="" set "_l=65535"
  if "!_l!"=="65535" (
    echo !_msg!
  ) else (
    echo !_msg! in !_l!
  )
  endlocal & exit /B 0


@REM --- _keyToLn KEY retVar: convert "00010" to "10" (strip leading zeros) ---
:_keyToLn
  setlocal EnableDelayedExpansion
  set "_k=%~1"
:_kln_strip
  if "!_k:~0,1!"=="0" if not "!_k:~1!"=="" (set "_k=!_k:~1!" & goto :_kln_strip)
  endlocal & set "%~2=%_k%" & exit /B 0


@REM --- _naturalNext CUR retVar: find smallest line > CUR (or empty) ---
:_naturalNext
  setlocal EnableDelayedExpansion
  set "_pad=00000%~1"
  set "_pad=!_pad:~-5!"
  set "_found="
  set "_natural="
  for /f "usebackq tokens=1 delims= " %%k in (`sort "%GWTEMP%\program.dat"`) do (
    if defined _found if not defined _natural set "_natural=%%k"
    if "%%k"=="!_pad!" set "_found=1"
  )
  if defined _natural (
    call :_keyToLn !_natural! _r
  ) else (
    set "_r="
  )
  endlocal & set "%~2=%_r%" & exit /B 0


:_start
  if not defined GWSRC set "GWSRC=%~dp0.."
  if not defined GWTEMP set "GWTEMP=%~dp0..\..\temp"
  @REM Parser needs _table on PATH for internal lookups
  set "PATH=%GWSRC%\parser;%PATH%"
  call %GWSRC%\lexer\keyword init
  call %GWSRC%\parser\_table loadCache "%GWSRC%\parser\_table.dat"
  call %GWSRC%\exec\_vars init
  @REM Error state: ERR / ERL accessible via _resolve's pseudo-vars
  set "_err_code=0"
  set "_err_line=0"

  echo GW-BASIC 3.23
  echo (C) Copyright Microsoft 1983,1984,1985,1986,1987,1988
  echo Ok
:_repl
  call %GWSRC%\str\str input "" _hex
  @REM Empty line: just re-prompt (no Ok)
  if errorlevel 1 goto :_repl
  setlocal EnableDelayedExpansion
  @REM Lexer
  call %GWSRC%\lexer\lexer ParseTxt !_hex! _tokens
  set "_first="
  set "_rest="
  for /f "tokens=1*" %%a in ("!_tokens!") do (
    set "_first=%%a"
    set "_rest=%%b"
  )
  @REM Program line entry: first token is LN__nnn — store (or delete if empty). Silent.
  if "!_first:~0,4!"=="LN__" (
    set "_lineno=!_first:~4!"
    if "!_rest!"=="EOL" (
      call %GWSRC%\exec\_program del !_lineno!
    ) else (
      call %GWSRC%\exec\_program add !_lineno! "!_tokens!"
    )
    endlocal
    goto :_repl
  )
  @REM SYSTEM: exit interpreter, no Ok.
  if "!_first!"=="SYSTEM" (
    endlocal
    goto :_repl_end
  )
  @REM Direct commands and immediate-mode statements both print Ok when done.
  if "!_first!"=="LIST" (
    call %GWSRC%\exec\_program list
    endlocal
    echo Ok
    goto :_repl
  )
  if "!_first!"=="RUN" (
    call :runProgram
    endlocal
    echo Ok
    goto :_repl
  )
  if "!_first!"=="LOAD" (
    call :_replFile load "!_tokens!"
    endlocal
    echo Ok
    goto :_repl
  )
  if "!_first!"=="SAVE" (
    call :_replFile save "!_tokens!"
    endlocal
    echo Ok
    goto :_repl
  )
  @REM Immediate mode: parse and execute. Line number for ERL is 65535.
  set "_cur_line=65535"
  call %GWSRC%\parser\parse parse "!_tokens!" _postfix
  if errorlevel 1 (
    @REM Parser failure → Syntax error (code 2)
    set "_err_code=2"
    set "_err_line=65535"
    call :_printErr 2 65535
    endlocal & set "_err_code=2" & set "_err_line=65535"
    echo Ok
    goto :_repl
  )
  call :run "!_postfix!"
  @REM On error, print the canonical message before "Ok"
  if !_err_code! neq 0 call :_printErr !_err_code! !_err_line!
  @REM Propagate error state out of setlocal so next iteration can read ERR/ERL
  endlocal & set "_err_code=%_err_code%" & set "_err_line=%_err_line%"
  echo Ok
  goto :_repl
:_repl_end
  exit /B 0


@REM --- _replFile OP TOKENS: extract filename STR_ from TOKENS, call file OP ---
@REM TOKENS is the full lexer-emitted line including the LOAD/SAVE keyword.
:_replFile
  setlocal EnableDelayedExpansion
  set "_op=%~1"
  set "_toks=%~2"
  set "_path="
  for %%t in (!_toks!) do (
    if not defined _path (
      set "_tt=%%t"
      if "!_tt:~0,4!"=="STR_" (
        call %GWSRC%\str\str decode !_tt:~4! _path
      )
    )
  )
  if not defined _path (
    echo Bad file name 1>&2
    endlocal
    exit /B 1
  )
  call %GWSRC%\file\file !_op! "!_path!"
  endlocal
  exit /B 0
