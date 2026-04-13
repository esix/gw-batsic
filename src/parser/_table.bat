@echo off
@REM Build LL(1) parse table from grammar, FIRST and FOLLOW sets.
@REM
@REM For each rule N: A -> alpha
@REM   For each terminal a in FIRST(alpha):
@REM     Set table.A.a = N
@REM   If e in FIRST(alpha):
@REM     For each terminal b in FOLLOW(A):
@REM       Set table.A.b = N
@REM
@REM Conflicts (table entry already set) are reported.
@REM
@REM Caller must have EnableDelayedExpansion active.
@REM Requires: grammar.*, first.*, follow.* from previous steps
@REM Sets: table.NONTERMINAL.TERMINAL = rule number

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:compute
  set "_conflicts=0"
  set /a "_last=!grammar.rules.length!-1"
  for /L %%i in (0,1,!_last!) do (
    set "_r=!grammar.rules.%%i!"
    for /f "tokens=1,2*" %%a in ("!_r!") do (
      set "_lhs=%%a"
      set "_first_sym=%%b"
    )
    @REM Compute FIRST of this rule's RHS (strip @actions first)
    set "_rfirst="
    set "_rnull=1"
    set "_cleanrhs="
    set "_skip=1"
    for %%s in (!_r!) do if "!_skip!"=="1" (set "_skip=") else (
      set "_sc=%%s"
      if "!_sc:~0,1!" neq "@" set "_cleanrhs=!_cleanrhs! %%s"
    )
    for %%s in (!_cleanrhs!) do if "!_rnull!"=="1" (
      if "%%s"=="e" (
        call set add _rfirst e
      ) else (
        call set has grammar.nonterminals %%s
        if errorlevel 1 (
          call set add _rfirst %%s
          set "_rnull="
        ) else for %%S in (%%s) do (
          for %%f in (!first.%%S!) do (
            if "%%f" neq "e" call set add _rfirst %%f
          )
          call set has first.%%S e
          if errorlevel 1 set "_rnull="
        )
      )
    )
    if "!_rnull!"=="1" call set add _rfirst e

    @REM For each terminal in FIRST(rhs): set table entry
    for %%a in (!_rfirst!) do (
      if "%%a" neq "e" (
        @REM Check for conflict (only if different rule)
        if defined table.!_lhs!.%%a for %%L in (!_lhs!) do (
          if "!table.%%L.%%a!" neq "%%i" (
            echo CONFLICT: table.%%L.%%a = !table.%%L.%%a! vs %%i
            set /a "_conflicts+=1"
          )
        )
        set "table.!_lhs!.%%a=%%i"
      )
    )
    @REM If nullable: for each terminal in FOLLOW(lhs), set table entry
    @REM FOLLOW entries do NOT overwrite existing FIRST entries (FIRST has priority)
    call set has _rfirst e
    if not errorlevel 1 for %%L in (!_lhs!) do (
      for %%b in (!follow.%%L!) do (
        if not defined table.%%L.%%b (
          set "table.%%L.%%b=%%i"
        ) else if "!table.%%L.%%b!" neq "%%i" (
          echo CONFLICT: table.%%L.%%b = !table.%%L.%%b! vs %%i [FOLLOW]
          set /a "_conflicts+=1"
        )
      )
    )
  )
  set "_rfirst="& set "_rnull="& set "_rr="& set "_skip="& set "_lhs="& set "_first_sym="& set "_r="
  exit /B 0


@REM === Save table to cache file ===
:saveCache
  setlocal EnableDelayedExpansion
  set "_d=%~1"
  echo ; Auto-generated parse table - delete to rebuild from bnf.txt> "!_d!"
  echo ; Rules + table entries, searched via findstr>> "!_d!"
  @REM Save grammar metadata
  echo grammar.start=!grammar.start!>> "!_d!"
  echo grammar.rules.length=!grammar.rules.length!>> "!_d!"
  echo grammar.nonterminals=!grammar.nonterminals!>> "!_d!"
  echo grammar.terminals=!grammar.terminals!>> "!_d!"
  @REM Save rules
  set /a "_last=!grammar.rules.length!-1"
  for /L %%i in (0,1,!_last!) do (
    echo rule.%%i=!grammar.rules.%%i!>> "!_d!"
  )
  @REM Save table entries
  for /f "delims=" %%a in ('set table. 2^>nul') do (
    echo %%a>> "!_d!"
  )
  endlocal & set "_tablefile=%~1"
  exit /B 0


@REM === Check if cache exists ===
:loadCache
  if not exist "%~1" exit /B 1
  set "_tablefile=%~1"
  exit /B 0


@REM === Look up a table entry: table.Nonterminal.Terminal -> rule number ===
:lookup
  set "%~3="
  for /f "tokens=2 delims==" %%v in ('findstr /B /C:"table.%~1.%~2=" "!_tablefile!"') do (
    set "%~3=%%v"
  )
  if "!%~3!"=="" exit /B 1
  exit /B 0


@REM === Look up a rule by number: rule.N -> "LHS sym sym ..." ===
:rule
  set "%~2="
  for /f "tokens=2* delims==" %%a in ('findstr /B /C:"rule.%~1=" "!_tablefile!"') do (
    set "%~2=%%a"
  )
  if "!%~2!"=="" exit /B 1
  exit /B 0


@REM === Look up grammar metadata ===
:meta
  set "%~2="
  for /f "tokens=2* delims==" %%a in ('findstr /B /C:"%~1=" "!_tablefile!"') do (
    set "%~2=%%a"
  )
  if "!%~2!"=="" exit /B 1
  exit /B 0


:dump
  setlocal EnableDelayedExpansion
  set /a "_entries=0"
  for /f "delims=" %%a in ('findstr /B "table." "!_tablefile!"') do set /a "_entries+=1"
  echo === LL(1) Parse Table ===
  echo Entries: !_entries!
  echo File: !_tablefile!
  echo.
  echo --- Lookup test ---
  call :lookup Stmt PRINT _r
  call :rule !_r! _rule
  echo   Stmt + PRINT = rule !_r!: !_rule!
  call :lookup AddExpr NUM _r
  call :rule !_r! _rule
  echo   AddExpr + NUM = rule !_r!: !_rule!
  call :lookup MulRest MUL _r
  call :rule !_r! _rule
  echo   MulRest + MUL = rule !_r!: !_rule!
  call :lookup Stmt NOTEXIST _r
  if errorlevel 1 echo   Stmt + NOTEXIST = not found (correct)
  endlocal
  exit /B 0


:_start
  setlocal EnableDelayedExpansion
  set "PATH=%~dp0;%~dp0..\stl;%PATH%"

  call :loadCache "%~dp0_table.dat"
  if not errorlevel 1 (
    echo Loaded from cache.
  ) else (
    call _nonterminals read "%~dp0bnf.txt"
    call _terminals compute
    echo Computing FIRST sets...
    call _first compute
    echo Computing FOLLOW sets...
    call _follow compute
    echo Building parse table...
    call :compute
    echo Saving...
    call :saveCache "%~dp0_table.dat"
  )
  call :dump
  endlocal
