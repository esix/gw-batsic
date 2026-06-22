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

  @REM FOR / NEXT need mid-line loop-back, which the line-based RUN loop
  @REM cannot express.  A single-line FOR..NEXT keeps its body in the postfix
  @REM AFTER the FOR; we capture it and re-run it on each NEXT that continues.
  @REM Multi-line loops leave an empty in-line body and fall through to the
  @REM body-line jump NEXT.bat sets.  Keyed by for-stack depth so loops nest.
  if "!_tok!"=="FOR" goto :_run_for
  if "!_tok!"=="NEXT" goto :_run_next

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

:_run_for
  call %GWSRC%\rtl\FOR.bat _stk
  set "_err=!ERRORLEVEL!"
  call %GWSRC%\stl\vec size _for_vars _fdep
  for /f "delims=" %%d in ("!_fdep!") do set "_inlinePost_%%d=!_postfix!"
  goto :_run_loop

:_run_next
  call %GWSRC%\stl\vec size _for_vars _fdep
  call %GWSRC%\rtl\NEXT.bat _stk
  set "_err=!ERRORLEVEL!"
  call %GWSRC%\stl\vec size _for_vars _fdep2
  if not "!_fdep2!"=="!_fdep!" goto :_run_next_end
  @REM Loop continued: re-run the in-line body (single-line loop).  For a
  @REM multi-line loop the body is empty, so this is a no-op and the
  @REM body-line jump NEXT.bat set takes effect when the line ends.
  for /f "delims=" %%d in ("!_fdep!") do if defined _inlinePost_%%d set "_postfix=!_inlinePost_%%d!"
  goto :_run_loop
:_run_next_end
  @REM Loop ended: drop the saved in-line body for this depth.
  for /f "delims=" %%d in ("!_fdep!") do set "_inlinePost_%%d="
  goto :_run_loop

:_run_end
  @REM On real error, capture ERR / ERL.  Code 99 is the END/STOP flow-control
  @REM signal — not a user-visible error, so don't surface it via ERR.
  if !_err! neq 0 if !_err! neq 99 if !_err! neq 98 if !_err! neq 97 (
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
    & set "_print_col=%_print_col%" ^
    & set "_input_prompted=%_input_prompted%" ^
    & set "_data_ptr=%_data_ptr%" ^
    & set "_run_file=%_run_file%" ^
    & set "_run_line=%_run_line%" ^
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
  set "_sys_exit="
  call :_runInit
  if not defined _runFirst goto :_runProg_done
  if defined _runFatal (
    set "_err_code=2"
    set "_err_line=!_runFatal!"
    goto :_runProg_done
  )

:_runProg_loop
  if not defined _next_line goto :_runProg_done
  if "!_next_line!"=="" goto :_runProg_done
  set "_pad=00000!_next_line!"
  set "_pad=!_pad:~-5!"
  set "_postfix="
  for %%k in (!_pad!) do set "_postfix=!_ppfx_%%k!"
  if not defined _postfix (
    @REM "Undefined line number" — reported against the issuing line.
    set "_err_code=8"
    if not defined _cur_line set "_cur_line=65535"
    set "_err_line=!_cur_line!"
    goto :_runProg_done
  )
  set "_cur_line=!_next_line!"
  for %%k in (!_pad!) do set "_next_line=!_pnext_%%k!"
  call :run "!_postfix!"
  set "_e=!ERRORLEVEL!"
  if !_e! equ 98 goto :_runProg_restart
  if !_e! equ 97 (
    @REM SYSTEM — exit the interpreter (runOnce / REPL check _sys_exit)
    set "_sys_exit=1"
    set "_err_code=0"
    goto :_runProg_done
  )
  if !_e! neq 0 (
    if !_e! equ 99 (
      @REM END / STOP — graceful halt, no error
      set "_err_code=0"
      goto :_runProg_done
    )
    goto :_runProg_done
  )
  goto :_runProg_loop


@REM --- _runInit: (re)initialize all per-RUN state ---
@REM Called at runProgram start and again on every RUN statement restart.
@REM RUN clears variables and arrays (GW-BASIC semantics), resets the
@REM control-flow stacks and error state, rebuilds the READ/DATA queue
@REM and the pre-parsed line cache (_ppfx_/_pnext_, _runFirst, _runFatal).
@REM A pending _run_line (RUN <num>) overrides the start line.
:_runInit
  call %GWSRC%\exec\_vars init
  call %GWSRC%\exec\_arrays init
  call %GWSRC%\exec\_files init
  set "_print_path="
  set "_gosub_stack="
  set "_for_vars="
  set "_for_limits="
  set "_for_steps="
  set "_for_lines="
  set "_while_stack="
  set "_print_col=0"
  set "_err_code=0"
  set "_err_line=0"
  call :_buildDataQueue
  set "_data_ptr=0"
  call :_buildRunCache
  set "_next_line=!_runFirst!"
  if defined _run_line set "_next_line=!_run_line!"
  set "_run_line="
  exit /B 0


@REM --- _runProg_restart: a RUN statement executed inside the program ---
@REM Flow code 98.  _run_file: load that file (replacing the program);
@REM _run_line: start there.  Either way variables clear, caches rebuild.
:_runProg_restart
  if defined _run_file (
    call %GWSRC%\file\file load "!_run_file!"
    if errorlevel 1 (
      set "_err_code=53"
      set "_err_line=!_cur_line!"
      set "_run_file="
      set "_run_line="
      goto :_runProg_done
    )
  )
  set "_run_file="
  @REM Drop the stale pre-parsed line cache before rebuilding.
  for /f "delims==" %%v in ('set _ppfx_ 2^>nul') do set "%%v="
  for /f "delims==" %%v in ('set _pnext_ 2^>nul') do set "%%v="
  call :_runInit
  if not defined _runFirst goto :_runProg_done
  if defined _runFatal (
    set "_err_code=2"
    set "_err_line=!_runFatal!"
    goto :_runProg_done
  )
  goto :_runProg_loop


@REM --- _buildRunCache: pre-parse all program lines into env-var cache ---
@REM Writes directly into the caller's setlocal scope (no nested setlocal —
@REM we'd otherwise have to roll up hundreds of _ppfx_* / _pnext_* vars
@REM across endlocal, which is fragile).  Sets:
@REM   _ppfx_<KEY>   per-line parsed postfix
@REM   _pnext_<KEY>  natural-next line number (empty for the last line)
@REM   _runFirst     line number of the first program line
@REM   _runFatal     line that failed to parse (caller surfaces as err 2)
:_buildRunCache
  set "_runFirst="
  set "_runFatal="
  set "_prevK="
  for /f "usebackq tokens=1,* delims= " %%k in (`sort "%GWTEMP%\program.dat"`) do (
    set "_keyP=%%k"
    set "_toksP=%%l"
    @REM Strip the leading LN__nnn token before parsing.
    for /f "tokens=1*" %%a in ("!_toksP!") do set "_toksP=%%b"
    call %GWSRC%\parser\parse parse "!_toksP!" _pfP
    if errorlevel 1 (
      call :_keyToLn !_keyP! _badLn
      set "_runFatal=!_badLn!"
    ) else (
      set "_ppfx_!_keyP!=!_pfP!"
      call :_keyToLn !_keyP! _curLn
      if not defined _runFirst set "_runFirst=!_curLn!"
      if defined _prevK set "_pnext_!_prevK!=!_curLn!"
      set "_prevK=!_keyP!"
    )
  )
  @REM Last line's _pnext_ is intentionally unset → loop terminates after it.
  exit /B 0

:_runProg_done
  @REM Print canonical error message if a real error halted the run.
  if !_err_code! neq 0 call :_printErr !_err_code! !_err_line!
  @REM Propagate error state to caller (so ERR / ERL can be read in REPL after RUN)
  endlocal & set "_err_code=%_err_code%" & set "_err_line=%_err_line%" & set "_sys_exit=%_sys_exit%" & exit /B 0


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


@REM --- _buildDataQueue: scan program.dat for DATA statements ---
@REM Writes %GWTEMP%\data.dat, one item per line: "<source_line> <tagged_value>"
@REM Values are in the same on-stack form the executor uses: NUM tags become
@REM bare iXXXX / sXXXXXXXX / dXXXXXXXXXXXXXXXX; STR_ keeps its prefix.
@REM Each program line is scanned token-by-token; after a DATA keyword we
@REM accept NUM_*/STR_*/HEX_*/OCT_* (and an optional MINUS before NUM) until
@REM a COLON or EOL ends the DATA statement.
:_buildDataQueue
  setlocal EnableDelayedExpansion
  set "_df=%GWTEMP%\data.dat"
  type nul > "!_df!"
  for /f "usebackq tokens=1,* delims= " %%k in (`sort "%GWTEMP%\program.dat"`) do (
    call :_keyToLn %%k _ln
    call :_scanLineForData "%%l" !_ln!
  )
  endlocal
  exit /B 0

@REM _scanLineForData "TOKENS" LINE — walk tokens; on DATA, emit items.
:_scanLineForData
  setlocal EnableDelayedExpansion
  set "_toks=%~1"
  set "_ln=%~2"
  set "_inData=0"
  set "_neg=0"
:_sl_next
  if "!_toks!"=="" goto :_sl_done
  for /f "tokens=1*" %%a in ("!_toks!") do (set "_tok=%%a" & set "_toks=%%b")
  if "!_tok!"=="EOL"   (set "_inData=0" & set "_neg=0" & goto :_sl_next)
  if "!_tok!"=="COLON" (set "_inData=0" & set "_neg=0" & goto :_sl_next)
  if "!_tok!"=="DATA"  (set "_inData=1" & set "_neg=0" & goto :_sl_next)
  if "!_inData!"=="0" goto :_sl_next
  if "!_tok!"=="COMA"  (set "_neg=0" & goto :_sl_next)
  if "!_tok!"=="MINUS" (set "_neg=1" & goto :_sl_next)
  if "!_tok!"=="DATA_MRK" goto :_sl_next
  call :_emitDataItem "!_tok!" !_neg! !_ln!
  set "_neg=0"
  goto :_sl_next
:_sl_done
  endlocal
  exit /B 0

@REM _emitDataItem "TOKEN" NEG LINE — write one row to data.dat.
:_emitDataItem
  setlocal EnableDelayedExpansion
  set "_tok=%~1"
  set "_neg=%~2"
  set "_ln=%~3"
  set "_pfx=!_tok:~0,4!"
  set "_val="
  if "!_pfx!"=="NUM_" goto :_em_num
  if "!_pfx!"=="STR_" (set "_val=!_tok!" & goto :_em_write)
  if "!_pfx!"=="HEX_" goto :_em_hex
  if "!_pfx!"=="OCT_" goto :_em_oct
  goto :_em_done
:_em_num
  set "_val=!_tok:~4!"
  if "!_neg!"=="1" (
    set "_t=!_val:~0,1!"
    if "!_t!"=="i" call %GWSRC%\num\int neg !_val!
    if "!_t!"=="s" call %GWSRC%\num\sng neg !_val!
    if "!_t!"=="d" call %GWSRC%\num\dbl neg !_val!
    set "_val=!__!"
  )
  goto :_em_write
:_em_hex
  set /a "_v=0x!_tok:~4!"
  call %GWSRC%\num\int fromDec !_v!
  set "_val=!__!"
  goto :_em_write
:_em_oct
  set "_octStr=!_tok:~4!"
  set /a "_v=0"
:_oct_loop
  if "!_octStr!"=="" goto :_oct_done
  set /a "_v=_v*8 + !_octStr:~0,1!"
  set "_octStr=!_octStr:~1!"
  goto :_oct_loop
:_oct_done
  call %GWSRC%\num\int fromDec !_v!
  set "_val=!__!"
:_em_write
  if defined _val >> "%GWTEMP%\data.dat" echo !_ln! !_val!
:_em_done
  endlocal
  exit /B 0


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


@REM --- runOnce: init engine, RUN the loaded program, exit (no REPL) ---
@REM Driven by `gw-batsic.bat /R file.bas`.  Exit code is the GW-BASIC
@REM error code (0 on clean END / STOP / fall-off).
:runOnce
  if not defined GWSRC set "GWSRC=%~dp0.."
  if not defined GWTEMP set "GWTEMP=%~dp0..\..\temp"
  set "PATH=%GWSRC%\parser;%PATH%"
  call %GWSRC%\lexer\keyword init
  call %GWSRC%\parser\_table loadCache "%GWSRC%\parser\_table.dat"
  call %GWSRC%\exec\_vars init
  call %GWSRC%\exec\_arrays init
  call %GWSRC%\exec\_files init
  set "_print_path="
  set "_err_code=0"
  set "_err_line=0"
  call :runProgram
  exit /B %_err_code%


:_start
  if not defined GWSRC set "GWSRC=%~dp0.."
  if not defined GWTEMP set "GWTEMP=%~dp0..\..\temp"
  @REM Parser needs _table on PATH for internal lookups
  set "PATH=%GWSRC%\parser;%PATH%"
  call %GWSRC%\lexer\keyword init
  call %GWSRC%\parser\_table loadCache "%GWSRC%\parser\_table.dat"
  call %GWSRC%\exec\_vars init
  call %GWSRC%\exec\_arrays init
  call %GWSRC%\exec\_files init
  set "_print_path="
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
  if "!_first!"=="LOAD" (
    call :_replFile load "!_tokens!"
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
  set "_re=!ERRORLEVEL!"
  if "!_re!"=="97" (endlocal & goto :_repl_end)
  if "!_re!"=="98" goto :_repl_runflow
  @REM On error, print the canonical message before "Ok"
  if !_err_code! neq 0 call :_printErr !_err_code! !_err_line!
  @REM Propagate error state out of setlocal so next iteration can read ERR/ERL
  endlocal & set "_err_code=%_err_code%" & set "_err_line=%_err_line%"
  echo Ok
  goto :_repl

@REM --- Immediate-mode RUN (flow code 98 from the RUN RTLs) ---
@REM Optionally load _run_file, then start the program.  _run_line is
@REM still set in this scope and is honoured by :_runInit.
:_repl_runflow
  if defined _run_file (
    call %GWSRC%\file\file load "!_run_file!"
    if errorlevel 1 (
      set "_run_file=" & set "_run_line="
      call :_printErr 53 65535
      endlocal & set "_err_code=53" & set "_err_line=65535"
      echo Ok
      goto :_repl
    )
  )
  set "_run_file="
  call :runProgram
  if defined _sys_exit (endlocal & goto :_repl_end)
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
