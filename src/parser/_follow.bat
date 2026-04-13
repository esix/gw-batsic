@echo off
@REM Compute FOLLOW sets for all nonterminals.
@REM
@REM FOLLOW(S) starts with {$} for start symbol.
@REM For each rule A -> a B b:
@REM   Add FIRST(b)\{e} to FOLLOW(B)
@REM   If e in FIRST(b) or b is empty: add FOLLOW(A) to FOLLOW(B)
@REM
@REM Fixed-point iteration until stable.
@REM
@REM Caller must have EnableDelayedExpansion active.
@REM Requires: grammar.* + first.* from previous steps
@REM Sets: follow.NONTERMINAL for each nonterminal

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:compute
  @REM Initialize: empty FOLLOW set for each nonterminal
  for %%n in (!grammar.nonterminals!) do set "follow.%%n="
  @REM Add $ (end marker) to FOLLOW of start symbol
  call set add follow.!grammar.start! $

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
    for /f "tokens=1*" %%a in ("!_r!") do (
      set "_lhs=%%a"
      set "_rhs=%%b"
    )
    if "!_rhs!" neq "e" call :_processRule
  )
  goto :_fp_loop

:_fp_done
  set "_changed="& set "_iter_count=!_iter!"
  set "_r="& set "_lhs="& set "_rhs="
  exit /B 0


@REM Process one rule: for each nonterminal B in RHS,
@REM add FIRST(rest)\{e} to FOLLOW(B), and if rest is nullable add FOLLOW(LHS).
:_processRule
  @REM Strip @action markers and build array of RHS symbols
  set /a "_len=0"
  for %%s in (!_rhs!) do (
    set "_sc=%%s"
    if "!_sc:~0,1!" neq "@" (
      set "_sym.!_len!=%%s"
      set /a "_len+=1"
    )
  )
  @REM For each position in RHS
  set /a "_lastpos=!_len!-1"
  for /L %%p in (0,1,!_lastpos!) do (
    set "_B=!_sym.%%p!"
    @REM Only process if B is a nonterminal
    call set has grammar.nonterminals !_B!
    if not errorlevel 1 (
      @REM Compute FIRST of the rest (symbols after B)
      set "_restnull=1"
      set /a "_np=%%p+1"
      for /L %%q in (!_np!,1,!_lastpos!) do if "!_restnull!"=="1" (
        set "_Sv=!_sym.%%q!"
        call set has grammar.nonterminals !_Sv!
        if errorlevel 1 (
          @REM Terminal: add to FOLLOW(B), rest not nullable
          call set add follow.!_B! !_Sv!
          if not errorlevel 1 set "_changed=1"
          set "_restnull="
        ) else for %%S in (!_Sv!) do (
          @REM Nonterminal: add FIRST(S)\{e} to FOLLOW(B)
          for %%f in (!first.%%S!) do (
            if "%%f" neq "e" (
              call set add follow.!_B! %%f
              if not errorlevel 1 set "_changed=1"
            )
          )
          @REM Continue only if e in FIRST(S)
          call set has first.%%S e
          if errorlevel 1 set "_restnull="
        )
      )
      @REM If rest is nullable (or B is last symbol): add FOLLOW(LHS) to FOLLOW(B)
      if "!_restnull!"=="1" for %%L in (!_lhs!) do (
        for %%f in (!follow.%%L!) do (
          call set add follow.!_B! %%f
          if not errorlevel 1 set "_changed=1"
        )
      )
    )
  )
  exit /B 0


:dump
  setlocal EnableDelayedExpansion
  echo === FOLLOW sets (computed in %_iter_count% iterations) ===
  for %%n in (!grammar.nonterminals!) do (
    set "_f=!follow.%%n!"
    if defined _f (
      call set size follow.%%n _sz
      echo   %%n [!_sz!]: !_f!
    )
  )
  endlocal
  exit /B 0


:_start
  setlocal EnableDelayedExpansion
  set "PATH=%~dp0;%~dp0..\stl;%PATH%"
  call _nonterminals read "%~dp0bnf.txt"
  call _terminals compute
  echo Computing FIRST sets...
  call _first compute
  echo Computing FOLLOW sets...
  call _follow compute
  call :dump
  endlocal
