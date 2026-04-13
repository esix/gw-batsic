@echo off
@REM Compute terminals set from grammar rules.
@REM A terminal is any RHS symbol that is NOT a nonterminal and not "e" (epsilon).
@REM
@REM Caller must have EnableDelayedExpansion active.
@REM Requires: grammar.rules.*, grammar.nonterminals from _nonterminals.bat
@REM
@REM Sets:
@REM   grammar.terminals - set of terminal names

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:compute
  set "grammar.terminals="
  set /a "_last=!grammar.rules.length!-1"
  for /L %%i in (0,1,!_last!) do (
    set "_r=!grammar.rules.%%i!"
    set "_skip=1"
    for %%s in (!_r!) do (
      if "!_skip!"=="1" (
        set "_skip="
      ) else if "%%s" neq "e" (
        set "_sc=%%s"
        if "!_sc:~0,1!" neq "@" (
          call set has grammar.nonterminals %%s
          if errorlevel 1 call set add grammar.terminals %%s
        )
      )
    )
  )
  set "_r="& set "_skip="
  exit /B 0


:dump
  setlocal EnableDelayedExpansion
  call set size grammar.terminals _sz
  echo === Terminals: !_sz! ===
  for %%t in (!grammar.terminals!) do echo   %%t
  endlocal
  exit /B 0


:_start
  setlocal EnableDelayedExpansion
  set "PATH=%~dp0;%~dp0..\stl;%PATH%"
  call _nonterminals read "%~dp0bnf.txt"
  call :compute
  call :dump
  endlocal
