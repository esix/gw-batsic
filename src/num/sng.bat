@echo off
@REM GW-BASIC single-precision float facade (MBF 4-byte)
@REM Tagged representation: "s" prefix + 8-char hex (xdword)
@REM
@REM Usage: call sng <op> [args...]
@REM
@REM Conversion (GW-BASIC equivalents):
@REM   sng fromInt i007B    -> __ = "s82FB0000"    CSNG(123)
@REM   sng toInt s82FB0000  -> __ = "i007B"         CINT(123.0)
@REM
@REM Unary (GW-BASIC equivalents):
@REM   sng neg s80000000    -> negate               unary -
@REM   sng abs s80800000    -> absolute value        ABS()
@REM
@REM Error 6  = Overflow
@REM Error 13 = Type mismatch

set "PATH=%~dp0;%PATH%"
if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:fromInt
  setlocal EnableDelayedExpansion
  set "a=%~1"
  if "!a:~0,1!" neq "i" endlocal & exit /B 13
  call _mbfs fromInt !a:~1!
  endlocal & set "__=s%__%" & exit /B 0


:fromDec
  setlocal EnableDelayedExpansion
  call _mbfs fromDec %~1
  if errorlevel 1 (endlocal & exit /B !ERRORLEVEL!)
  endlocal & set "__=s%__%" & exit /B 0

:toDec
  setlocal EnableDelayedExpansion
  set "a=%~1"
  if "!a:~0,1!" neq "s" endlocal & exit /B 13
  call _mbfs toDec !a:~1!
  endlocal & set "__=%__%" & exit /B 0

:toInt
  setlocal EnableDelayedExpansion
  set "a=%~1"
  if "!a:~0,1!" neq "s" endlocal & exit /B 13
  call _mbfs toInt !a:~1!
  set "e=%ERRORLEVEL%"
  if %e% neq 0 (endlocal & exit /B %e%)
  endlocal & set "__=i%__%" & exit /B 0


:neg
  setlocal EnableDelayedExpansion
  set "a=%~1"
  if "!a:~0,1!" neq "s" endlocal & exit /B 13
  call _mbfs neg !a:~1!
  endlocal & set "__=s%__%" & exit /B 0


:abs
  setlocal EnableDelayedExpansion
  set "a=%~1"
  if "!a:~0,1!" neq "s" endlocal & exit /B 13
  call _mbfs abs !a:~1!
  endlocal & set "__=s%__%" & exit /B 0


:add
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "s" endlocal & exit /B 13
  if "!b:~0,1!" neq "s" endlocal & exit /B 13
  call _mbfs add !a:~1! !b:~1!
  set "e=%ERRORLEVEL%"
  if %e% neq 0 (endlocal & exit /B %e%)
  endlocal & set "__=s%__%" & exit /B 0


:sub
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "s" endlocal & exit /B 13
  if "!b:~0,1!" neq "s" endlocal & exit /B 13
  call _mbfs sub !a:~1! !b:~1!
  set "e=%ERRORLEVEL%"
  if %e% neq 0 (endlocal & exit /B %e%)
  endlocal & set "__=s%__%" & exit /B 0


:mul
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "s" endlocal & exit /B 13
  if "!b:~0,1!" neq "s" endlocal & exit /B 13
  call _mbfs mul !a:~1! !b:~1!
  set "e=%ERRORLEVEL%"
  if %e% neq 0 (endlocal & exit /B %e%)
  endlocal & set "__=s%__%" & exit /B 0


:div
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "s" endlocal & exit /B 13
  if "!b:~0,1!" neq "s" endlocal & exit /B 13
  if "!b:~1,2!"=="00" (endlocal & exit /B 11)
  call _mbfs div !a:~1! !b:~1!
  set "e=%ERRORLEVEL%"
  if %e% neq 0 (endlocal & exit /B %e%)
  endlocal & set "__=s%__%" & exit /B 0


:cmp
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "s" endlocal & exit /B 13
  if "!b:~0,1!" neq "s" endlocal & exit /B 13
  call _mbfs cmp !a:~1! !b:~1!
  endlocal & set "__=%__%" & exit /B 0


:_start
  setlocal EnableDelayedExpansion
  echo Single calculator. Enter: NUMBER + NUMBER (empty to quit)
:_repl
  set "_in="
  set /p "_in=> " || goto :_repl_end
  if "!_in!"=="" goto :_repl_end
  for /f "tokens=1,2,3" %%a in ("!_in!") do (
    set "_a=%%a"& set "_op=%%b"& set "_b=%%c"
  )
  call %~dp0sng.bat fromDec !_a!
  set "_va=!__!"
  call %~dp0sng.bat fromDec !_b!
  set "_vb=!__!"
  if "!_op!"=="+" call %~dp0sng.bat add !_va! !_vb!
  if "!_op!"=="-" call %~dp0sng.bat sub !_va! !_vb!
  if "!_op!"=="*" call %~dp0sng.bat mul !_va! !_vb!
  if "!_op!"=="/" call %~dp0sng.bat div !_va! !_vb!
  call %~dp0sng.bat toDec !__!
  echo !__!
  goto :_repl
:_repl_end
  endlocal
