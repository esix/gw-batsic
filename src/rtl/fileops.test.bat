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

@REM --- OPEN / CLOSE (M1) ---
call %test% "fileops.open.output.creates"
  del /Q "%GWTEMP%\fo_oo.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_oo.txt"
  >>"%GWTEMP%\fo.bas" echo 20 CLOSE #1
  call :_foRunOK
  call :_foExist "%GWTEMP%\fo_oo.txt" "OPEN O created file"

call %test% "fileops.open.input.missing.err53"
  del /Q "%GWTEMP%\fo_none.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "I",#1,"%GWTEMP%\fo_none.txt"
  call :_foRunErr 53

call %test% "fileops.open.foras.creates"
  del /Q "%GWTEMP%\fo_fa.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "%GWTEMP%\fo_fa.txt" FOR OUTPUT AS #2
  >>"%GWTEMP%\fo.bas" echo 20 CLOSE
  call :_foRunOK
  call :_foExist "%GWTEMP%\fo_fa.txt" "OPEN FOR OUTPUT AS created file"

call %test% "fileops.open.aslen.random"
  del /Q "%GWTEMP%\fo_rec.dat" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "%GWTEMP%\fo_rec.dat" AS #3 LEN=80
  >>"%GWTEMP%\fo.bas" echo 20 CLOSE #3
  call :_foRunOK
  call :_foExist "%GWTEMP%\fo_rec.dat" "OPEN AS LEN created random file"

call %test% "fileops.open.already.err55"
  del /Q "%GWTEMP%\fo_dup.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_dup.txt"
  >>"%GWTEMP%\fo.bas" echo 20 OPEN "O",#1,"%GWTEMP%\fo_dup.txt"
  call :_foRunErr 55

@REM --- PRINT# / WRITE# (M2) ---
call %test% "fileops.print.file.semicolon"
  del /Q "%GWTEMP%\fo_p.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_p.txt"
  >>"%GWTEMP%\fo.bas" echo 20 PRINT #1,"HELLO";"WORLD"
  >>"%GWTEMP%\fo.bas" echo 30 CLOSE #1
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_p.txt" "HELLOWORLD"

call %test% "fileops.print.file.number"
  del /Q "%GWTEMP%\fo_pn.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_pn.txt"
  >>"%GWTEMP%\fo.bas" echo 20 PRINT #1,"X=";42
  >>"%GWTEMP%\fo.bas" echo 30 CLOSE #1
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_pn.txt" "X= 42"

call %test% "fileops.print.file.append.continues"
  del /Q "%GWTEMP%\fo_pc.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_pc.txt"
  >>"%GWTEMP%\fo.bas" echo 20 PRINT #1,"AB";
  >>"%GWTEMP%\fo.bas" echo 30 PRINT #1,"CD"
  >>"%GWTEMP%\fo.bas" echo 40 CLOSE #1
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_pc.txt" "ABCD"

call %test% "fileops.write.file.csv"
  del /Q "%GWTEMP%\fo_wr.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_wr.txt"
  >>"%GWTEMP%\fo.bas" echo 20 WRITE #1,"AB",5,"CD"
  >>"%GWTEMP%\fo.bas" echo 30 CLOSE #1
  call :_foRunOK
  call :_foHas "%GWTEMP%\fo_wr.txt" "AB"
  call :_foHas "%GWTEMP%\fo_wr.txt" ",5,"

call %test% "fileops.print.input.mode.err54"
  > "%GWTEMP%\fo_im.txt" echo seed
  > "%GWTEMP%\fo.bas" echo 10 OPEN "I",#1,"%GWTEMP%\fo_im.txt"
  >>"%GWTEMP%\fo.bas" echo 20 PRINT #1,"nope"
  call :_foRunErr 54

del /Q "%GWTEMP%\fo_oo.txt" "%GWTEMP%\fo_fa.txt" "%GWTEMP%\fo_rec.dat" "%GWTEMP%\fo_dup.txt" >nul 2>nul
del /Q "%GWTEMP%\fo_*.txt" >nul 2>nul
del /Q "%GWTEMP%\fo.bas" >nul 2>nul

exit /B


@REM Assert the first line of file %1 equals %2.
:_foLine1
  set /a numTests+=1
  setlocal EnableDelayedExpansion
  set "_got="
  set /p "_got=" < "%~1"
  if "!_got!"=="%~2" (
    endlocal & set /a passedTests+=1
  ) else (
    echo FAILED fileops: %~1 line1 [!_got!] != [%~2]
    echo.
    endlocal & set /a failedTests+=1
  )
  exit /B 0

@REM Assert file %1 contains literal substring %2.
:_foHas
  set /a numTests+=1
  findstr /C:"%~2" "%~1" >nul 2>nul
  if not errorlevel 1 (
    set /a passedTests+=1
  ) else (
    echo FAILED fileops: %~1 missing [%~2]
    echo.
    set /a failedTests+=1
  )
  exit /B 0

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
