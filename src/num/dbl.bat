@echo off
@REM GW-BASIC double-precision float facade (MBF 8-byte)
@REM Tagged representation: "d" prefix + 16-char hex (xqword)
@REM Error 6=Overflow, 11=Division by zero, 13=Type mismatch

set "PATH=%~dp0;%PATH%"
if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%

:fromDec
  setlocal EnableDelayedExpansion
  call _mbfd fromDec %~1
  if errorlevel 1 (endlocal & exit /B !ERRORLEVEL!)
  endlocal & set "__=d%__%" & exit /B 0

:toDec
  setlocal EnableDelayedExpansion
  set "a=%~1"
  if "!a:~0,1!" neq "d" endlocal & exit /B 13
  call _mbfd toDec !a:~1!
  endlocal & set "__=%__%" & exit /B 0

:fromInt
  setlocal EnableDelayedExpansion
  set "a=%~1"
  if "!a:~0,1!" neq "i" endlocal & exit /B 13
  call _mbfd fromInt !a:~1!
  endlocal & set "__=d%__%" & exit /B 0

:toInt
  setlocal EnableDelayedExpansion
  set "a=%~1"
  if "!a:~0,1!" neq "d" endlocal & exit /B 13
  call _mbfd toInt !a:~1!
  set "e=%ERRORLEVEL%"
  if %e% neq 0 (endlocal & exit /B %e%)
  endlocal & set "__=i%__%" & exit /B 0

:neg
  setlocal EnableDelayedExpansion
  set "a=%~1"
  if "!a:~0,1!" neq "d" endlocal & exit /B 13
  call _mbfd neg !a:~1!
  endlocal & set "__=d%__%" & exit /B 0

:abs
  setlocal EnableDelayedExpansion
  set "a=%~1"
  if "!a:~0,1!" neq "d" endlocal & exit /B 13
  call _mbfd abs !a:~1!
  endlocal & set "__=d%__%" & exit /B 0

:add
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "d" endlocal & exit /B 13
  if "!b:~0,1!" neq "d" endlocal & exit /B 13
  call _mbfd add !a:~1! !b:~1!
  set "e=%ERRORLEVEL%"
  if %e% neq 0 (endlocal & exit /B %e%)
  endlocal & set "__=d%__%" & exit /B 0

:sub
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "d" endlocal & exit /B 13
  if "!b:~0,1!" neq "d" endlocal & exit /B 13
  call _mbfd sub !a:~1! !b:~1!
  set "e=%ERRORLEVEL%"
  if %e% neq 0 (endlocal & exit /B %e%)
  endlocal & set "__=d%__%" & exit /B 0

:mul
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "d" endlocal & exit /B 13
  if "!b:~0,1!" neq "d" endlocal & exit /B 13
  call _mbfd mul !a:~1! !b:~1!
  set "e=%ERRORLEVEL%"
  if %e% neq 0 (endlocal & exit /B %e%)
  endlocal & set "__=d%__%" & exit /B 0

:div
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "d" endlocal & exit /B 13
  if "!b:~0,1!" neq "d" endlocal & exit /B 13
  if "!b:~1,2!"=="00" (endlocal & exit /B 11)
  call _mbfd div !a:~1! !b:~1!
  set "e=%ERRORLEVEL%"
  if %e% neq 0 (endlocal & exit /B %e%)
  endlocal & set "__=d%__%" & exit /B 0

:cmp
  setlocal EnableDelayedExpansion
  set "a=%~1"& set "b=%~2"
  if "!a:~0,1!" neq "d" endlocal & exit /B 13
  if "!b:~0,1!" neq "d" endlocal & exit /B 13
  call _mbfd cmp !a:~1! !b:~1!
  endlocal & set "__=%__%" & exit /B 0

:_start
  setlocal EnableDelayedExpansion
  echo Double calculator. Enter: NUMBER + NUMBER (empty to quit)
:_repl
  set "_in="
  set /p "_in=> " || goto :_repl_end
  if "!_in!"=="" goto :_repl_end
  for /f "tokens=1,2,3" %%a in ("!_in!") do (
    set "_a=%%a"& set "_op=%%b"& set "_b=%%c"
  )
  call %~dp0dbl.bat fromDec !_a!
  set "_va=!__!"
  call %~dp0dbl.bat fromDec !_b!
  set "_vb=!__!"
  if "!_op!"=="+" call %~dp0dbl.bat add !_va! !_vb!
  if "!_op!"=="-" call %~dp0dbl.bat sub !_va! !_vb!
  if "!_op!"=="*" call %~dp0dbl.bat mul !_va! !_vb!
  if "!_op!"=="/" call %~dp0dbl.bat div !_va! !_vb!
  call %~dp0dbl.bat toDec !__!
  echo !__!
  goto :_repl
:_repl_end
  endlocal
