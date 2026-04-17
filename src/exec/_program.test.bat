@REM Program storage tests

call %test% "_program.init.empty"
  call %GWSRC%\exec\_program init
  call expect "%GWSRC%\exec\_program get 10 __" ""

call %test% "_program.add.get"
  call %GWSRC%\exec\_program init
  call %GWSRC%\exec\_program add 10 "LN__10 PRINT NUM_i0001 EOL"
  call expect "%GWSRC%\exec\_program get 10 __" "LN__10 PRINT NUM_i0001 EOL"

call %test% "_program.add.replace"
  call %GWSRC%\exec\_program init
  call %GWSRC%\exec\_program add 10 "LN__10 PRINT NUM_i0001 EOL"
  call %GWSRC%\exec\_program add 10 "LN__10 PRINT NUM_i0002 EOL"
  call expect "%GWSRC%\exec\_program get 10 __" "LN__10 PRINT NUM_i0002 EOL"

call %test% "_program.del"
  call %GWSRC%\exec\_program init
  call %GWSRC%\exec\_program add 10 "LN__10 PRINT NUM_i0001 EOL"
  call %GWSRC%\exec\_program del 10
  call expect "%GWSRC%\exec\_program get 10 __" ""

call %test% "_program.multi"
  call %GWSRC%\exec\_program init
  call %GWSRC%\exec\_program add 20 "LN__20 PRINT NUM_i0014 EOL"
  call %GWSRC%\exec\_program add 10 "LN__10 PRINT NUM_i000A EOL"
  call %GWSRC%\exec\_program add 100 "LN__100 PRINT NUM_i0064 EOL"
  call expect "%GWSRC%\exec\_program get 10 __"  "LN__10 PRINT NUM_i000A EOL"
  call expect "%GWSRC%\exec\_program get 20 __"  "LN__20 PRINT NUM_i0014 EOL"
  call expect "%GWSRC%\exec\_program get 100 __" "LN__100 PRINT NUM_i0064 EOL"

call %test% "_program.list.sorted"
  @REM Insert out of order; LIST must show them sorted and unlexed
  call %GWSRC%\exec\_program init
  call %GWSRC%\exec\_program add 20 "LN__20 PRINT NUM_i0014 EOL"
  call %GWSRC%\exec\_program add 10 "LN__10 PRINT NUM_i000A EOL"
  call %GWSRC%\exec\_program add 5  "LN__5 REM REM_204845 EOL"
  call :_listLine 1 "5 REM HE"
  call :_listLine 2 "10 PRINT 10"
  call :_listLine 3 "20 PRINT 20"

exit /B


@REM Helper: assert Nth line of LIST output equals expected text.
:_listLine
  set /a numTests+=1
  setlocal EnableDelayedExpansion
  set "_n=%~1"
  set "_expected=%~2"
  call %GWSRC%\exec\_program list > "%GWTEMP%\_plist.out" 2>&1
  set "_got="
  set /a "_i=0"
  for /f "usebackq delims=" %%L in ("%GWTEMP%\_plist.out") do (
    set /a "_i+=1"
    if !_i!==!_n! set "_got=%%L"
  )
  if "!_got!"=="!_expected!" (
    endlocal & set /a passedTests+=1
  ) else (
    echo FAILED: _program list line !_n!
    echo   Expected: !_expected!
    echo        Got: !_got!
    endlocal & set /a failedTests+=1
  )
  exit /B
