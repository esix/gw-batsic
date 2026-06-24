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

@REM --- INPUT# / LINE INPUT# / EOF / LOF (M3) ---
@REM Read values back and re-emit to a 2nd file so the harness can verify.
call %test% "fileops.input.file.roundtrip"
  del /Q "%GWTEMP%\fo_d.txt" "%GWTEMP%\fo_o.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_d.txt"
  >>"%GWTEMP%\fo.bas" echo 20 WRITE #1,"Alice",42
  >>"%GWTEMP%\fo.bas" echo 30 CLOSE #1
  >>"%GWTEMP%\fo.bas" echo 40 OPEN "I",#1,"%GWTEMP%\fo_d.txt"
  >>"%GWTEMP%\fo.bas" echo 50 INPUT #1,N$,A
  >>"%GWTEMP%\fo.bas" echo 60 CLOSE #1
  >>"%GWTEMP%\fo.bas" echo 70 OPEN "O",#2,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 80 PRINT #2,N$;A
  >>"%GWTEMP%\fo.bas" echo 90 CLOSE #2
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" "Alice 42"

call %test% "fileops.input.file.eofloop"
  del /Q "%GWTEMP%\fo_d.txt" "%GWTEMP%\fo_o.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_d.txt"
  >>"%GWTEMP%\fo.bas" echo 20 FOR I=1 TO 3:WRITE #1,I:NEXT I
  >>"%GWTEMP%\fo.bas" echo 30 CLOSE #1
  >>"%GWTEMP%\fo.bas" echo 40 OPEN "I",#1,"%GWTEMP%\fo_d.txt"
  >>"%GWTEMP%\fo.bas" echo 50 C=0
  >>"%GWTEMP%\fo.bas" echo 60 IF EOF(1) THEN 90
  >>"%GWTEMP%\fo.bas" echo 70 INPUT #1,X
  >>"%GWTEMP%\fo.bas" echo 80 C=C+1:GOTO 60
  >>"%GWTEMP%\fo.bas" echo 90 CLOSE #1
  >>"%GWTEMP%\fo.bas" echo 100 OPEN "O",#2,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 110 PRINT #2,C
  >>"%GWTEMP%\fo.bas" echo 120 CLOSE #2
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" " 3"

call %test% "fileops.lineinput.file"
  del /Q "%GWTEMP%\fo_d.txt" "%GWTEMP%\fo_o.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_d.txt"
  >>"%GWTEMP%\fo.bas" echo 20 PRINT #1,"a,b,c"
  >>"%GWTEMP%\fo.bas" echo 30 CLOSE #1
  >>"%GWTEMP%\fo.bas" echo 40 OPEN "I",#1,"%GWTEMP%\fo_d.txt"
  >>"%GWTEMP%\fo.bas" echo 50 LINE INPUT #1,L$
  >>"%GWTEMP%\fo.bas" echo 60 CLOSE #1
  >>"%GWTEMP%\fo.bas" echo 70 OPEN "O",#2,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 80 PRINT #2,L$
  >>"%GWTEMP%\fo.bas" echo 90 CLOSE #2
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" "a,b,c"

@REM --- Random-access records: FIELD / LSET / RSET / GET / PUT (M5/M6) ---
del /Q "%GWTEMP%\fo_r.dat" >nul 2>nul
del "%GWTEMP%\fields.dat" "%GWTEMP%\recbuf_*.hex" >nul 2>nul

call %test% "fileops.record.numeric.roundtrip"
  @REM LSET MKS$ -> PUT -> GET -> CVS must round-trip a single through disk.
  del /Q "%GWTEMP%\fo_r.dat" "%GWTEMP%\fo_o.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "R",#1,"%GWTEMP%\fo_r.dat",24
  >>"%GWTEMP%\fo.bas" echo 20 FIELD #1,20 AS N$,4 AS S$
  >>"%GWTEMP%\fo.bas" echo 30 LSET N$="Alice":LSET S$=MKS$(95.5):PUT #1,1
  >>"%GWTEMP%\fo.bas" echo 40 CLOSE #1
  >>"%GWTEMP%\fo.bas" echo 50 OPEN "R",#1,"%GWTEMP%\fo_r.dat",24
  >>"%GWTEMP%\fo.bas" echo 60 FIELD #1,20 AS N$,4 AS S$
  >>"%GWTEMP%\fo.bas" echo 70 GET #1,1
  >>"%GWTEMP%\fo.bas" echo 80 CLOSE #1
  >>"%GWTEMP%\fo.bas" echo 90 OPEN "O",#2,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 100 PRINT #2,CVS(S$)
  >>"%GWTEMP%\fo.bas" echo 110 CLOSE #2
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" " 95.5"

call %test% "fileops.record.getmodifyput"
  @REM GET, change ONLY field 2, PUT; re-GET must keep fields 1 and 3 intact.
  del /Q "%GWTEMP%\fo_r.dat" "%GWTEMP%\fo_o.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "R",#1,"%GWTEMP%\fo_r.dat",12
  >>"%GWTEMP%\fo.bas" echo 20 FIELD #1,4 AS A$,4 AS B$,4 AS C$
  >>"%GWTEMP%\fo.bas" echo 30 LSET A$="aaa":LSET B$="bbb":LSET C$="ccc":PUT #1,1
  >>"%GWTEMP%\fo.bas" echo 40 GET #1,1:LSET B$="XYZ":PUT #1,1
  >>"%GWTEMP%\fo.bas" echo 50 GET #1,1
  >>"%GWTEMP%\fo.bas" echo 60 CLOSE #1
  >>"%GWTEMP%\fo.bas" echo 70 OPEN "O",#2,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 80 PRINT #2,A$;B$;C$
  >>"%GWTEMP%\fo.bas" echo 90 CLOSE #2
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" "aaa XYZ ccc "

call %test% "fileops.record.norecord.advance"
  @REM Bare PUT / GET advance the current-record pointer.
  del /Q "%GWTEMP%\fo_r.dat" "%GWTEMP%\fo_o.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "R",#1,"%GWTEMP%\fo_r.dat",2
  >>"%GWTEMP%\fo.bas" echo 20 FIELD #1,2 AS R$
  >>"%GWTEMP%\fo.bas" echo 30 FOR I=1 TO 3:LSET R$=MKI$(I*10):PUT #1:NEXT I
  >>"%GWTEMP%\fo.bas" echo 40 CLOSE #1:OPEN "R",#1,"%GWTEMP%\fo_r.dat",2
  >>"%GWTEMP%\fo.bas" echo 50 FIELD #1,2 AS R$:T=0
  >>"%GWTEMP%\fo.bas" echo 60 FOR I=1 TO 3:GET #1:T=T+CVI(R$):NEXT I
  >>"%GWTEMP%\fo.bas" echo 70 CLOSE #1
  >>"%GWTEMP%\fo.bas" echo 80 OPEN "O",#2,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 90 PRINT #2,T
  >>"%GWTEMP%\fo.bas" echo 100 CLOSE #2
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" " 60"

call %test% "fileops.record.detach"
  @REM Plain assignment to a FIELDed var unbinds it from the buffer.
  del /Q "%GWTEMP%\fo_r.dat" "%GWTEMP%\fo_o.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "R",#1,"%GWTEMP%\fo_r.dat",4
  >>"%GWTEMP%\fo.bas" echo 20 FIELD #1,4 AS X$
  >>"%GWTEMP%\fo.bas" echo 30 LSET X$="AB":PUT #1,1
  >>"%GWTEMP%\fo.bas" echo 40 GET #1,1:X$="ZZ":GET #1,1
  >>"%GWTEMP%\fo.bas" echo 50 CLOSE #1
  >>"%GWTEMP%\fo.bas" echo 60 OPEN "O",#2,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 70 PRINT #2,X$
  >>"%GWTEMP%\fo.bas" echo 80 CLOSE #2
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" "ZZ"

@REM --- ON ERROR GOTO / RESUME / ERR (error trapping) ---
call %test% "stmt.onerror.traps.and.resumes"
  @REM OPEN of a missing file (err 53) traps to the handler; RESUME NEXT
  @REM continues; ERR holds 53.
  del /Q "%GWTEMP%\fo_none.dat" "%GWTEMP%\fo_o.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 ON ERROR GOTO 100
  >>"%GWTEMP%\fo.bas" echo 20 OPEN "I",#1,"%GWTEMP%\fo_none.dat"
  >>"%GWTEMP%\fo.bas" echo 30 OPEN "O",#2,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 40 PRINT #2,"trapped";ERR;"at";ERL
  >>"%GWTEMP%\fo.bas" echo 50 CLOSE #2:END
  >>"%GWTEMP%\fo.bas" echo 100 RESUME NEXT
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" "trapped 53at 20"

@REM --- glued PRINT#n / WRITE#n (no space before #) ---
call %test% "stmt.print.hash.glued"
  @REM PRINT#2 (glued) must lex as PRINT HASH 2, not a VAR_DBL_PRINT.
  del /Q "%GWTEMP%\fo_o.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "O",#2,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 20 PRINT#2,"glued"
  >>"%GWTEMP%\fo.bas" echo 30 CLOSE
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" "glued"

@REM --- LIST [n-m] : list lines then halt (GW returns to command level) ---
call %test% "stmt.list.lists.then.halts"
  @REM line 10 writes BEFORE; line 20 LISTs and halts; line 30 (would overwrite
  @REM with AFTER) never runs -> the file still says BEFORE.
  del /Q "%GWTEMP%\fo_o.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_o.txt":PRINT #1,"BEFORE":CLOSE
  >>"%GWTEMP%\fo.bas" echo 20 LIST 10-20
  >>"%GWTEMP%\fo.bas" echo 30 OPEN "O",#1,"%GWTEMP%\fo_o.txt":PRINT #1,"AFTER":CLOSE
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" "BEFORE"

@REM --- IF ... :ELSE (colon before ELSE, THEN-line and GOTO-line forms) ---
call %test% "stmt.if.then.num.colon.else"
  del /Q "%GWTEMP%\fo_o.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 20 IF 1=2 THEN 100:ELSE 200
  >>"%GWTEMP%\fo.bas" echo 30 END
  >>"%GWTEMP%\fo.bas" echo 100 PRINT #1,"THEN":CLOSE:END
  >>"%GWTEMP%\fo.bas" echo 200 PRINT #1,"ELSE":CLOSE:END
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" "ELSE"

call %test% "stmt.if.goto.num.colon.else"
  del /Q "%GWTEMP%\fo_o.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 20 IF 1=1 GOTO 100:ELSE 200
  >>"%GWTEMP%\fo.bas" echo 30 END
  >>"%GWTEMP%\fo.bas" echo 100 PRINT #1,"THEN":CLOSE:END
  >>"%GWTEMP%\fo.bas" echo 200 PRINT #1,"ELSE":CLOSE:END
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" "THEN"

@REM --- RUN <variable filename> (not just a string literal) ---
call %test% "stmt.run.variable.filename"
  del /Q "%GWTEMP%\fo_o.txt" "%GWTEMP%\fo2.bas" >nul 2>nul
  > "%GWTEMP%\fo2.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_o.txt":PRINT #1,"RAN2":CLOSE
  > "%GWTEMP%\fo.bas" echo 10 P$="%GWTEMP%\fo2.bas":RUN P$
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" "RAN2"
  del /Q "%GWTEMP%\fo2.bas" >nul 2>nul

@REM --- CHAIN: load another program preserving variables ---
call %test% "stmt.chain.preserves.vars"
  del /Q "%GWTEMP%\fo_o.txt" "%GWTEMP%\fo2.bas" >nul 2>nul
  > "%GWTEMP%\fo2.bas" echo 10 OPEN "O",#1,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo2.bas" echo 20 PRINT #1,X
  >>"%GWTEMP%\fo2.bas" echo 30 CLOSE #1
  > "%GWTEMP%\fo.bas" echo 10 X=42
  >>"%GWTEMP%\fo.bas" echo 20 CHAIN "%GWTEMP%\fo2.bas"
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" " 42"

call %test% "stmt.chain.missing.file.traps"
  @REM CHAIN to a nonexistent file raises 53, trappable by ON ERROR.
  del /Q "%GWTEMP%\fo_o.txt" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 ON ERROR GOTO 100
  >>"%GWTEMP%\fo.bas" echo 20 CHAIN "%GWTEMP%\nope.bas"
  >>"%GWTEMP%\fo.bas" echo 30 OPEN "O",#1,"%GWTEMP%\fo_o.txt":PRINT #1,ERR:CLOSE:END
  >>"%GWTEMP%\fo.bas" echo 100 RESUME 30
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" " 53"

del /Q "%GWTEMP%\fo2.bas" >nul 2>nul

@REM --- DEF FN with string return + string/numeric params ---
call %test% "fn.deffn.string"
  del "%GWTEMP%\deffns.dat" >nul 2>nul
  > "%GWTEMP%\fo.bas" echo 10 DEF FNB$(S$,N)=LEFT$(S$,N)
  >>"%GWTEMP%\fo.bas" echo 20 OPEN "O",#1,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 30 PRINT #1,FNB$("HELLO",3)
  >>"%GWTEMP%\fo.bas" echo 40 CLOSE #1
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" "HEL"

@REM --- MID$ statement (left-side substring assignment) ---
call %test% "stmt.mid.assign"
  > "%GWTEMP%\fo.bas" echo 10 A$="HELLO"
  >>"%GWTEMP%\fo.bas" echo 20 MID$(A$,2,3)="xyz"
  >>"%GWTEMP%\fo.bas" echo 30 OPEN "O",#1,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 40 PRINT #1,A$
  >>"%GWTEMP%\fo.bas" echo 50 CLOSE #1
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" "HxyzO"

call %test% "stmt.mid.assign.shortvalue"
  > "%GWTEMP%\fo.bas" echo 10 B$="ABCDEF"
  >>"%GWTEMP%\fo.bas" echo 20 MID$(B$,3,4)="Xy"
  >>"%GWTEMP%\fo.bas" echo 30 OPEN "O",#1,"%GWTEMP%\fo_o.txt"
  >>"%GWTEMP%\fo.bas" echo 40 PRINT #1,B$
  >>"%GWTEMP%\fo.bas" echo 50 CLOSE #1
  call :_foRunOK
  call :_foLine1 "%GWTEMP%\fo_o.txt" "ABXyEF"

del /Q "%GWTEMP%\fo_r.dat" >nul 2>nul
del "%GWTEMP%\fields.dat" "%GWTEMP%\recbuf_*.hex" >nul 2>nul
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
