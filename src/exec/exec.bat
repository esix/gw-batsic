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

  endlocal & exit /B %_err%


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
