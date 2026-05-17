@REM Error message tests.
@REM
@REM Each test:
@REM   1. _clear            — fresh program / vars / arrays state
@REM   2. _addLine "10 ..."  — encode + lex + store in _program
@REM   3. _progErr CODE LINE — runProgram and check ERR / ERL match
@REM
@REM We check _err_code / _err_line directly (rather than capturing stdout)
@REM because (a) those are the ground truth that the central printer formats
@REM from, and (b) capturing stdout into a single tempfile across many tests
@REM hits file-lock races on Windows.
@REM
@REM The end-to-end printed format ("Message in <line>") is exercised by one
@REM dedicated test that captures stdout once.


@REM ============================================================
@REM  Arithmetic
@REM ============================================================

call %test% "err.divbyzero.int"
  call :_clear
  call :_addLine "10 PRINT 1 / 0"
  call :_progErr 11 10

call %test% "err.divbyzero.float"
  call :_clear
  call :_addLine "10 PRINT 1.5 / 0"
  call :_progErr 11 10


@REM ============================================================
@REM  Control flow
@REM ============================================================

call %test% "err.goto.undefined.line"
  call :_clear
  call :_addLine "10 GOTO 999"
  call :_progErr 8 10

call %test% "err.gosub.undefined.line"
  call :_clear
  call :_addLine "10 GOSUB 999"
  call :_progErr 8 10

call %test% "err.return.without.gosub"
  call :_clear
  call :_addLine "10 RETURN"
  call :_progErr 3 10


@REM ============================================================
@REM  Arrays
@REM ============================================================

call %test% "err.subscript.upper"
  call :_clear
  call :_addLine "10 DIM A(3)"
  call :_addLine "20 PRINT A(10)"
  call :_progErr 9 20

call %test% "err.duplicate.definition"
  call :_clear
  call :_addLine "10 DIM A(3)"
  call :_addLine "20 DIM A(5)"
  call :_progErr 10 20

call %test% "err.line.reported.is.failing.line"
  call :_clear
  call :_addLine "10 DIM A(3)"
  call :_addLine "20 X = 1"
  call :_addLine "30 PRINT A(99)"
  call :_progErr 9 30


@REM ============================================================
@REM  No error
@REM ============================================================

call %test% "err.end.clears.no.error"
  call :_clear
  call :_addLine "10 END"
  call :_progErr 0 0

call %test% "err.stop.is.not.an.error"
  @REM STOP halts with "Break in <line>" but doesn't set ERR.
  call :_clear
  call :_addLine "10 STOP"
  call :_progErr 0 0


@REM ============================================================
@REM  End-to-end formatting test — captured stdout matches "Msg in <line>"
@REM ============================================================

call %test% "err.message.format.in.line"
  call :_clear
  call :_addLine "10 PRINT 1 / 0"
  call :_progStdoutEndsWith "Division by zero in 10"

call %test% "err.message.format.subscript"
  call :_clear
  call :_addLine "10 DIM A(3)"
  call :_addLine "20 PRINT A(50)"
  call :_progStdoutEndsWith "Subscript out of range in 20"


exit /B


@REM ----------------------------------------------------------------
@REM  Helpers
@REM ----------------------------------------------------------------

@REM Reset program / vars / arrays state before each test.
:_clear
  call %GWSRC%\exec\_program init
  call %GWSRC%\exec\_vars init
  call %GWSRC%\exec\_arrays init
  exit /B 0

@REM Encode + lex one source line, store in _program.
:_addLine
  setlocal EnableDelayedExpansion
  call %GWSRC%\str\str encode "%~1" _h
  call %GWSRC%\lexer\lexer ParseTxt !_h! _t
  set "_first="
  for /f "tokens=1*" %%a in ("!_t!") do set "_first=%%a"
  if "!_first:~0,4!"=="LN__" call %GWSRC%\exec\_program add !_first:~4! "!_t!"
  endlocal & exit /B 0

@REM Run program and verify _err_code and _err_line.
@REM Usage: _progErr <expected_code> <expected_line>
:_progErr
  set /a numTests+=1
  set "_expCode=%~1"
  set "_expLine=%~2"
  setlocal EnableDelayedExpansion
  set "_err_code=0"
  set "_err_line=0"
  @REM Suppress the printed message — we only want to check ERR / ERL here.
  call %GWSRC%\exec\exec runProgram >nul 2>nul
  set "_gotCode=!_err_code!"
  set "_gotLine=!_err_line!"
  if "!_gotCode!"=="%_expCode%" if "!_gotLine!"=="%_expLine%" (
    endlocal & set /a passedTests+=1 & exit /B 0
  )
  echo FAILED: expected ERR=%_expCode% ERL=%_expLine%
  echo        Got: ERR=!_gotCode! ERL=!_gotLine!
  echo.
  endlocal & set /a failedTests+=1
  exit /B 0

@REM Run program and verify the last line of captured stdout matches.  Uses a
@REM per-test unique tempfile to dodge inter-test file-lock races.
:_progStdoutEndsWith
  set /a numTests+=1
  setlocal EnableDelayedExpansion
  set "_of=%GWTEMP%\_errfmt_!numTests!.out"
  del "!_of!" 2>nul
  call %GWSRC%\exec\exec runProgram > "!_of!" 2>&1
  set "_got="
  for /f "usebackq delims=" %%L in ("!_of!") do set "_got=%%L"
  del "!_of!" 2>nul
  if "!_got!"=="%~1" (
    endlocal & set /a passedTests+=1
  ) else (
    echo FAILED: expected last line "%~1"
    echo        Got: !_got!
    echo.
    endlocal & set /a failedTests+=1
  )
  exit /B 0
