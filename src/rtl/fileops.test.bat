@REM File-management op tests (FILES / KILL / NAME / RESET).
@REM All paths are absolute under %GWTEMP% so the ops never touch the repo
@REM working directory.  We assert both the GW error code (_err_code) and the
@REM real filesystem effect (if exist).

if not defined GWTEMP set "GWTEMP=%~dp0..\..\temp"

del /Q "%GWTEMP%\fo_*.txt" >nul 2>nul

call %test% "fileops.kill.deletes"
  > "%GWTEMP%\fo_k.txt" echo data
  > "%GWTEMP%\fo.bas" echo 10 KILL "%GWTEMP%\fo_k.txt"
  call :_foRunOK
  call :_foAbsent "%GWTEMP%\fo_k.txt" "killed file gone"

call %test% "fileops.kill.missing.err53"
  del /Q "%GWTEMP%\fo_nope.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 KILL "%GWTEMP%\fo_nope.txt"
  call :_foRunErr 53

call %test% "fileops.kill.wildcard"
  > "%GWTEMP%\fo_w1.txt" echo a
  > "%GWTEMP%\fo_w2.txt" echo b
  > "%GWTEMP%\fo.bas" echo 10 KILL "%GWTEMP%\fo_w?.txt"
  call :_foRunOK
  call :_foAbsent "%GWTEMP%\fo_w1.txt" "wildcard kill w1"
  call :_foAbsent "%GWTEMP%\fo_w2.txt" "wildcard kill w2"

call %test% "fileops.name.renames"
  > "%GWTEMP%\fo_o.txt" echo data
  del /Q "%GWTEMP%\fo_n.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 NAME "%GWTEMP%\fo_o.txt" AS "%GWTEMP%\fo_n.txt"
  call :_foRunOK
  call :_foExist "%GWTEMP%\fo_n.txt" "renamed-to exists"
  call :_foAbsent "%GWTEMP%\fo_o.txt" "renamed-from gone"

call %test% "fileops.name.exists.err58"
  > "%GWTEMP%\fo_o.txt" echo data
  > "%GWTEMP%\fo_x.txt" echo other
  > "%GWTEMP%\fo.bas" echo 10 NAME "%GWTEMP%\fo_o.txt" AS "%GWTEMP%\fo_x.txt"
  call :_foRunErr 58

call %test% "fileops.name.missing.err53"
  del /Q "%GWTEMP%\fo_gone.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 NAME "%GWTEMP%\fo_gone.txt" AS "%GWTEMP%\fo_z.txt"
  call :_foRunErr 53

call %test% "fileops.files.nomatch.err53"
  > "%GWTEMP%\fo.bas" echo 10 FILES "%GWTEMP%\fo_zzz_no.qqq"
  call :_foRunErr 53

call %test% "fileops.files.lists.ok"
  > "%GWTEMP%\fo_f.txt" echo data
  > "%GWTEMP%\fo.bas" echo 10 FILES "%GWTEMP%\fo_f.txt"
  call :_foRunOK

call %test% "fileops.reset.ok"
  > "%GWTEMP%\fo.bas" echo 10 RESET
  call :_foRunOK

del /Q "%GWTEMP%\fo_*.txt" >nul 2>nul
del /Q "%GWTEMP%\fo.bas" >nul 2>nul

exit /B


@REM Load+run %GWTEMP%\fo.bas; assert it ends with no error.
:_foRunOK
  set /a numTests+=1
  setlocal EnableDelayedExpansion
  call %GWSRC%\file\file load "%GWTEMP%\fo.bas"
  set "_err_code=0"
  call %GWSRC%\exec\exec runProgram >nul 2>nul
  if "!_err_code!"=="0" (
    endlocal & set /a passedTests+=1
  ) else (
    echo FAILED fileops: expected ok, got err !_err_code!
    echo.
    endlocal & set /a failedTests+=1
  )
  exit /B 0

@REM Load+run %GWTEMP%\fo.bas; assert _err_code == %1.
:_foRunErr
  set /a numTests+=1
  setlocal EnableDelayedExpansion
  set "_exp=%~1"
  call %GWSRC%\file\file load "%GWTEMP%\fo.bas"
  set "_err_code=0"
  call %GWSRC%\exec\exec runProgram >nul 2>nul
  if "!_err_code!"=="%_exp%" (
    endlocal & set /a passedTests+=1
  ) else (
    echo FAILED fileops: expected err %_exp%, got !_err_code!
    echo.
    endlocal & set /a failedTests+=1
  )
  exit /B 0

@REM Assert path %1 exists (label %2).
:_foExist
  set /a numTests+=1
  if exist "%~1" (
    set /a passedTests+=1
  ) else (
    echo FAILED fileops: %~2 — expected to exist: %~1
    echo.
    set /a failedTests+=1
  )
  exit /B 0

@REM Assert path %1 does NOT exist (label %2).
:_foAbsent
  set /a numTests+=1
  if not exist "%~1" (
    set /a passedTests+=1
  ) else (
    echo FAILED fileops: %~2 — expected absent: %~1
    echo.
    set /a failedTests+=1
  )
  exit /B 0
