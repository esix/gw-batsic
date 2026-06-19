@REM String operation tests.
@REM
@REM These use pre-parsed postfix (via :_rexec) so they don't depend on
@REM string literals making it through CMD argument quoting — `"` in source
@REM lines gets mangled by `call`'s arg parser, which prevents end-to-end
@REM lex→parse→exec of strings.  Reading samples/05str.bas would hit the
@REM same issue.  Tests go straight to the executor.
@REM
@REM STR_<hex> notation:
@REM   STR_48454C4C4F = "HELLO"  (H=48 E=45 L=4C L=4C O=4F)
@REM   STR_4142       = "AB"
@REM   STR_43         = "C"


@REM ============================================================
@REM  Concatenation via ADD
@REM ============================================================

call %test% "str.concat"
  @REM "AB" + "C" → "ABC"
  call :_rexec "STR_4142 STR_43 ADD PEND" "ABC"

call %test% "str.concat.with.empty"
  @REM "" + "AB" → "AB"
  call :_rexec "STR_ STR_4142 ADD PEND" "AB"


@REM ============================================================
@REM  Built-in functions
@REM ============================================================

call %test% "str.fn.len"
  @REM LEN("HELLO") = 5
  call :_rexec "STR_48454C4C4F FN_LEN PEND" " 5"

call %test% "str.fn.len.empty"
  call :_rexec "STR_ FN_LEN PEND" " 0"

call %test% "str.fn.chr"
  @REM CHR$(65) = "A"
  call :_rexec "NUM_i0041 FN_CHR PEND" "A"

call %test% "str.fn.asc"
  @REM ASC("A") = 65
  call :_rexec "STR_41 FN_ASC PEND" " 65"

call %test% "str.fn.left"
  @REM LEFT$("HELLO", 3) = "HEL"
  call :_rexec "STR_48454C4C4F NUM_i0003 FN_LEFT PEND" "HEL"

call %test% "str.fn.left.zero"
  call :_rexec "STR_48454C4C4F NUM_i0000 FN_LEFT PEND" ""

call %test% "str.fn.right"
  @REM RIGHT$("HELLO", 2) = "LO"
  call :_rexec "STR_48454C4C4F NUM_i0002 FN_RIGHT PEND" "LO"

call %test% "str.fn.right.past.length"
  @REM RIGHT$("HI", 10) = "HI"
  call :_rexec "STR_4849 NUM_i000A FN_RIGHT PEND" "HI"

call %test% "str.fn.mid.3arg"
  @REM MID$("HELLO", 2, 3) = "ELL"
  call :_rexec "STR_48454C4C4F NUM_i0002 NUM_i0003 FN_MID PEND" "ELL"

call %test% "str.fn.mid.2arg"
  @REM MID$("HELLO", 3) = "LLO" (no length, take to end)
  @REM Grammar's @MID_DEFAULT_LEN pushes the sentinel — simulate directly.
  call :_rexec "STR_48454C4C4F NUM_i0003 MID_DEFAULT_LEN FN_MID PEND" "LLO"

call %test% "str.fn.space"
  @REM SPACE$(4) = "    "  (4 spaces)
  call :_rexec "NUM_i0004 FN_SPACE PEND" "    "

call %test% "str.fn.str.positive"
  @REM STR$(42) = " 42"   (leading space placeholder)
  call :_rexec "NUM_i002A FN_STR PEND" " 42"

call %test% "str.fn.str.negative"
  @REM STR$(-5) = "-5"
  call :_rexec "NUM_iFFFB FN_STR PEND" "-5"

call %test% "str.fn.val.numeric"
  @REM VAL("3.14") = 3.14
  call :_rexec "STR_332E3134 FN_VAL PEND" " 3.14"

call %test% "str.fn.val.trailing.garbage"
  @REM VAL("12XYZ") parses leading numeric, ignores rest.
  call :_rexec "STR_31325859 FN_VAL PEND" " 12"

call %test% "str.fn.val.nonnumeric"
  @REM VAL("abc") = 0
  call :_rexec "STR_616263 FN_VAL PEND" " 0"


@REM ============================================================
@REM  Comparison
@REM ============================================================

call %test% "str.cmp.eq.same"
  @REM "AB" = "AB" → -1 (true)
  call :_rexec "STR_4142 STR_4142 CMP_EQ PEND" "-1"

call %test% "str.cmp.eq.different"
  @REM "AB" = "AC" → 0 (false)
  call :_rexec "STR_4142 STR_4143 CMP_EQ PEND" " 0"

call %test% "str.cmp.lt"
  @REM "AB" < "AC" → -1 (true)
  call :_rexec "STR_4142 STR_4143 CMP_LT PEND" "-1"

call %test% "str.cmp.lt.shorter.prefix"
  @REM "AB" < "ABC" → -1
  call :_rexec "STR_4142 STR_414243 CMP_LT PEND" "-1"

call %test% "str.cmp.gt.longer"
  @REM "ABC" > "AB" → -1
  call :_rexec "STR_414243 STR_4142 CMP_GT PEND" "-1"

call %test% "str.cmp.ne"
  @REM "AB" <> "AC" → -1
  call :_rexec "STR_4142 STR_4143 CMP_NE PEND" "-1"


call %test% "print.pzone.empty.zone"
  @REM PZONE advances to the next 14-column zone without popping a value.
  @REM PRINT ,"B": the leading comma pads columns 0-13, B lands at 14.
  call :_rexec "PZONE STR_42 PEND" "              B"
  @REM PRINT "A",,"B": PTAB prints A and pads to 14, PZONE pads to 28.
  call :_rexec "STR_41 PTAB PZONE STR_42 PEND" "A                           B"

call %test% "str.fn.string"
  @REM STRING$(10,42) -> ten "*" (42 = ASCII "*")
  call :_rexec "NUM_i000A NUM_i002A FN_STRING PEND" "**********"
  @REM STRING$(3,"AB") -> first char repeated -> "AAA"
  call :_rexec "NUM_i0003 STR_4142 FN_STRING PEND" "AAA"
  @REM STRING$(0,"X") -> empty string
  call :_rexec "NUM_i0000 STR_58 FN_STRING PEND" ""

exit /B

@REM Helper: execute postfix directly and check output (same as exec.test.bat;
@REM `call :label` can't reach labels in another file, so each test file
@REM needs its own copy).
:_rexec
  set /a numTests+=1
  setlocal EnableDelayedExpansion
  call %GWSRC%\exec\exec run "%~1" > "%GWTEMP%\_test.out" 2>&1
  set /p "_got=" < "%GWTEMP%\_test.out"
  if "!_got!"=="%~2" (
    endlocal & set /a passedTests+=1
  ) else (
    echo FAILED: exec "%~1"
    echo   Expected: %~2
    echo        Got: !_got!
    echo.
    endlocal & set /a failedTests+=1
  )
  exit /B
