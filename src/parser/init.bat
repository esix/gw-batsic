@echo off
if not defined GWSRC set GWSRC=%~dp0..

goto _start


:addBNFLine lhs rhs
  if "%~2"=="ε" (
    set "grammar.rule[%i%]=%~1"
  ) else (
    set "grammar.rule[%i%]=%~1 %~2"
  )
  call %GWSRC%\lib\strvec push_uniq grammar.nonterminals "%~1"
  set /a i=%i%+1
exit /b


:getRule idx ret
  setlocal EnableDelayedExpansion
  set "rule=!grammar.rule[%~1]!"
  endlocal && set "%~2=%rule%"
exit /b


:addTerminal symbol
  call %GWSRC%\lib\strvec includes grammar.nonterminals %~1
  if NOT ERRORLEVEL 1 exit /b 1
  call %GWSRC%\lib\strvec push_uniq grammar.terminals %~1
exit /b 0


:addTerminals idx
  call :getRule %~1 rule
  for %%a in (%rule%) do (
    call:addTerminal %%a
  )
exit /b 0


:_start
  set i=0
  set grammar.nullable=
  set grammar.rule=
  set grammar.terminals=EOL
  set grammar.nonterminals=Root
  set grammar.start=

  FOR /F "tokens=1,2,* delims= " %%a in (%GWSRC%\parser\bnf.txt) do (
    call:addBNFLine "%%a" "%%c"
  )
  set grammar.rule.length=%i%

  call %GWSRC%\lib\iter range 0 %grammar.rule.length% iter
  for %%i in (%iter%) do (
    call:addTerminals %%i 
  )
  :: TODO: get start
  :: TODO: add rule [Root Start EOL]

