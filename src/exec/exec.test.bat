@REM Executor tests
@REM Each test: encode → lex → parse → execute, check output

call %test% "exec.calc.add"
  call :_run "PRINT 1+2" " 3"

call %test% "exec.calc.mul"
  call :_run "PRINT 3*4+5" " 17"

call %test% "exec.calc.sub"
  call :_run "PRINT 100-37" " 63"

call %test% "exec.calc.div"
  @REM / always promotes to single (or higher); IDIV (\) is the int-truncating one.
  call :_run "PRINT 10/4" " 2.5"

call %test% "exec.calc.idiv"
  call :_run "PRINT 10\3" " 3"

call %test% "exec.calc.mod"
  call :_run "PRINT 10 MOD 3" " 1"

call %test% "exec.calc.pow"
  @REM Direct postfix to avoid `^` being eaten by CMD escape on the source.
  call :_rexec "NUM_i0002 NUM_i000A POW PEND" " 1024"

call %test% "exec.calc.pow.zero"
  call :_rexec "NUM_i0007 NUM_i0000 POW PEND" " 1"

call %test% "exec.calc.xor"
  call :_run "PRINT 3 XOR 5" " 6"

call %test% "exec.calc.eqv"
  @REM EQV = NOT (a XOR b); 3 EQV 5 = NOT 6 = -7
  @REM Negatives skip the GW-BASIC leading-space placeholder.
  call :_run "PRINT 3 EQV 5" "-7"

call %test% "exec.calc.imp"
  call :_run "PRINT 3 IMP 5" "-3"

call %test% "exec.calc.neg"
  call :_run "PRINT -42" "-42"

call %test% "exec.calc.parens"
  call :_run "PRINT (2+3)*4" " 20"


@REM ============================================================
@REM  Single-line FOR..NEXT (loop body and NEXT on the FOR's line).
@REM  The body lives in the postfix after FOR and is re-run in place;
@REM  see exec.bat :_run_for / :_run_next.
@REM ============================================================

@REM (:_run shares one variable store across cases, so reset S each time.)
call %test% "exec.for.singleline"
  call :_run "S=0:FOR I=1 TO 5:S=S+I:NEXT I:PRINT S" " 15"

call %test% "exec.for.singleline.step"
  call :_run "S=0:FOR I=10 TO 1 STEP -3:S=S+I:NEXT I:PRINT S" " 22"

call %test% "exec.for.singleline.nested"
  call :_run "S=0:FOR I=1 TO 3:FOR J=1 TO 2:S=S+1:NEXT J:NEXT I:PRINT S" " 6"

call %test% "exec.for.singleline.tail"
  @REM Statements after NEXT on the same line run once, after the loop.
  call :_run "S=0:FOR I=1 TO 3:S=S+I:NEXT I:S=S+100:PRINT S" " 106"


@REM ============================================================
@REM  MKI$/MKS$/MKD$ <-> CVI/CVS/CVD (MBF disk byte codecs)
@REM ============================================================

call %test% "fn.mki.cvi.roundtrip"
  call :_run "PRINT CVI(MKI$(258))" " 258"

call %test% "fn.mki.cvi.negative"
  call :_run "PRINT CVI(MKI$(-1))" "-1"

call %test% "fn.mki.len"
  call :_run "PRINT LEN(MKI$(5))" " 2"

call %test% "fn.mks.cvs.roundtrip"
  call :_run "PRINT CVS(MKS$(3.14))" " 3.14"

call %test% "fn.mks.cvs.negative"
  call :_run "PRINT CVS(MKS$(-2.5))" "-2.5"

call %test% "fn.mks.zero"
  call :_run "PRINT CVS(MKS$(0))" " 0"

call %test% "fn.mks.len"
  call :_run "PRINT LEN(MKS$(0))" " 4"

call %test% "fn.mkd.cvd.roundtrip"
  call :_run "PRINT CVD(MKD$(2.5))" " 2.5"

call %test% "fn.mkd.len"
  call :_run "PRINT LEN(MKD$(1))" " 8"


@REM --- INSTR / HEX$ / OCT$  (CHR$ builds strings to avoid quotes in :_run) ---

call %test% "fn.instr.found"
  @REM INSTR("HI","I") = 2
  call :_run "PRINT INSTR(CHR$(72)+CHR$(73),CHR$(73))" " 2"

call %test% "fn.instr.notfound"
  call :_run "PRINT INSTR(CHR$(65),CHR$(66))" " 0"

call %test% "fn.instr.start"
  @REM INSTR(3,"ABAB","AB") = 3 (search from position 3)
  call :_run "PRINT INSTR(3,CHR$(65)+CHR$(66)+CHR$(65)+CHR$(66),CHR$(65)+CHR$(66))" " 3"

call %test% "fn.hex.pos"
  call :_run "PRINT HEX$(255)" "FF"

call %test% "fn.hex.neg"
  call :_run "PRINT HEX$(-1)" "FFFF"

call %test% "fn.oct.pos"
  call :_run "PRINT OCT$(8)" "10"

call %test% "fn.oct.zero"
  call :_run "PRINT OCT$(0)" "0"

call %test% "stmt.swap.scalar"
  call :_run "A=1:B=2:SWAP A,B:PRINT A" " 2"

call %test% "stmt.swap.array.element"
  call :_run "DIM Q(2):Q(0)=5:Q(1)=9:SWAP Q(0),Q(1):PRINT Q(0)" " 9"

call %test% "stmt.erase.then.redim"
  @REM ERASE removes the array so it can be re-DIMmed (fresh, zeroed).
  call :_run "DIM E(2):E(1)=5:ERASE E:DIM E(3):PRINT E(1)" " 0"


@REM --- DEF FN user functions (glued FNname, single/multi-param, save/restore) ---

call %test% "fn.deffn.simple"
  call :_run "DEF FNA(X)=X*2:PRINT FNA(5)" " 10"

call %test% "fn.deffn.multiparam"
  call :_run "DEF FNS(A,B)=A+B*2:PRINT FNS(10,5)" " 20"

call %test% "fn.deffn.body.uses.global"
  call :_run "K=10:DEF FNG(X)=X+K:PRINT FNG(5)" " 15"

call %test% "fn.deffn.restores.param.var"
  @REM The param shadows the global X only during evaluation (dummy-variable
  @REM model); X keeps its outer value 99 afterward.
  call :_run "X=99:DEF FNQ(X)=X*X:Y=FNQ(4):PRINT X" " 99"

call %test% "fn.deffn.nested.call"
  call :_run "DEF FND(X)=X*2:DEF FNE(X)=FND(X)+1:PRINT FNE(3)" " 7"


@REM ============================================================
@REM  WIDTH (no-op) / DEFINT type-range  (MID$ statement: fileops.test.bat)
@REM ============================================================

call %test% "stmt.width.noop"
  call :_run "WIDTH 80:PRINT 7" " 7"

call %test% "stmt.width.device"
  call :_run "WIDTH 80,25:PRINT 9" " 9"

call %test% "stmt.screen.text.noop"
  @REM SCREEN 0 is text mode -> accepted no-op (SCREEN n>0 errors; see errors.test).
  call :_run "SCREEN 0:PRINT 7" " 7"

call %test% "stmt.screen.text.extra.args"
  call :_run "SCREEN 0,0,0:PRINT 8" " 8"

call %test% "stmt.defint.truncates"
  @REM DEFINT X makes X integer; 3.7 -> 3.  Reset with DEFSNG so the shared
  @REM _deftypes table does not leak into later :_run tests.
  call :_run "DEFINT X:X=3.7:PRINT X:DEFSNG X" " 3"

call %test% "stmt.clear.resets.numeric"
  @REM CLEAR zeroes variables but keeps running (whole line is one program).
  call :_run "A=5:CLEAR:PRINT A" " 0"

call %test% "stmt.clear.size.arg.ignored"
  call :_run "CLEAR 5000:PRINT 7" " 7"

call %test% "stmt.clear.comma.forms"
  call :_run "CLEAR ,1000:PRINT 8" " 8"

call %test% "stmt.onkey.trap.parses"
  @REM KEY(n) ON/OFF/STOP arm function-key trapping; accepted (inert headless).
  call :_run "KEY(2) ON:KEY(2) OFF:KEY(2) STOP:PRINT 7" " 7"

call %test% "stmt.onkey.gosub.parses"
  @REM ON KEY(n) GOSUB registers a handler (never fires without key input).
  call :_run "ON KEY(2) GOSUB 100:PRINT 8" " 8"

call %test% "stmt.key.softkey.still.works"
  @REM Ensure the KEY n,str$ soft-key form still parses after adding KEY(n).
  call :_run "KEY 1,A$:PRINT 9" " 9"


@REM ============================================================
@REM  Math built-ins
@REM ============================================================

call %test% "fn.abs.int.neg"
  call :_run "PRINT ABS(-7)" " 7"

call %test% "fn.abs.int.pos"
  call :_run "PRINT ABS(7)" " 7"

call %test% "fn.abs.float"
  call :_run "PRINT ABS(-3.5)" " 3.5"

call %test% "fn.sgn.neg"
  call :_run "PRINT SGN(-5)" "-1"

call %test% "fn.sgn.zero"
  call :_run "PRINT SGN(0)" " 0"

call %test% "fn.sgn.pos"
  call :_run "PRINT SGN(3)" " 1"

call %test% "fn.int.floor.negative"
  @REM INT(-3.5) = -4  (floor toward -inf, NOT trunc toward zero)
  call :_run "PRINT INT(-3.5)" "-4"

call %test% "fn.int.positive"
  call :_run "PRINT INT(3.7)" " 3"

call %test% "fn.fix.trunc.negative"
  @REM FIX(-3.5) = -3  (trunc toward zero)
  call :_run "PRINT FIX(-3.5)" "-3"

call %test% "fn.fix.positive"
  call :_run "PRINT FIX(3.7)" " 3"

call %test% "fn.cint.round.up"
  call :_run "PRINT CINT(3.5)" " 4"

call %test% "fn.cint.round.down"
  call :_run "PRINT CINT(3.4)" " 3"

call %test% "fn.csng"
  call :_run "PRINT CSNG(5)" " 5"

call %test% "fn.cdbl"
  call :_run "PRINT CDBL(5)" " 5"


@REM ============================================================
@REM  PRINT formatting (PTAB comma, SPC, TAB)
@REM ============================================================
@REM Note: <nul set/p strips leading spaces from PSEMI/PTAB-emitted numbers,
@REM so the GW-BASIC " 1" leading-space placeholder isn't preserved inline.
@REM Padding via certutil is preserved, so comma-zones still align.

call %test% "print.tab.padding"
  @REM PRINT 1, 2 — comma-separator pads to next 14-col tab stop.  Inline
  @REM PTAB strips its own leading space (set/p quirk), pads 12 chars,
  @REM then PEND prints " 2" via echo.  Result: "1" + 13 chars + "2".
  call :_run "PRINT 1, 2" "1             2"

call %test% "print.tab.function"
  @REM TAB(10) goes to column 10 (1-based, so 9 chars before).  PSEMI on
  @REM the empty STR sentinel adds nothing; PEND prints " 42".
  call :_run "PRINT TAB(10); 42" "          42"

call %test% "print.spc.function"
  @REM SPC(3) prints 3 spaces; PEND adds " 7".
  call :_run "PRINT SPC(3); 7" "    7"

call %test% "exec.vars.assign"
  @REM Init vars, assign, then print
  @REM Default type is single, so 10 is stored as sng and displayed as 10.
  call %GWSRC%\exec\_vars init
  call :_exec "VAR_UNK_A NUM_i000A ASSIGN"
  call :_run "PRINT A" " 10"

call %test% "exec.vars.assign.int"
  @REM Explicit integer variable — use postfix directly (% can't go through str encode)
  call %GWSRC%\exec\_vars init
  call :_exec "VAR_INT_A NUM_i000A ASSIGN"
  call :_rexec "VAR_INT_A PEND" " 10"

call %test% "exec.vars.namespace"
  @REM I and I! are the same var (default single)
  @REM I% is a different var
  call %GWSRC%\exec\_vars init
  call :_exec "VAR_UNK_I NUM_i0005 ASSIGN"
  call :_exec "VAR_INT_I NUM_i0063 ASSIGN"
  @REM I! should be 5 (stored as single)
  @REM I% should be 99

call %test% "exec.vars.expr"
  @REM Use explicit integer vars for clean output
  call %GWSRC%\exec\_vars init
  call %GWSRC%\exec\_vars defrange A Z i
  call :_exec "VAR_UNK_X NUM_i0005 ASSIGN"
  call :_run "PRINT X+1" " 6"

call %test% "exec.vars.typeof"
  call %GWSRC%\exec\_vars init
  call expect "%GWSRC%\exec\_vars typeof VAR_UNK_A __" "s"
  call expect "%GWSRC%\exec\_vars typeof VAR_INT_A __" "i"
  call expect "%GWSRC%\exec\_vars typeof VAR_STR_A __" "t"

call %test% "exec.vars.defrange"
  call %GWSRC%\exec\_vars init
  call %GWSRC%\exec\_vars defrange A M i
  call expect "%GWSRC%\exec\_vars typeof VAR_UNK_A __" "i"
  call expect "%GWSRC%\exec\_vars typeof VAR_UNK_N __" "s"

exit /B


@REM Helper: full pipeline — encode, lex, parse, execute, capture output
:_run
  set /a numTests+=1
  setlocal EnableDelayedExpansion
  call %GWSRC%\str\str encode "%~1" _hex
  call %GWSRC%\lexer\lexer ParseTxt !_hex! _tokens
  @REM Strip LN__ if present
  set "_first="
  for /f "tokens=1*" %%a in ("!_tokens!") do (
    set "_first=%%a"
    set "_rest=%%b"
  )
  if "!_first:~0,4!"=="LN__" set "_tokens=!_rest!"
  call %GWSRC%\parser\parse parse "!_tokens!" _postfix
  if errorlevel 1 (
    echo FAILED: parse error for "%~1"
    echo.
    endlocal & set /a failedTests+=1
    exit /B
  )
  @REM Capture exec output
  call %GWSRC%\exec\exec run "!_postfix!" > "%GWTEMP%\_test.out" 2>&1
  set /p "_got=" < "%GWTEMP%\_test.out"
  if "!_got!"=="%~2" (
    endlocal & set /a passedTests+=1
  ) else (
    echo FAILED: "%~1"
    echo   Expected: %~2
    echo        Got: !_got!
    echo.
    endlocal & set /a failedTests+=1
  )
  exit /B

@REM Helper: execute postfix directly and check output
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

@REM Helper: execute postfix directly (for setup like assignments)
:_exec
  setlocal EnableDelayedExpansion
  call %GWSRC%\exec\exec run "%~1"
  endlocal
  exit /B
