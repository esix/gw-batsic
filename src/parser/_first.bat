@echo off
@REM Compute FIRST sets for all nonterminals.
@REM
@REM FIRST(X):
@REM   If X is terminal: FIRST(X) = {X}
@REM   If X -> e: add e to FIRST(X)
@REM   If X -> Y1 Y2 ... Yn:
@REM     Add FIRST(Y1)\{e} to FIRST(X)
@REM     If e in FIRST(Y1): add FIRST(Y2)\{e}
@REM     If e in FIRST(Y1..Yk): add FIRST(Yk+1)\{e}
@REM     If e in all FIRST(Yi): add e
@REM
@REM Fixed-point iteration until stable.
@REM
@REM Caller must have EnableDelayedExpansion active.
@REM Requires: grammar.* from _nonterminals + _terminals
@REM Sets: first.NONTERMINAL for each nonterminal

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:compute
  @REM Initialize: empty FIRST set for each nonterminal
  for %%n in (!grammar.nonterminals!) do set "first.%%n="

  @REM Fixed-point iteration
  set "_changed=1"
  set /a "_iter=0"
:_fp_loop
  if "!_changed!" neq "1" goto :_fp_done
  set "_changed="
  set /a "_iter+=1"

  set /a "_last=!grammar.rules.length!-1"
  for /L %%i in (0,1,!_last!) do (
    set "_r=!grammar.rules.%%i!"
    @REM Extract LHS (first word)
    for /f "tokens=1*" %%a in ("!_r!") do (
      set "_lhs=%%a"
      set "_rhs=%%b"
    )
    @REM Process RHS symbols
    if "!_rhs!"=="e" (
      @REM Rule X -> e: add e to FIRST(X)
      call set add first.!_lhs! e
      if not errorlevel 1 set "_changed=1"
    ) else (
      @REM Walk RHS symbols, adding to FIRST(LHS)
      @REM Strip @action markers from RHS (they don't affect FIRST)
      set "_cleanrhs="
      for %%s in (!_rhs!) do (
        set "_sc=%%s"
        if "!_sc:~0,1!" neq "@" set "_cleanrhs=!_cleanrhs! %%s"
      )
      set "_allnull=1"
      for %%s in (!_cleanrhs!) do if "!_allnull!"=="1" (
        @REM Is this symbol a terminal?
        call set has grammar.nonterminals %%s
        if errorlevel 1 (
          @REM Terminal: add it to FIRST(LHS), stop
          call set add first.!_lhs! %%s
          if not errorlevel 1 set "_changed=1"
          set "_allnull="
        ) else (
          @REM Nonterminal: add FIRST(sym)\{e} to FIRST(LHS)
          for %%f in (!first.%%s!) do (
            if "%%f" neq "e" (
              call set add first.!_lhs! %%f
              if not errorlevel 1 set "_changed=1"
            )
          )
          @REM Continue only if e in FIRST(sym)
          call set has first.%%s e
          if errorlevel 1 set "_allnull="
        )
      )
      @REM If all RHS symbols are nullable: add e
      if "!_allnull!"=="1" (
        call set add first.!_lhs! e
        if not errorlevel 1 set "_changed=1"
      )
    )
  )
  goto :_fp_loop

:_fp_done
  set "_changed="& set "_iter_count=!_iter!"& set "_r="& set "_lhs="& set "_rhs="& set "_allnull="
  exit /B 0


:dump
  setlocal EnableDelayedExpansion
  echo === FIRST sets (computed in %_iter_count% iterations) ===
  for %%n in (!grammar.nonterminals!) do (
    call set size first.%%n _sz
    echo   %%n [!_sz!]: !first.%%n!
  )
  endlocal
  exit /B 0


:_start
  setlocal EnableDelayedExpansion
  set "PATH=%~dp0;%~dp0..\stl;%PATH%"
  call _nonterminals read "%~dp0bnf.txt"
  call _terminals compute
  echo Computing FIRST sets...
  call :compute
  call :dump
  endlocal
