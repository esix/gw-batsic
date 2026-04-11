@echo off
::
::  ParseTxt buffer &tokens
::
::  Input: hex-encoded text line (pairs of hex chars, "00" terminated)
::  Output: space-separated tokens in variable named by %2 (or stdout)
::
::  Token types:
::    LN__nnn        Line number
::    NUM_nnn        Numeric literal (decimal, may have . and E/D notation)
::    STR_hhh        String literal (hex-encoded content)
::    REM_hhh        Comment (hex-encoded content)
::    VAR_UNK_name   Untyped variable
::    VAR_STR_name   String variable (name$)
::    VAR_INT_name   Integer variable (name%)
::    VAR_SNG_name   Single variable (name!)
::    VAR_DBL_name   Double variable (name#)
::    KEYWORD        Recognized keywords (PRINT, FOR, etc.)
::    OPAR CPAR      ( )
::    PLUS MINUS MUL DIV IDIV POW  Operators: + - * / \ ^
::    EQ LT GT LE GE NE            Comparison: = < > <= >= <>
::    COMA SEMICOLON COLON         Delimiters: , ; :
::    HASH                         # (file number prefix)
::    EOL                          End of line
::
if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


:ParseTxt
  setlocal EnableDelayedExpansion

  @REM Hex-to-ASCII lookup (for digits 0-9 and letters A-Z, a-z)
  set "_h_30=0"& set "_h_31=1"& set "_h_32=2"& set "_h_33=3"& set "_h_34=4"
  set "_h_35=5"& set "_h_36=6"& set "_h_37=7"& set "_h_38=8"& set "_h_39=9"
  set "_h_41=A"& set "_h_42=B"& set "_h_43=C"& set "_h_44=D"& set "_h_45=E"
  set "_h_46=F"& set "_h_47=G"& set "_h_48=H"& set "_h_49=I"& set "_h_4A=J"
  set "_h_4B=K"& set "_h_4C=L"& set "_h_4D=M"& set "_h_4E=N"& set "_h_4F=O"
  set "_h_50=P"& set "_h_51=Q"& set "_h_52=R"& set "_h_53=S"& set "_h_54=T"
  set "_h_55=U"& set "_h_56=V"& set "_h_57=W"& set "_h_58=X"& set "_h_59=Y"
  set "_h_5A=Z"& set "_h_61=a"& set "_h_62=b"& set "_h_63=c"& set "_h_64=d"
  set "_h_65=e"& set "_h_66=f"& set "_h_67=g"& set "_h_68=h"& set "_h_69=i"
  set "_h_6A=j"& set "_h_6B=k"& set "_h_6C=l"& set "_h_6D=m"& set "_h_6E=n"
  set "_h_6F=o"& set "_h_70=p"& set "_h_71=q"& set "_h_72=r"& set "_h_73=s"
  set "_h_74=t"& set "_h_75=u"& set "_h_76=v"& set "_h_77=w"& set "_h_78=x"
  set "_h_79=y"& set "_h_7A=z"& set "_h_2E=."

  :: 00 means last char
  set "buffer=%~100"
  set tokens=
  set error=
  set i=0
  set state=Start
  set acc=

  goto :_Loop

:_Loop
    set /a  ii = 2 * i
    set "c=!buffer:~%ii%,2!"
    if "!c!"=="" goto :_LoopEnd
    set /a  i = i + 1

    set "isSpace="& set "isNumber="& set "isLetter="& set "isEol="
    if !c!==20 set "isSpace=T"
    if !c! GEQ 30 if !c! LEQ 39 set "isNumber=T"
    if !c! GEQ 41 if !c! LEQ 5A set "isLetter=T"
    if !c! GEQ 61 if !c! LEQ 7A set "isLetter=T"
    if !c!==00 set "isEol=T"

    goto :_S_!state!

:_S_EmitNum
      @REM Convert acc to tagged binary number
      if "!ntype!"=="" (
        call int fromDec !acc!
        if not errorlevel 1 (
          set "tokens=!tokens! NUM_!__!"
          set acc=
          set state=Normal
          goto :_S_Normal
        )
        set "ntype=s"
      )
      if "!ntype!"=="i" (
        call int fromDec !acc!
        if errorlevel 1 (call sng fromDec !acc!)
        set "tokens=!tokens! NUM_!__!"
      )
      if "!ntype!"=="s" (
        call sng fromDec !acc!
        set "tokens=!tokens! NUM_!__!"
      )
      if "!ntype!"=="d" (
        call dbl fromDec !acc!
        set "tokens=!tokens! NUM_!__!"
      )
      set acc=
      set ntype=
      set state=Normal
      goto :_S_Normal

:_S_Start
      if defined isEol goto :_Loop
      if defined isSpace goto :_Loop
      if defined isNumber (
        set state=LineNumber
        set acc=
        goto :_S_LineNumber
      )
      set state=Normal
      goto :_S_Normal

:_S_Normal
      if defined isEol goto :_Loop
      if defined isSpace goto :_Loop
      if defined isLetter (
        set state=Id
        set acc=
        goto :_S_Id
      )
      if defined isNumber (
        set state=Number1
        set acc=
        goto :_S_Number1
      )
      @REM " (0x22) - string literal
      if !c!==22 (
        set state=Quote
        set acc=
        goto :_Loop
      )
      @REM ' (0x27) - comment shorthand
      if !c!==27 (
        set state=Rem
        set acc=
        goto :_Loop
      )
      @REM ( ) (0x28, 0x29)
      if !c!==28 (set "tokens=!tokens! OPAR" & goto :_Loop)
      if !c!==29 (set "tokens=!tokens! CPAR" & goto :_Loop)
      @REM * + , - . / (0x2A-0x2F)
      if !c!==2A (set "tokens=!tokens! MUL" & goto :_Loop)
      if !c!==2B (set "tokens=!tokens! PLUS" & goto :_Loop)
      if !c!==2C (set "tokens=!tokens! COMA" & goto :_Loop)
      if !c!==2D (set "tokens=!tokens! MINUS" & goto :_Loop)
      if !c!==2E (set "acc=." & set "state=Number2" & goto :_Loop)
      if !c!==2F (set "tokens=!tokens! DIV" & goto :_Loop)
      @REM : ; (0x3A, 0x3B)
      if !c!==3A (set "tokens=!tokens! COLON" & goto :_Loop)
      if !c!==3B (set "tokens=!tokens! SEMICOLON" & goto :_Loop)
      @REM < = > (0x3C-0x3E)
      if !c!==3C (set "state=Less" & goto :_Loop)
      if !c!==3D (set "tokens=!tokens! EQ" & goto :_Loop)
      if !c!==3E (set "state=More" & goto :_Loop)
      @REM ? (0x3F) - PRINT shorthand
      if !c!==3F (set "tokens=!tokens! PRINT" & goto :_Loop)
      @REM \ (0x5C) - integer division
      if !c!==5C (set "tokens=!tokens! IDIV" & goto :_Loop)
      @REM ^ (0x5E) - exponent
      if !c!==5E (set "tokens=!tokens! POW" & goto :_Loop)
      @REM # (0x23) - file number prefix
      if !c!==23 (set "tokens=!tokens! HASH" & goto :_Loop)
      @REM & (0x26) - hex/octal prefix
      if !c!==26 (set "state=Ampersand" & goto :_Loop)
      @REM @ (0x40) - sometimes used, ignore for now
      if !c!==40 goto :_Loop
      goto :_Error

:_S_Id
      @REM Letters and digits in identifiers
      if defined isLetter (
        set "acc=!acc!!_h_%c%!"
        goto :_Loop
      )
      if defined isNumber (
        set "acc=!acc!!_h_%c%!"
        goto :_Loop
      )
      @REM $ (0x24) - string type suffix
      if !c!==24 (
        call %GWSRC%\lexer\keyword isKeywordStr !acc!
        if ERRORLEVEL 1 (
          set acc=VAR_STR_!acc!
        ) else (
          set acc=!acc!_STR
        )
        set "tokens=!tokens! !acc!"
        set state=Normal
        set acc=
        goto :_Loop
      )
      @REM % (0x25) - integer type suffix
      if !c!==25 (
        set "tokens=!tokens! VAR_INT_!acc!"
        set state=Normal
        set acc=
        goto :_Loop
      )
      @REM ! (0x21) - single type suffix
      if !c!==21 (
        set "tokens=!tokens! VAR_SNG_!acc!"
        set state=Normal
        set acc=
        goto :_Loop
      )
      @REM # (0x23) - double type suffix
      if !c!==23 (
        set "tokens=!tokens! VAR_DBL_!acc!"
        set state=Normal
        set acc=
        goto :_Loop
      )
      @REM End of identifier: check keyword, emit token
      call %GWSRC%\lexer\keyword isKeyword !acc!
      if ERRORLEVEL 1 set acc=VAR_UNK_!acc!
      set "tokens=!tokens! !acc!"
      set "_isRem="
      if "!acc!"=="REM" set "_isRem=1"
      set acc=
      if "!_isRem!"=="1" (
        set state=Rem
        goto :_S_Rem
      )
      set state=Normal
      goto :_S_Normal

:_S_LineNumber
      if defined isNumber (
        set acc=!acc!!c!
        goto :_Loop
      )
      @REM Decode hex pairs to line number string (inline)
      set "_ln="
      set "_la=!acc!"
:_S_LN_dec
      if "!_la!"=="" goto :_S_LN_done
      set "_lc=!_la:~0,2!"
      set "_la=!_la:~2!"
      set "_ln=!_ln!!_h_%_lc%!"
      goto :_S_LN_dec
:_S_LN_done
      set "tokens=!tokens! LN__!_ln!"
      set acc=
      set state=Normal
      goto :_S_Normal

    @REM === Number states ===
    @REM Number1: integer part (digits)
    @REM Number2: fractional part (after .)
    @REM Number3: exponent part (after E/D, optional +/-)
    @REM ntype tracks forced type: i=int, s=single, d=double, empty=auto

:_S_Number1
      if defined isNumber (
        set "acc=!acc!!_h_%c%!"
        goto :_Loop
      )
      @REM . -> fractional part
      if !c!==2E (set "acc=!acc!." & set "state=Number2" & goto :_Loop)
      @REM E/e -> single exponent
      if !c!==45 (set "acc=!acc!E" & set "ntype=s" & set "state=Number3" & goto :_Loop)
      if !c!==65 (set "acc=!acc!E" & set "ntype=s" & set "state=Number3" & goto :_Loop)
      @REM D/d -> double exponent
      if !c!==44 (set "acc=!acc!D" & set "ntype=d" & set "state=Number3" & goto :_Loop)
      if !c!==64 (set "acc=!acc!D" & set "ntype=d" & set "state=Number3" & goto :_Loop)
      @REM % -> force integer
      if !c!==25 (set "ntype=i" & goto :_S_EmitNum)
      @REM ! -> force single
      if !c!==21 (set "ntype=s" & goto :_S_EmitNum)
      @REM # -> force double
      if !c!==23 (set "ntype=d" & goto :_S_EmitNum)
      @REM End of number (no suffix -> auto)
      set "ntype="
      goto :_S_EmitNum

:_S_Number2
      if defined isNumber (
        set "acc=!acc!!_h_%c%!"
        goto :_Loop
      )
      @REM E/e -> single exponent
      if !c!==45 (set "acc=!acc!E" & set "ntype=s" & set "state=Number3" & goto :_Loop)
      if !c!==65 (set "acc=!acc!E" & set "ntype=s" & set "state=Number3" & goto :_Loop)
      @REM D/d -> double exponent
      if !c!==44 (set "acc=!acc!D" & set "ntype=d" & set "state=Number3" & goto :_Loop)
      if !c!==64 (set "acc=!acc!D" & set "ntype=d" & set "state=Number3" & goto :_Loop)
      @REM End of number (has decimal -> single by default)
      set "ntype=s"
      goto :_S_EmitNum

:_S_Number3
      @REM Exponent: optional +/-, then digits
      if !c!==2B (set "acc=!acc!+" & goto :_Loop)
      if !c!==2D (set "acc=!acc!-" & goto :_Loop)
      if defined isNumber (
        set "acc=!acc!!_h_%c%!"
        goto :_Loop
      )
      @REM End of number (ntype already set by E or D)
      goto :_S_EmitNum

:_S_Less
      if !c!==3D (set "tokens=!tokens! LE" & set "state=Normal" & goto :_Loop)
      if !c!==3E (set "tokens=!tokens! NE" & set "state=Normal" & goto :_Loop)
      set "tokens=!tokens! LT"
      set state=Normal
      goto :_S_Normal

:_S_More
      if !c!==3D (set "tokens=!tokens! GE" & set "state=Normal" & goto :_Loop)
      set "tokens=!tokens! GT"
      set state=Normal
      goto :_S_Normal

:_S_Quote
      @REM End on " or EOL, accumulate raw hex pairs
      if !c!==22 (
        set "tokens=!tokens! STR_!acc!"
        set acc=
        set state=Normal
        goto :_Loop
      )
      if defined isEol (
        set "tokens=!tokens! STR_!acc!"
        set acc=
        set state=Normal
        goto :_Loop
      )
      set acc=!acc!!c!
      goto :_Loop

:_S_Rem
      @REM Accumulate raw hex pairs until EOL
      if defined isEol (
        set "tokens=!tokens! REM_!acc!"
        set acc=
        set state=Normal
        goto :_Loop
      )
      set acc=!acc!!c!
      goto :_Loop

:_S_Ampersand
      @REM &H -> hex literal, &O -> octal literal, & alone -> ignored
      if !c!==48 (set "state=HexLit" & set "acc=" & goto :_Loop)
      if !c!==68 (set "state=HexLit" & set "acc=" & goto :_Loop)
      if !c!==4F (set "state=OctLit" & set "acc=" & goto :_Loop)
      if !c!==6F (set "state=OctLit" & set "acc=" & goto :_Loop)
      @REM Bare & - treat as long integer suffix, ignore
      set state=Normal
      goto :_S_Normal

:_S_HexLit
      @REM Hex digits: 0-9, A-F, a-f
      if defined isNumber (
        set "acc=!acc!!_h_%c%!"
        goto :_Loop
      )
      if !c! GEQ 41 if !c! LEQ 46 (
        set "acc=!acc!!_h_%c%!"
        goto :_Loop
      )
      if !c! GEQ 61 if !c! LEQ 66 (
        set "acc=!acc!!_h_%c%!"
        goto :_Loop
      )
      @REM End of hex literal
      set "tokens=!tokens! HEX_!acc!"
      set acc=
      set state=Normal
      goto :_S_Normal

:_S_OctLit
      @REM Octal digits: 0-7
      if !c! GEQ 30 if !c! LEQ 37 (
        set "acc=!acc!!_h_%c%!"
        goto :_Loop
      )
      @REM End of octal literal
      set "tokens=!tokens! OCT_!acc!"
      set acc=
      set state=Normal
      goto :_S_Normal

:_LoopEnd

  @REM Flush any pending accumulator
  @REM EmitNum state no longer used at flush (direct goto now)
  if "!state!"=="Number1" (set "ntype=" & goto :_FlushNum)
  if "!state!"=="Number2" (set "ntype=s" & goto :_FlushNum)
  if "!state!"=="Number3" goto :_FlushNum
  goto :_FlushId
:_FlushNum
  @REM Same logic as _EmitNum but at end-of-line
  if "!ntype!"=="" (
    call int fromDec !acc!
    if not errorlevel 1 (
      set "tokens=!tokens! NUM_!__!"
      goto :_FlushDone
    )
    set "ntype=s"
  )
  if "!ntype!"=="i" (
    call int fromDec !acc!
    if errorlevel 1 (call sng fromDec !acc!)
    set "tokens=!tokens! NUM_!__!"
  )
  if "!ntype!"=="s" (call sng fromDec !acc! & set "tokens=!tokens! NUM_!__!")
  if "!ntype!"=="d" (call dbl fromDec !acc! & set "tokens=!tokens! NUM_!__!")
  set "ntype="
  goto :_FlushDone
:_FlushId
  if "!state!"=="Id" (
    call %GWSRC%\lexer\keyword isKeyword !acc!
    if ERRORLEVEL 1 set acc=VAR_UNK_!acc!
    set "tokens=!tokens! !acc!"
    set state=Normal
  )
  if "!state!"=="Rem" set "tokens=!tokens! REM_!acc!" & set "state=Normal"
  if "!state!"=="Quote" set "tokens=!tokens! STR_!acc!" & set "state=Normal"
  if "!state!"=="HexLit" set "tokens=!tokens! HEX_!acc!" & set "state=Normal"
  if "!state!"=="OctLit" set "tokens=!tokens! OCT_!acc!" & set "state=Normal"
:_FlushDone

  set "tokens=!tokens! EOL"

  endlocal && if "%~2"=="" (
    echo %tokens:~1%
  ) else (
    set "%~2=%tokens:~1%"
  )
  exit /b 0

:_Error
    echo "tokens=%tokens%"
    call buffer decode !buffer! wholeLine
    echo "LEXER ERROR:"
    echo "LEXER ERROR: !wholeLine!"
    echo "LEXER ERROR: state=%state%: undefined char !c! at index !i!"
    echo "LEXER ERROR:"
    endlocal && set "%~2=%tokens:~1%"
  exit /b 2


:_start
  setlocal DisableDelayedExpansion
  set PATH=%~dp0;%~dp0..\..\lib;%PATH%

  ::                 6 5   D I M   H ( M A X F R A M E   +   1 ,   P O I N T S ,   2 )
  set "buffer=20202036352044494D2048284D41584652414D45202B20312C20504F494E54532C20322920"
  echo "   65 DIM H(MAXFRAME + 1, POINTS, 2)"
  call:ParseTxt %buffer%
  endlocal
