@echo off
@REM Read bnf.txt, extract rules and nonterminals.
@REM
@REM Caller must have EnableDelayedExpansion active.
@REM Requires: src/stl on PATH (set.bat)
@REM
@REM Sets:
@REM   grammar.nonterminals  - set of nonterminal names
@REM   grammar.rules.N       - rule N: "LHS sym1 sym2 ..."
@REM   grammar.rules.length  - total number of rules
@REM   grammar.start         - start symbol (LHS of first rule)

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:read
  set /a "grammar.rules.length=0"
  set "grammar.nonterminals="
  set "grammar.start="

  for /f "usebackq eol=; tokens=1,* delims==" %%a in ("%~1") do (
    set "_lhs=%%a"
    set "_rhs=%%b"
    if defined _lhs (
      for /f "tokens=1" %%w in ("!_lhs!") do set "_lhs=%%w"
      if defined _rhs if "!_rhs:~0,1!"==" " set "_rhs=!_rhs:~1!"
      if not defined _rhs set "_rhs=e"
      set "grammar.rules.!grammar.rules.length!=!_lhs! !_rhs!"
      set /a "grammar.rules.length+=1"
      call set add grammar.nonterminals !_lhs!
      if not defined grammar.start set "grammar.start=!_lhs!"
    )
  )
  set "_lhs="& set "_rhs="
  exit /B 0


:dump
  setlocal EnableDelayedExpansion
  call set size grammar.nonterminals _sz
  echo === Nonterminals: !_sz! ===
  for %%n in (!grammar.nonterminals!) do echo   %%n
  echo.
  echo Start: !grammar.start!
  echo Rules: !grammar.rules.length!
  echo.
  echo --- Rules ---
  set /a "_last=!grammar.rules.length!-1"
  for /L %%i in (0,1,!_last!) do (
    set "_r=!grammar.rules.%%i!"
    for /f "tokens=1*" %%a in ("!_r!") do echo   %%i: %%a ::= %%b
  )
  endlocal
  exit /B 0


:_start
  setlocal EnableDelayedExpansion
  set "PATH=%~dp0..\stl;%PATH%"
  call :read "%~dp0bnf.txt"
  call :dump
  endlocal
