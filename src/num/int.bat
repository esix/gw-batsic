@echo off
@REM GW-BASIC integer facade (16-bit signed, -32768..32767)
@REM Tagged representation: "i" prefix + 4-char hex (xword), two's complement
@REM
@REM Usage: call int <op> [args...]
@REM Returns result in __ (and __r for div/mod)
@REM
@REM Conversion:
@REM   int fromDec 123      -> __ = "i007B"
@REM   int toDec i007B      -> __ = "123"
@REM
@REM Arithmetic (GW-BASIC operators):
@REM   int add i0001 i0002  -> __ = "i0003"     +
@REM   int sub i0005 i0003  -> __ = "i0002"     -
@REM   int mul i0003 i0004  -> __ = "i000C"     *
@REM   int div i0007 i0002  -> __ = "i0003", __r = "i0001"   \ and MOD
@REM   int neg iFFFF        -> __ = "i0001"     unary -
@REM
@REM Bitwise (GW-BASIC operators):
@REM   int and i00FF i0F0F  -> AND
@REM   int or  i00F0 i000F  -> OR
@REM   int xor iFFFF iFFFF  -> XOR
@REM   int inv i0000        -> NOT (inv because "not" is reserved in batch)
@REM
@REM Error 13 = Type mismatch (wrong prefix)

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:fromDec
  call _xword fromDec %~1
  if errorlevel 1 exit /B %ERRORLEVEL%
  set "__=i%__%"
  exit /B 0

:toDec
  setlocal EnableDelayedExpansion
  set "a=%~1"
  if "!a:~0,1!" neq "i" endlocal & exit /B 13
  call _xword toDec !a:~1!
  endlocal & set "__=%__%" & exit /B 0


:neg
  setlocal EnableDelayedExpansion
  set "a=%~1"
  if "!a:~0,1!" neq "i" endlocal & exit /B 13
  call _xword neg !a:~1!
  endlocal & set "__=i%__%" & exit /B 0

:inv
  setlocal EnableDelayedExpansion
  set "a=%~1"
  if "!a:~0,1!" neq "i" endlocal & exit /B 13
  call _xword inv !a:~1!
  endlocal & set "__=i%__%" & exit /B 0


:add
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "i" endlocal & exit /B 13
  if "!b:~0,1!" neq "i" endlocal & exit /B 13
  call _xword add !a:~1! !b:~1!
  endlocal & set "__=i%__%" & exit /B 0

:sub
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "i" endlocal & exit /B 13
  if "!b:~0,1!" neq "i" endlocal & exit /B 13
  call _xword sub !a:~1! !b:~1!
  endlocal & set "__=i%__%" & exit /B 0

:mul
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "i" endlocal & exit /B 13
  if "!b:~0,1!" neq "i" endlocal & exit /B 13
  call _xword smul !a:~1! !b:~1!
  endlocal & set "__=i%__%" & exit /B 0

:div
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "i" endlocal & exit /B 13
  if "!b:~0,1!" neq "i" endlocal & exit /B 13
  if "!b:~1!"=="0000" endlocal & exit /B 11
  call _xword sdiv !a:~1! !b:~1!
  endlocal & set "__=i%__%" & set "__r=i%__r%" & exit /B 0

:and
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "i" endlocal & exit /B 13
  if "!b:~0,1!" neq "i" endlocal & exit /B 13
  call _xword and !a:~1! !b:~1!
  endlocal & set "__=i%__%" & exit /B 0

:or
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "i" endlocal & exit /B 13
  if "!b:~0,1!" neq "i" endlocal & exit /B 13
  call _xword or !a:~1! !b:~1!
  endlocal & set "__=i%__%" & exit /B 0

:xor
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "i" endlocal & exit /B 13
  if "!b:~0,1!" neq "i" endlocal & exit /B 13
  call _xword xor !a:~1! !b:~1!
  endlocal & set "__=i%__%" & exit /B 0


:_start
echo int.bat - GW-BASIC 16-bit signed integer facade
