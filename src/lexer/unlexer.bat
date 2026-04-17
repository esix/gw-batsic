@echo off
@REM Unlexer: convert a token list back to readable text.
@REM
@REM Usage:
@REM   call unlexer fromTokens "<token list>" retVar
@REM
@REM Token mapping:
@REM   LN__nnn         -> nnn
@REM   NUM_<tagged>    -> decimal (via int/sng/dbl toDec)
@REM   STR_<hex>       -> "<decoded>"
@REM   REM_<hex>       -> <decoded>    (body already starts with a space)
@REM   HEX_<hex>       -> &H<hex>
@REM   OCT_<oct>       -> &O<oct>
@REM   VAR_UNK_<name>  -> <name>
@REM   VAR_INT_<name>  -> <name>%
@REM   VAR_SNG_<name>  -> <name>!
@REM   VAR_DBL_<name>  -> <name>#
@REM   VAR_STR_<name>  -> <name>$
@REM   PLUS MINUS MUL DIV IDIV POW  -> + - * / \ ^
@REM   EQ LT GT LE GE NE            -> = < > <= >= <>
@REM   OPAR CPAR COMA SEMICOLON COLON HASH -> ( ) , ; : #
@REM   EOL                          -> (skipped)
@REM   anything else                -> kept as-is (keyword name)
@REM
@REM Spacing: inserts a single space between two consecutive "word" tokens
@REM (identifiers, numbers, string literals, keywords). No spaces around
@REM operators or punctuation.

if not defined GWSRC set "GWSRC=%~dp0.."

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


@REM --- print "tokens...": assemble and echo to stdout ---
@REM Preferred for displaying (handles `!` correctly).
:print
  setlocal DisableDelayedExpansion
  set _EX=!
  set _Q="
  setlocal EnableDelayedExpansion
  set "_r="
  set "_wasWord="
  for %%t in (%~1) do (
    set "_tok=%%t"
    call :_unlex1 !_tok!
    if defined _out (
      if defined _wasWord if defined _curWord set "_r=!_r! "
      set "_r=!_r!!_out!"
      set "_wasWord=!_curWord!"
    )
  )
  echo(!_r!
  endlocal
  endlocal
  exit /B 0


@REM --- fromTokens "tokens..." retVar ---
@REM Returns unlexed text in retVar. NOTE: if the output contains `!`
@REM (e.g. from VAR_SNG_) and the caller has delayed expansion enabled,
@REM the `!` will be stripped on assignment. Use `print` for LIST-style
@REM output. This entry point is kept for callers that don't embed `!`.
:fromTokens
  setlocal DisableDelayedExpansion
  set _EX=!
  set _Q="
  setlocal EnableDelayedExpansion
  set "_r="
  set "_wasWord="
  for %%t in (%~1) do (
    set "_tok=%%t"
    call :_unlex1 !_tok!
    if defined _out (
      if defined _wasWord if defined _curWord set "_r=!_r! "
      set "_r=!_r!!_out!"
      set "_wasWord=!_curWord!"
    )
  )
  endlocal & set "_r=%_r%"
  endlocal & set "%~2=%_r%" & exit /B 0


@REM Internal: unlex one token.
@REM Sets _out=text (may be empty; undefined means skip with no state change)
@REM Sets _curWord=1 if this token is "word-like" for spacing, else empty
:_unlex1
  set "_t=%~1"
  set "_out="
  set "_curWord="

  @REM Prefixed tokens
  if "!_t:~0,4!"=="LN__" (
    set "_out=!_t:~4!"
    set "_curWord=1"
    exit /B 0
  )
  if "!_t:~0,4!"=="NUM_" (
    set "_nt=!_t:~4,1!"
    if "!_nt!"=="i" call %GWSRC%\num\int toDec !_t:~4!
    if "!_nt!"=="s" call %GWSRC%\num\sng toDec !_t:~4!
    if "!_nt!"=="d" call %GWSRC%\num\dbl toDec !_t:~4!
    set "_out=!__!"
    set "_curWord=1"
    exit /B 0
  )
  if "!_t:~0,4!"=="STR_" (
    call %GWSRC%\str\str decode !_t:~4! _dec
    set "_out=!_Q!!_dec!!_Q!"
    set "_curWord=1"
    exit /B 0
  )
  if "!_t:~0,4!"=="REM_" (
    call %GWSRC%\str\str decode !_t:~4! _dec
    set "_out=!_dec!"
    @REM Body already has its own leading space from lexer — don't add another
    set "_curWord="
    exit /B 0
  )
  if "!_t:~0,4!"=="HEX_" (
    set "_out=^&H!_t:~4!"
    set "_curWord=1"
    exit /B 0
  )
  if "!_t:~0,4!"=="OCT_" (
    set "_out=^&O!_t:~4!"
    set "_curWord=1"
    exit /B 0
  )
  if "!_t:~0,8!"=="VAR_UNK_" (
    set "_out=!_t:~8!"
    set "_curWord=1"
    exit /B 0
  )
  if "!_t:~0,8!"=="VAR_INT_" (
    set "_out=!_t:~8!%%"
    set "_curWord=1"
    exit /B 0
  )
  if "!_t:~0,8!"=="VAR_SNG_" (
    set "_out=!_t:~8!!_EX!"
    set "_curWord=1"
    exit /B 0
  )
  if "!_t:~0,8!"=="VAR_DBL_" (
    set "_out=!_t:~8!#"
    set "_curWord=1"
    exit /B 0
  )
  if "!_t:~0,8!"=="VAR_STR_" (
    set "_out=!_t:~8!$"
    set "_curWord=1"
    exit /B 0
  )

  @REM Fixed-name tokens
  if "!_t!"=="PLUS"      (set "_out=+"  & exit /B 0)
  if "!_t!"=="MINUS"     (set "_out=-"  & exit /B 0)
  if "!_t!"=="MUL"       (set "_out=*"  & exit /B 0)
  if "!_t!"=="DIV"       (set "_out=/"  & exit /B 0)
  if "!_t!"=="IDIV"      (set "_out=\"  & exit /B 0)
  if "!_t!"=="POW"       (set "_out=^^" & exit /B 0)
  if "!_t!"=="EQ"        (set "_out==" & exit /B 0)
  if "!_t!"=="LT"        (set "_out=<" & exit /B 0)
  if "!_t!"=="GT"        (set "_out=>" & exit /B 0)
  if "!_t!"=="LE"        (set "_out=<=" & exit /B 0)
  if "!_t!"=="GE"        (set "_out=>=" & exit /B 0)
  if "!_t!"=="NE"        (set "_out=<>" & exit /B 0)
  if "!_t!"=="OPAR"      (set "_out=(" & exit /B 0)
  if "!_t!"=="CPAR"      (set "_out=)" & exit /B 0)
  if "!_t!"=="COMA"      (set "_out=," & exit /B 0)
  if "!_t!"=="SEMICOLON" (set "_out=;" & exit /B 0)
  if "!_t!"=="COLON"     (set "_out=:" & exit /B 0)
  if "!_t!"=="HASH"      (set "_out=#" & exit /B 0)
  if "!_t!"=="EOL"       (set "_out=" & exit /B 0)

  @REM Fallback: a keyword — emit its name verbatim (acts as word)
  set "_out=!_t!"
  set "_curWord=1"
  exit /B 0


:_start
  echo unlexer.bat - token stream to text
