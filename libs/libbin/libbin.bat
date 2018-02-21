@echo off
  if "%~1"=="" (call :usage) else call :%*
exit /b


:usage                             -- Library syntax and general info
::
::  libbin.bat is a callable library of batch functions used to manipulate
::  bits and simple integer arithmetics
::
::  Supported three hex types
::      - x32 - 32 bit (4 bytes) hex value
::      - x16 - 16 bit (2 bytes)
::      - x8  - 8 bit (1 byte)
::
::  Values a saved in strings of lengths 8, 4, 2 chars
::
::  syntax:
::
::    [call] [path]libbin function [arguments]
::
::  For a full list of available functions use:
::
::     libbin help
::
::  For detailed help on a specific function use:
::
::     libbin help FunctionName
::
::  All library functions give the correct result regardless whether delayed
::  expansion is enabled or disabled at the time of the call!
::
:::
::: Dependencies - :help
:::
  call :help Usage
exit /b


:help    [ /I | FuncName ]         -- Help for this library
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



:x16      DecInt [result]    -- convert a decimal number to hexadecimal, i.e. -20 to FFFFFFEC or 26 to 0000001A
::                           -- DecInt [in]      - decimal number to convert
::                           -- result [out,opt] - variable to store the converted hexadecimal number in
::  Ex:
::   -20 => FFEC
::    26 => 001A
::  Sets RtnVar to result
::  or displays result if RtnVar not specified
::
  setlocal enableDelayedExpansion
  set "dec=!%~1!"
  set "error=0"
  echo !dec!| findstr /r /B /E "[\-+]*[0-9][0-9]*" >nul 2>&1
  if errorlevel 1 set "error=2"
  set "hex="
  set /a "rest=dec&0xffff0000"

  if NOT [!rest!]==[0] if NOT [!rest!]==[-65536]  set "error=1"

  set "map=0123456789ABCDEF"
  for /L %%N in (1,1,4) do (
    set /a "d=dec&15,dec>>=4"
    for %%D in (!d!) do set "hex=!map:~%%D,1!!hex!"
)
( endlocal & REM return value
  if "%~2" neq "" (set %~2=%hex%) else echo:%hex%
  exit /b %error%)


:x8    dec [hex]       -- convert a decimal number to hexadecimal, i.e. -20 to FFFFFFEC or 26 to 0000001A
::                      -- dect [in]      - decimal number to convert
::                      -- hex [out,opt]   - variable to store the converted hexadecimal number
::  Ex:
::   -20 => EC
::    26 => 1A
::   566 => 36, errorlevel=2
::
::  Sets `hex` argument to result  or displays result if `hex` not specified
::
::  input value dec chould be in range:
::     [-128..255]
::
::  ERRORLEVEL is
::   1 - not a number
::   2 - number too big to fit in one byte
::
  setlocal enableDelayedExpansion
  set "dec=!%~1!"
  set "error=0"
  echo !dec!| findstr /r /B /E "[\-+]*[0-9][0-9]*" >nul 2>&1
  if errorlevel 1 set "error=2"
  set "hex="
  set /a "rest=dec&0xffffff00"

  if NOT [!rest!]==[0] if NOT [!rest!]==[-256]  set "error=1"

  set "map=0123456789ABCDEF"
  for /L %%N in (1,1,2) do (
    set /a "d=dec&15,dec>>=4"
    for %%D in (!d!) do set "hex=!map:~%%D,1!!hex!"
  )
( endlocal & REM return value
  if "%~2" neq "" (set %~2=%hex%) else echo:%hex%
  exit /b %error%)



:u   Hex  [result]       -- converts hex string to decimal unsigned integer
::                       -- Hex [in]    - hex value to convert, 
::                                        of len 2, 4 or 8 chars
::                       -- result [out, opt] - variable name to store 
::                                              decimal value
::
  setlocal enableDelayedExpansion
  set "Hex=%~1"
  set "result="
  set /A "result=0x!Hex!"
( endlocal & REM return value
    if "%~2" neq "" (set %~2=%result%) else echo:%result%
)
exit /b
