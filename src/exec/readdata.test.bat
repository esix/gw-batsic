@REM READ / DATA / RESTORE tests.
@REM
@REM Pattern matches input.test.bat: each test writes its own .bas file
@REM inline, runs, and checks the last captured stdout line.


call %test% "read.single.numeric"
  call :_clear
  > "%GWTEMP%\_rd.bas" echo 10 DATA 42
  >>"%GWTEMP%\_rd.bas" echo 20 READ A
  >>"%GWTEMP%\_rd.bas" echo 30 PRINT A
  call :_rdRun " 42"

call %test% "read.multivar"
  call :_clear
  > "%GWTEMP%\_rd.bas" echo 10 DATA 10, 20, 30
  >>"%GWTEMP%\_rd.bas" echo 20 READ A, B, C
  >>"%GWTEMP%\_rd.bas" echo 30 PRINT A + B + C
  call :_rdRun " 60"

call %test% "read.string"
  call :_clear
  > "%GWTEMP%\_rd.bas" echo 10 DATA "hello"
  >>"%GWTEMP%\_rd.bas" echo 20 READ A$
  >>"%GWTEMP%\_rd.bas" echo 30 PRINT A$
  call :_rdRun "hello"

call %test% "read.into.string.array"
  @REM Regression: READ into a string-array element (was Type mismatch).
  call :_clear
  > "%GWTEMP%\_rd.bas" echo 10 DIM K$(3)
  >>"%GWTEMP%\_rd.bas" echo 20 READ K$(1), K$(2), K$(3)
  >>"%GWTEMP%\_rd.bas" echo 30 PRINT K$(1);K$(2);K$(3)
  >>"%GWTEMP%\_rd.bas" echo 40 DATA AAA, BBB, CCC
  call :_rdRun "AAABBBCCC"

call %test% "read.into.numeric.array"
  call :_clear
  > "%GWTEMP%\_rd.bas" echo 10 DIM N(3)
  >>"%GWTEMP%\_rd.bas" echo 20 READ N(1), N(2), N(3)
  >>"%GWTEMP%\_rd.bas" echo 30 PRINT N(1) + N(2) + N(3)
  >>"%GWTEMP%\_rd.bas" echo 40 DATA 11, 22, 33
  call :_rdRun " 66"

call %test% "read.into.2d.array"
  call :_clear
  > "%GWTEMP%\_rd.bas" echo 10 DIM B(2,2)
  >>"%GWTEMP%\_rd.bas" echo 20 READ B(1,1), B(2,2)
  >>"%GWTEMP%\_rd.bas" echo 30 PRINT B(1,1) + B(2,2)
  >>"%GWTEMP%\_rd.bas" echo 40 DATA 5, 9
  call :_rdRun " 14"

call %test% "read.across.lines"
  @REM DATA items across multiple lines should form one queue in line order.
  call :_clear
  > "%GWTEMP%\_rd.bas" echo 10 DATA 1, 2
  >>"%GWTEMP%\_rd.bas" echo 20 DATA 3, 4
  >>"%GWTEMP%\_rd.bas" echo 30 READ A, B, C, D
  >>"%GWTEMP%\_rd.bas" echo 40 PRINT A + B + C + D
  call :_rdRun " 10"

call %test% "read.restore.resets.to.start"
  call :_clear
  > "%GWTEMP%\_rd.bas" echo 10 DATA 5, 6
  >>"%GWTEMP%\_rd.bas" echo 20 READ X, Y
  >>"%GWTEMP%\_rd.bas" echo 30 RESTORE
  >>"%GWTEMP%\_rd.bas" echo 40 READ Z
  >>"%GWTEMP%\_rd.bas" echo 50 PRINT Z
  call :_rdRun " 5"

call %test% "read.restore.line"
  call :_clear
  > "%GWTEMP%\_rd.bas" echo 10 DATA 1, 2
  >>"%GWTEMP%\_rd.bas" echo 20 DATA 100, 200
  >>"%GWTEMP%\_rd.bas" echo 30 RESTORE 20
  >>"%GWTEMP%\_rd.bas" echo 40 READ A
  >>"%GWTEMP%\_rd.bas" echo 50 PRINT A
  call :_rdRun " 100"

call %test% "read.out.of.data"
  call :_clear
  > "%GWTEMP%\_rd.bas" echo 10 DATA 1
  >>"%GWTEMP%\_rd.bas" echo 20 READ A, B
  call :_rdErr 4

call %test% "read.negative.numbers"
  call :_clear
  > "%GWTEMP%\_rd.bas" echo 10 DATA -5, -10
  >>"%GWTEMP%\_rd.bas" echo 20 READ A, B
  >>"%GWTEMP%\_rd.bas" echo 30 PRINT A + B
  call :_rdRun "-15"

call %test% "read.mixed.numeric.string"
  call :_clear
  > "%GWTEMP%\_rd.bas" echo 10 DATA 7, "seven"
  >>"%GWTEMP%\_rd.bas" echo 20 READ N, S$
  >>"%GWTEMP%\_rd.bas" echo 30 PRINT N; S$
  @REM " 7 " (leading sign-space + trailing space) then "seven": " 7 seven".
  call :_rdRun " 7 seven"


exit /B


@REM ----------------------------------------------------------------
@REM  Helpers
@REM ----------------------------------------------------------------

:_clear
  call %GWSRC%\exec\_program init
  call %GWSRC%\exec\_vars init
  call %GWSRC%\exec\_arrays init
  exit /B 0

@REM Run the saved program; expect captured stdout's last line to match.
:_rdRun
  set /a numTests+=1
  setlocal EnableDelayedExpansion
  set "_exp=%~1"
  call %GWSRC%\file\file load "%GWTEMP%\_rd.bas"
  call %GWSRC%\exec\exec runProgram > "%GWTEMP%\_rd.out" 2>&1
  set "_got="
  for /f "usebackq delims=" %%L in ("%GWTEMP%\_rd.out") do set "_got=%%L"
  if "!_got!"=="%_exp%" (
    endlocal & set /a passedTests+=1
  ) else (
    echo FAILED: expected "%_exp%"
    echo        Got: !_got!
    echo.
    endlocal & set /a failedTests+=1
  )
  exit /B 0

@REM Run the saved program; expect _err_code to match.
:_rdErr
  set /a numTests+=1
  setlocal EnableDelayedExpansion
  set "_expCode=%~1"
  call %GWSRC%\file\file load "%GWTEMP%\_rd.bas"
  set "_err_code=0"
  call %GWSRC%\exec\exec runProgram >nul 2>nul
  if "!_err_code!"=="%_expCode%" (
    endlocal & set /a passedTests+=1
  ) else (
    echo FAILED: expected err=%_expCode%
    echo        Got: !_err_code!
    echo.
    endlocal & set /a failedTests+=1
  )
  exit /B 0
