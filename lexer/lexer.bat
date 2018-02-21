@echo off

:: dependencies
if [%libchar%]==[] (
  for %%i in ("%~dp0..\libs\libchar\libchar.bat") do (
    set "libchar=%%~fi"
  )
)
if [%libbin%]==[] (
  for %%i in ("%~dp0..\libs\libbin\libbin.bat") do (
    set "libbin=%%~fi"
  )
)

if [%~1]==[] (call :usage) else (call :%*)
exit /b

:usage                                 -- syntax and general info
::
::  lexer.bat is a part of gwbatsic interpreter
::  it converts a string (one line in basic syntax) into a sequence of tokens
::
::  syntax:
::
::    [call] [path]lexer function [arguments]
::
::  For a full list of available functions use:
::
::     lexer help
::
::  For detailed help on a specific function use:
::
::     lexer help FunctionName
::
::  To use interactive process, run repl function without arguments
::  lexer repl
::
::
  call :help Usage
  exit /b


:repl                                   -- interactive read-eval-print-loop
  setlocal enableDelayedExpansion
  :repl.loop
    set /p "line=Ok> "
    If %errorlevel%==1 goto repl.empty
    set "tokens="
    call :tokenize line tokens

    if [%errorlevel%]==[0] (
      echo !tokens!
    ) else (
      echo Error=%errorlevel%
      echo Syntax error
    )
    goto :repl.loop
  :repl.empty
  ( endlocal
    exit /b
  )


:tokenize line [tokens]                -- run lexer on provided string
::                                      -- line   [in, var]  - string variable with gwbatsic line
::                                      -- tokens [out, var] - list of resulting tokens
::
:: Tokenizes provided line and return list of tokens 
:: If succeded errorlevel is 0 (Ok)
:: if lexer fails the errorcode will be 2 (Syntax error)
:: 
::
  setlocal enableDelayedExpansion
  set "line=!%~1!"
  set "hexLine="
  call %libchar% str2hex line hexLine
  call %libchar% StrLen hexLine len
  set /a "len=!len!/2"
  rem initial state is "1"
  set /a "state=1"
  set "acc="
  set "tokens="
  set "error=0"

  set i=0
  :i_loop
    set /a "pos=2*!i!"
    call set "hex=%%hexLine:~%pos%,2%%"
    call :_SMEvent !hex! state acc tokens
    set "error=%errorlevel%"
    set /a i=!i!+1
    rem we reserve special code=100 for "BACK" operator: to process the char twice
    if [!error!]==[100] (set /a "i=!i!-1" && set "error=0")
    if NOT [!error!]==[0] goto :tokenize_exit
    if !i! LSS !len! goto i_loop

  rem EOL
  call :_SMEvent 0A state acc tokens
  if errorlevel 100 (
    call :_SMEvent 0A state acc tokens
  )

  :tokenize_exit
  ( endlocal
    if "%~2" neq "" (set %~2=%tokens%) else echo:%tokens%
    exit /b %error%
  )






:_SMEvent hexCode state acc tokens     -- state machine event handler
::                                      -- hexCode          - hexadecimal ascii code of next character
::                                      -- state  [in, out] - variable for current state   
::                                      -- acc    [in, out] - accumulator for incomplete tokens
::                                      -- tokens [in, out] - result
  setlocal enableDelayedExpansion
  :: arguments
  set "hexCode=%~1"
  set "state=!%~2!"
  set "acc=!%~3!"
  set "tokens=!%~4!"
  :: var
  set /A "charCode=0x!hexCode!"
  set "char="
  set "nextState="
  set "result=0"

  call %libchar% chr !charCode! char
  
  if [!state!]==[0] (
    rem  Ok state: nothing should be after
    rem  if there is then error
  )
  if [!state!]==[1] (
    if [!hexCode!]==[3A] ( call :PushToken COLN tokens && set "nextState=1" )
    if [!hexCode!]==[3B] ( call :PushToken SCLN tokens && set "nextState=1" )
    if [!hexCode!]==[2C] ( call :PushToken COMM tokens && set "nextState=1" )
    if [!hexCode!]==[2B] ( call :PushToken PLUS tokens && set "nextState=1" )
    if [!hexCode!]==[2D] ( call :PushToken MINS tokens && set "nextState=1" )
    if [!hexCode!]==[2A] ( call :PushToken MULT tokens && set "nextState=1" )
    if [!hexCode!]==[2F] ( call :PushToken DIV_ tokens && set "nextState=1" )
    if [!hexCode!]==[5C] ( call :PushToken IDIV tokens && set "nextState=1" )
    rem  =
    if [!hexCode!]==[3D] ( call :PushToken EQL_ tokens && set "nextState=1" )
    if [!hexCode!]==[28] ( call :PushToken OPAR tokens && set "nextState=1" )
    if [!hexCode!]==[29] ( call :PushToken CPAR tokens && set "nextState=1" )
    rem  space
    if [!hexCode!]==[20] (set "nextState=1" )
    rem  tab
    if [!hexCode!]==[07] (set "nextState=1" )
    rem  <
    if [!hexCode!]==[3C] ( set "nextState=2" )
    rem  >
    if [!hexCode!]==[3E] ( set "nextState=3" )
    rem  0..9
    call :_isDigit !hexCode!
    if errorlevel 1 (
      set "acc=!char!"
      set "nextState=4"
    )
    rem  a..zA-Z
    call :_isAlpha !hexCode!
    if errorlevel 1 (
      set "acc=!char!"
      set "nextState=10"
    )
    rem  "
    if [!hexCode!]==[22] ( set "acc=" && set "nextState=9" )
    rem  EOL
    if [!hexCode!]==[0A] ( set "nextState=0" )
  )
  if [!state!]==[2] (
    rem  =
    if [!hexCode!]==[3D] ( call :PushToken LEQU tokens && set "nextState=1" )
    rem  >
    if [!hexCode!]==[3E] ( call :PushToken NEQU tokens && set "nextState=1" )
    rem  else
    if [!nextState!]==[] ( call :PushToken LESS tokens && set "nextState=1" &&  set "result=100")
  )
  if [!state!]==[3] (
    rem
  )
  if [!state!]==[4] (
    rem  0..9
    call :_isDigit !hexCode!
    if errorlevel 1 (
      set "acc=!acc!!char!"
      set "nextState=4"
    )
    rem TODO e, E
    rem  else
    if [!nextState!]==[] (
      call :PushTokenInt !acc! tokens
      set "acc="
      set "nextState=1"
      set "result=100"
    )
  )
  if [!state!]==[9] (
    rem  "
    if [!hexCode!]==[22] ( call :PushToken STR_!acc! tokens && set "acc=" && set "nextState=1" )
    rem  EOL
    if [!hexCode!]==[0A] ( call :PushToken STR_!acc! tokens && set "acc=" && set "nextState=0" )
    rem  else
    if [!nextState!]==[] (
      set "acc=!acc!!hexCode!"
      set "nextState=9"
    )
  )
  if [!state!]==[10] (
    call :_isAlpha !hexCode!
    if errorlevel 1 (
      set "acc=!acc!!char!"
      set "nextState=10"
    )
    rem $
    if [!hexCode!]==[24] ( call :PushTokenId !acc!$ tokens && set "acc=" && set "nextState=1" )
    rem %
    if [!hexCode!]==[25] ( call :PushTokenId !acc!% tokens && set "acc=" && set "nextState=1" )
    rem !
    if [!hexCode!]==[21] ( call :PushTokenId !acc!^! tokens && set "acc=" && set "nextState=1" )
    rem #
    if [!hexCode!]==[23] ( call :PushTokenId !acc!# tokens && set "acc=" && set "nextState=1" )
    rem else
    if [!nextState!]==[] (
      call :PushTokenId !acc! tokens
      set "acc="
      set "nextState=1"
      rem  100 - "Lexer: Please, repeat char"
      set "result=100"
    )
  )
  ::
  ::
  if [!state!]==[-1] (
    rem This is fail state and no event can make us leave it
    set nextState=-1
  )

  :: nextState is empty: unknown char, FAIL
  if [!nextState!]==[] (
    rem The state was not set means it failed
    echo [lexer]: Failed at state !state!, char=!char! hex=!hexCode!
    rem  2 - "Syntax error"
    set "result=2"
    set "nextState=-1"
  )

  echo SME hex=%hexCode% (!char!)  state: !state!=^>!nextState!  acc='!acc!'  tokens='!tokens!'

  set state=!nextState!

  ( endlocal
    set %~2=%state%
    set %~3=%acc%
    set %~4=%tokens%
    exit /b %result%
  )


:PushTokenInt 
  call :PushToken I16_%~1 %~2
exit /b


:PushTokenId
  call :PushToken ID__%~1 %~2
exit /b


:PushTokenString
exit /b


:PushToken token tokens                -- add new token
  setlocal enableDelayedExpansion
  :: arguments
  set "token=%~1"
  set "tokens=!%~2!"
  ::
  if NOT [!tokens!]==[] ( set "tokens=!tokens! !token!" )
  if [!tokens!]==[]     ( set "tokens=!token!"          )
  ::
  ( endlocal
    set %~2=%tokens%
  )
exit /b


:_isDigit hexCode
  setlocal enableDelayedExpansion
  set "hexCode=%~1"
  set /A "charCode=0x!hexCode!"
  ::
  set "result=0"
  if !charCode! GEQ 48 (
    if !charCode! LEQ 57 (
        set "result=1"
    )
  )
  ::
  ( endlocal
    exit /b %result%
  )


:_isAlpha  hexCode
  setlocal enableDelayedExpansion
  set "hexCode=%~1"
  set /A "charCode=0x!hexCode!"
  ::
  set "result=0"
  if !charCode! GEQ 65 (
    if !charCode! LEQ 90 (
      set "result=1"
    )
  )
  if !charCode! GEQ 97 (
    if !charCode! LEQ 122 (
      set "result=1"
    )
  )
  ::
  ( endlocal
    exit /b %result%
  )


:help    [ /I | FuncName ]             -- Help
::
::  Displays help about function FuncName
::
::  If FuncName is not specified then lists all available functions
::
::  The case insensitive /I option adds Internal functions to the list
::  of availabile functions.
::
  setlocal disableDelayedExpansion
  set file="%~f0"
  echo:
  set _=
  if /i "%~1"=="/I" (set _=_) else if not "%~1"=="" goto :help.func
  for /f "tokens=* delims=:" %%a in ('findstr /r /c:"^:[%_%0-9A-Za-z]* " /c:"^:[%_%0-9A-Za-z]*$" %file%^|sort') do echo:  %%a
  exit /b
  :help.func
  set beg=
  for /f "tokens=1,* delims=:" %%a in ('findstr /n /r /i /c:"^:%~1 " /c:"^:%~1$" %file%') do (
    if not defined beg set beg=%%a
  )
  if not defined beg (1>&2 echo: Function %~1 not found) & exit /b 1
  set end=
  for /f "tokens=1 delims=:" %%a in ('findstr /n /r /c:"^[^:]" %file%') do (
    if not defined end if %beg% LSS %%a set end=%%a
  )
  for /f "tokens=1,* delims=[]:" %%a in ('findstr /n /r /c:"^ *:[^:]" /c:"^::[^:]" /c:"^ *::$" %file%') do (
    if %beg% LEQ %%a if %%a LEQ %end% echo: %%b
  )
exit /b 0