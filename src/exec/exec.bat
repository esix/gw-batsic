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

  for %%t in (!_postfix!) do if !_err!==0 (
    set "_tok=%%t"
    set "_tp=!_tok:~0,4!"
    @REM Values: push onto stack
    if "!_tp!"=="NUM_" (
      call %GWSRC%\stl\vec push _stk !_tok:~4!
    ) else if "!_tp!"=="VAR_" (
      @REM TODO: look up variable value
      call %GWSRC%\stl\vec push _stk !_tok!
    ) else if "!_tp!"=="STR_" (
      call %GWSRC%\stl\vec push _stk !_tok!
    ) else if "!_tp!"=="REM_" (
      @REM Comment: ignore
      set "_nop=1"
    ) else (
      @REM Action: call RTL handler
      if exist "%GWSRC%\rtl\!_tok!.bat" (
        call %GWSRC%\rtl\!_tok!.bat _stk
        set "_err=!ERRORLEVEL!"
      ) else (
        echo RTL: unknown action !_tok! 1>&2
        set "_err=1"
      )
    )
  )

  @REM Propagate flow-control state back to caller (RUN loop)
  endlocal & set "_next_line=%_next_line%" & set "_gosub_stack=%_gosub_stack%" & exit /B %_err%


@REM --- runProgram: execute the stored program from lowest line number ---
@REM Iterates lines via _next_line; RTLs (GOTO/GOSUB/RETURN) override it.
:runProgram
  setlocal EnableDelayedExpansion
  set "_gosub_stack="
  @REM Find the lowest line number from sorted program.dat
  set "_first="
  for /f "usebackq tokens=1 delims= " %%k in (`sort "%GWTEMP%\program.dat"`) do (
    if not defined _first set "_first=%%k"
  )
  if not defined _first (endlocal & exit /B 0)
  call :_keyToLn !_first! _next_line

:_runProg_loop
  if not defined _next_line goto :_runProg_done
  if "!_next_line!"=="" goto :_runProg_done
  call %GWSRC%\exec\_program get !_next_line! _line_tokens
  if not defined _line_tokens (
    echo Undefined line !_next_line!
    goto :_runProg_done
  )
  @REM Strip leading LN__nnn token
  for /f "tokens=1*" %%a in ("!_line_tokens!") do set "_line_tokens=%%b"
  @REM Compute the natural-next line (smallest key > current); RTLs may override
  call :_naturalNext !_next_line! _next_line
  call %GWSRC%\parser\parse parse "!_line_tokens!" _postfix
  if errorlevel 1 goto :_runProg_done
  call :run "!_postfix!"
  set "_e=!ERRORLEVEL!"
  if !_e! neq 0 goto :_runProg_done
  goto :_runProg_loop

:_runProg_done
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


:_start
  if not defined GWSRC set "GWSRC=%~dp0.."
  if not defined GWTEMP set "GWTEMP=%~dp0..\..\temp"
  @REM Parser needs _table on PATH for internal lookups
  set "PATH=%GWSRC%\parser;%PATH%"
  call %GWSRC%\lexer\keyword init
  call %GWSRC%\parser\_table loadCache "%GWSRC%\parser\_table.dat"
  call %GWSRC%\exec\_vars init

  echo GW-BASIC Executor. Enter a line. Empty to quit.
:_repl
  call %GWSRC%\str\str input "> " _hex
  if errorlevel 1 goto :_repl_end
  setlocal EnableDelayedExpansion
  @REM Lexer
  call %GWSRC%\lexer\lexer ParseTxt !_hex! _tokens
  set "_first="
  set "_rest="
  for /f "tokens=1*" %%a in ("!_tokens!") do (
    set "_first=%%a"
    set "_rest=%%b"
  )
  @REM Program line entry: first token is LN__nnn — store (or delete if empty)
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
  @REM Direct commands
  if "!_first!"=="LIST" (
    call %GWSRC%\exec\_program list
    endlocal
    goto :_repl
  )
  if "!_first!"=="SYSTEM" (
    endlocal
    goto :_repl_end
  )
  if "!_first!"=="RUN" (
    call :runProgram
    endlocal
    goto :_repl
  )
  @REM Immediate mode: parse and execute
  call %GWSRC%\parser\parse parse "!_tokens!" _postfix
  if errorlevel 1 (
    endlocal
    goto :_repl
  )
  call :run "!_postfix!"
  endlocal
  goto :_repl
:_repl_end
