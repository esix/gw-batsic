@echo off

:: dependencies

if "%~1"=="" (call :repl) else call :%*
exit /b

:repl
  setlocal enableDelayedExpansion

  rem 60  LET A = A - 1
  set "tokens=I16_60 VAR_LET VAR_A EQL_ VAR_A MINS I16_1"
  call :parse tokens
  :repl_empty
  ( endlocal
    exit /b
  )


:parse tokens [ast]
::
::
  setlocal enableDelayedExpansion
  set "tokens=!%~1!"
  set "ast=AST"
  ::

  :tokenize_exit
  ( endlocal
    if "%~2" neq "" (set %~2=%ast%) else echo:%ast%
    exit /b %error%
  )
