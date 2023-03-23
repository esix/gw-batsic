::
:: TODO: check if binary file and parse other way
::

@echo off
setlocal EnableDelayedExpansion

set line=

:Loop
  set /p input=
  if ERRORLEVEL 1 (
    set input=0A
  )
  :: echo input=%input%

  for %%b in (%input%) do (
    rem call :onNextChar %%b
    set isEol=
    if %%b==0D set isEol=T
    if %%b==0A set isEol=T

    if defined isEol (
      if defined line (
        echo %line%
      )
      set line=
    ) else (
      set line=!line!%%b
    )
  )

  if not "%input%"=="0A" goto :Loop

:End
  endlocal
