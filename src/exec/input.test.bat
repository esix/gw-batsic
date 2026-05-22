@REM INPUT statement tests.
@REM
@REM Each test writes its own .bas file inline (avoiding `call`-arg quoting
@REM issues with `"` in source) and a stdin file, then calls :_inputRun with
@REM the expected output's last line.


call %test% "input.single.numeric"
  call :_clear
  > "%GWTEMP%\_input.bas" echo 10 INPUT A
  >>"%GWTEMP%\_input.bas" echo 20 PRINT A * 2
  call :_inputRun "42" "?  84"

call %test% "input.prompt.string"
  call :_clear
  > "%GWTEMP%\_input.bas" echo 10 INPUT "Name? "; N$
  >>"%GWTEMP%\_input.bas" echo 20 PRINT N$
  call :_inputRun "Alice" "Name? Alice"

call %test% "input.multivar"
  call :_clear
  > "%GWTEMP%\_input.bas" echo 10 INPUT A, B
  >>"%GWTEMP%\_input.bas" echo 20 PRINT A + B
  call :_inputRun "10, 20" "?  30"

call %test% "input.string.case.preserved"
  @REM Verifies that encodeRaw keeps lowercase letters in user input.
  call :_clear
  > "%GWTEMP%\_input.bas" echo 10 INPUT N$
  >>"%GWTEMP%\_input.bas" echo 20 PRINT N$
  call :_inputRun "MixedCase" "? MixedCase"


exit /B


@REM ----------------------------------------------------------------
@REM  Helpers
@REM ----------------------------------------------------------------

:_clear
  call %GWSRC%\exec\_program init
  call %GWSRC%\exec\_vars init
  call %GWSRC%\exec\_arrays init
  exit /B 0

@REM Load _input.bas, write stdin, run, check last line of stdout.
:_inputRun
  set /a numTests+=1
  setlocal EnableDelayedExpansion
  set "_stdin=%~1"
  set "_exp=%~2"
  call %GWSRC%\file\file load "%GWTEMP%\_input.bas"
  > "%GWTEMP%\_input.txt" echo !_stdin!
  call %GWSRC%\exec\exec runProgram < "%GWTEMP%\_input.txt" > "%GWTEMP%\_input.out" 2>&1
  set "_got="
  for /f "usebackq delims=" %%L in ("%GWTEMP%\_input.out") do set "_got=%%L"
  if "!_got!"=="%_exp%" (
    endlocal & set /a passedTests+=1
  ) else (
    echo FAILED: stdin "%_stdin%"
    echo   Expected: %_exp%
    echo        Got: !_got!
    echo.
    endlocal & set /a failedTests+=1
  )
  exit /B 0
