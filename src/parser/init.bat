@echo off
if not defined GWSRC set GWSRC=%~dp0..
::if exist strvec.bat (
::  set PATH=%~dp0..\lib;%PATH%
::  echo PATH UPDATED
::)

goto :_start


:addBNFLine lhs rhs
  if "%~2"=="ε" (
    set "grammar.rules[%i%]=%~1"
  ) else (
    set "grammar.rules[%i%]=%~1 %~2"
  )
  call %GWSRC%\lib\strvec push_uniq grammar.nonterminals "%~1"
  set /a i=%i%+1
exit /b


:: return rule by index [0..grammar.rules.length)
:getRule idx ret
  setlocal EnableDelayedExpansion
  set "rule=!grammar.rules[%~1]!"
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
  set rule0=
  set iter=
  set grammar.nullable=
  set grammar.rules=
  set grammar.terminals=EOL
  set grammar.nonterminals=Root
  set grammar.start=

  :: add rules and nonterminals
  FOR /F "tokens=1,2,* delims= " %%a in (%GWSRC%\parser\bnf.txt) do (
    call:addBNFLine "%%a" "%%c"
  )
  set grammar.rules.length=%i%

  :: add terminals
  call %GWSRC%\lib\iter range 0 %grammar.rules.length% iter
  for %%i in (%iter%) do (
    call:addTerminals %%i
  )

  :: set grammar.start = rules[0][0]
  call :getRule 0 rule0
  call %GWSRC%\lib\strvec front rule0 grammar.start

  :: add rule [Root Start EOL]
  set "grammar.rules[%grammar.rules.length%]=Root %grammar.start% EOL"
  set /a grammar.rules.length=%grammar.rules.length% + 1

  :: cleanup
  set i=
  set rule0=
  set iter=

