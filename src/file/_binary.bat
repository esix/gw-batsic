@echo off
@REM GW-BASIC binary `.BAS` format ↔ our internal token stream.
@REM
@REM See docs/04-lexer.md for the binary format details. Key facts:
@REM
@REM File:   FF <line>... 00 00 1A
@REM Line:   <next_lo><next_hi> <num_lo><num_hi> <content...> 00
@REM
@REM Token bytes inside a line:
@REM   0B xx xx     octal literal (2-byte LE)
@REM   0C xx xx     hex literal (2-byte LE)
@REM   0E xx xx     line-number reference (after GOTO/THEN/etc.)
@REM   0F nn        1-byte unsigned int (11..255)
@REM   11..1A       small int constants 0..9 (note: 10 uses `0F 0A`)
@REM   1C xx xx     2-byte LE signed int (256..32767)
@REM   1D <4 bytes> MBF single (mantissa LE + exp last; bias 129)
@REM   1F <8 bytes> MBF double (same layout, bias 129)
@REM   20..7E       ASCII (var name chars, $%!#, operators ()[],;:, ", etc.)
@REM   81..FC       single-byte keyword token
@REM   FD xx / FE xx / FF xx   2-byte keyword token
@REM
@REM Our internal MBF uses bias 128, GW-BASIC uses 129 — exponent byte differs
@REM by 1. We add 1 when emitting binary; subtract 1 when reading.
@REM
@REM Usage:
@REM   call _binary detokenize PATH      - read binary file → add lines to _program
@REM   call _binary tokenize PATH        - write current _program as binary
@REM   call _binary isBinary PATH        - errorlevel 0 if first byte is FF

if not defined GWSRC set "GWSRC=%~dp0.."
if not defined GWTEMP set "GWTEMP=%~dp0..\..\temp"

if "%~1"=="" goto :_start
set "_fn=%~1"
shift
goto :%_fn%


@REM --- isBinary PATH: errorlevel 0 if file starts with FF (tokenized), else 1 ---
:isBinary
  setlocal EnableDelayedExpansion
  set "_hf=%TEMP%\_gwbas_isbin.hex"
  del "!_hf!" 2>nul
  certutil -encodehex "%~1" "!_hf!" 12 >nul 2>nul
  if errorlevel 1 (endlocal & exit /B 1)
  set "_first="
  set /p "_first=" < "!_hf!"
  set "_first=!_first:~0,2!"
  @REM Normalize to uppercase
  if "!_first!"=="ff" set "_first=FF"
  if "!_first!"=="FF" (endlocal & exit /B 0)
  endlocal & exit /B 1


@REM --- detokenize PATH: read binary file, add each line to _program ---
:detokenize
  setlocal EnableDelayedExpansion
  set "_hf=%TEMP%\_gwbas_load.hex"
  del "!_hf!" 2>nul
  certutil -encodehex "%~1" "!_hf!" 12 >nul 2>nul
  if errorlevel 1 (echo Cannot read: %~1 1>&2 & endlocal & exit /B 1)
  @REM Concatenate all hex lines into one stream.
  set "_all="
  for /f "usebackq delims=" %%h in ("!_hf!") do set "_all=!_all!%%h"
  @REM Normalize to uppercase.
  set "_all=!_all:a=A!"
  set "_all=!_all:b=B!"
  set "_all=!_all:c=C!"
  set "_all=!_all:d=D!"
  set "_all=!_all:e=E!"
  set "_all=!_all:f=F!"
  @REM Header byte must be FF.
  if not "!_all:~0,2!"=="FF" (
    echo Not a tokenized BAS file: %~1 1>&2
    endlocal & exit /B 1
  )
  set /a "_pos=2"
:_detok_lineLoop
  @REM Read next-line pointer (2 bytes LE)
  call :_hexWordLE _ptr
  if "!_ptr!"=="" goto :_detok_done
  if "!_ptr!"=="0" goto :_detok_done
  @REM Read line number (2 bytes LE)
  call :_hexWordLE _ln
  @REM Begin building our internal token list for this line.
  set "_toks=LN__!_ln!"
  call :_detokLineBody
  set "_toks=!_toks! EOL"
  @REM Store the line.
  call %GWSRC%\exec\_program add !_ln! "!_toks!"
  goto :_detok_lineLoop
:_detok_done
  endlocal & exit /B 0


@REM --- internal: consume one byte from _all at _pos, return 2-hex in retVar ---
:_hexByte
  set "%~1=!_all:~%_pos%,2!"
  set /a "_pos+=2"
  exit /B 0


@REM --- internal: consume one 2-byte LE word, return decimal value in retVar ---
:_hexWordLE
  set "_lo=!_all:~%_pos%,2!"
  set /a "_pos+=2"
  set "_hi=!_all:~%_pos%,2!"
  set /a "_pos+=2"
  if "!_lo!"=="" (set "%~1=" & exit /B 0)
  set /a "%~1=0x!_hi!!_lo!"
  exit /B 0


@REM --- internal: walk one line's content, append tokens to _toks until 0x00 ---
:_detokLineBody
:_dlb_loop
  set "_b=!_all:~%_pos%,2!"
  if "!_b!"=="" exit /B 0
  set /a "_pos+=2"
  @REM End of line
  if "!_b!"=="00" exit /B 0
  @REM Skip embedded ASCII spaces (cosmetic in binary)
  if "!_b!"=="20" goto :_dlb_loop
  @REM Numeric literal markers
  if "!_b!"=="0B" (
    call :_hexWordLE _v
    call :_int16Oct !_v! _h
    set "_toks=!_toks! OCT_!_h!"
    goto :_dlb_loop
  )
  if "!_b!"=="0C" (
    call :_hexWordLE _v
    call :_int16HexStrip !_v! _h
    set "_toks=!_toks! HEX_!_h!"
    goto :_dlb_loop
  )
  if "!_b!"=="0E" (
    @REM Line-number reference — emit as NUM_i<hex16>
    call :_hexWordLE _v
    call :_int16Hex !_v! _h
    set "_toks=!_toks! NUM_i!_h!"
    goto :_dlb_loop
  )
  if "!_b!"=="0F" (
    @REM 1-byte unsigned int
    call :_hexByte _bb
    set /a "_v=0x!_bb!"
    call :_int16Hex !_v! _h
    set "_toks=!_toks! NUM_i!_h!"
    goto :_dlb_loop
  )
  if "!_b!"=="1C" (
    @REM 2-byte LE signed int
    call :_hexWordLE _v
    @REM Sign-correct: value > 32767 means negative
    if !_v! GTR 32767 set /a "_v=_v-65536"
    call :_int16Hex !_v! _h
    set "_toks=!_toks! NUM_i!_h!"
    goto :_dlb_loop
  )
  if "!_b!"=="1D" (
    @REM MBF single: 4 bytes LE-mantissa, exp last. Bias 129 → our 128: subtract 1 from exp.
    call :_hexByte _m0
    call :_hexByte _m1
    call :_hexByte _m2
    call :_hexByte _ee
    set /a "_e=0x!_ee!-1"
    call :_byteHex !_e! _eh
    set "_toks=!_toks! NUM_s!_eh!!_m2!!_m1!!_m0!"
    goto :_dlb_loop
  )
  if "!_b!"=="1F" (
    @REM MBF double: 8 bytes LE-mantissa, exp last. Bias 129 → 128.
    call :_hexByte _m0
    call :_hexByte _m1
    call :_hexByte _m2
    call :_hexByte _m3
    call :_hexByte _m4
    call :_hexByte _m5
    call :_hexByte _m6
    call :_hexByte _ee
    set /a "_e=0x!_ee!-1"
    call :_byteHex !_e! _eh
    set "_toks=!_toks! NUM_d!_eh!!_m6!!_m5!!_m4!!_m3!!_m2!!_m1!!_m0!"
    goto :_dlb_loop
  )
  @REM Small int constants 0-9
  if "!_b!"=="11" (set "_toks=!_toks! NUM_i0000" & goto :_dlb_loop)
  if "!_b!"=="12" (set "_toks=!_toks! NUM_i0001" & goto :_dlb_loop)
  if "!_b!"=="13" (set "_toks=!_toks! NUM_i0002" & goto :_dlb_loop)
  if "!_b!"=="14" (set "_toks=!_toks! NUM_i0003" & goto :_dlb_loop)
  if "!_b!"=="15" (set "_toks=!_toks! NUM_i0004" & goto :_dlb_loop)
  if "!_b!"=="16" (set "_toks=!_toks! NUM_i0005" & goto :_dlb_loop)
  if "!_b!"=="17" (set "_toks=!_toks! NUM_i0006" & goto :_dlb_loop)
  if "!_b!"=="18" (set "_toks=!_toks! NUM_i0007" & goto :_dlb_loop)
  if "!_b!"=="19" (set "_toks=!_toks! NUM_i0008" & goto :_dlb_loop)
  if "!_b!"=="1A" (set "_toks=!_toks! NUM_i0009" & goto :_dlb_loop)
  @REM String literal: starts with ", read until next " or 00.
  if "!_b!"=="22" (
    set "_strhex="
    :_dlb_str_loop
    set "_sb=!_all:~%_pos%,2!"
    if "!_sb!"=="" goto :_dlb_str_done
    if "!_sb!"=="22" (set /a "_pos+=2" & goto :_dlb_str_done)
    if "!_sb!"=="00" goto :_dlb_str_done
    set "_strhex=!_strhex!!_sb!"
    set /a "_pos+=2"
    goto :_dlb_str_loop
    :_dlb_str_done
    set "_toks=!_toks! STR_!_strhex!"
    goto :_dlb_loop
  )
  @REM REM keyword (0x8F): rest of line is comment body
  @REM   8F <body>      explicit REM — emit "REM REM_<body>"
  @REM   8F D9 <body>   apostrophe shorthand — emit only "REM_<body>"
  @REM                  (matches ASCII lexer's "'foo" output)
  if "!_b!"=="8F" (
    if "!_all:~%_pos%,2!"=="D9" (
      set /a "_pos+=2"
      call :_collectApoBody
    ) else (
      set "_toks=!_toks! REM"
      call :_collectRemBody
    )
    goto :_dlb_loop
  )
  @REM Comparison operators with optional second byte: >, >=, <, <=, <>, =
  if "!_b!"=="E6" (
    if "!_all:~%_pos%,2!"=="E7" (
      set "_toks=!_toks! GE"
      set /a "_pos+=2"
      goto :_dlb_loop
    )
    set "_toks=!_toks! GT"
    goto :_dlb_loop
  )
  if "!_b!"=="E8" (
    if "!_all:~%_pos%,2!"=="E7" (
      set "_toks=!_toks! LE"
      set /a "_pos+=2"
      goto :_dlb_loop
    )
    if "!_all:~%_pos%,2!"=="E6" (
      set "_toks=!_toks! NE"
      set /a "_pos+=2"
      goto :_dlb_loop
    )
    set "_toks=!_toks! LT"
    goto :_dlb_loop
  )
  @REM ASCII printable 0x21-0x7E (excluding " handled above): operators, punctuation, var name chars
  set /a "_bv=0x!_b!"
  if !_bv! GEQ 33 if !_bv! LEQ 126 (
    call :_asciiToken !_b!
    goto :_dlb_loop
  )
  @REM 2-byte keyword tokens
  if "!_b!"=="FD" (
    call :_hexByte _b2
    call %GWSRC%\lexer\keyword fromCode FD!_b2! _name
    if defined _name set "_toks=!_toks! !_name!"
    goto :_dlb_loop
  )
  if "!_b!"=="FE" (
    call :_hexByte _b2
    call %GWSRC%\lexer\keyword fromCode FE!_b2! _name
    if defined _name set "_toks=!_toks! !_name!"
    goto :_dlb_loop
  )
  if "!_b!"=="FF" (
    call :_hexByte _b2
    call %GWSRC%\lexer\keyword fromCode FF!_b2! _name
    if defined _name set "_toks=!_toks! !_name!"
    goto :_dlb_loop
  )
  @REM Single-byte keyword token (or operator)
  call %GWSRC%\lexer\keyword fromCode !_b! _name
  if defined _name set "_toks=!_toks! !_name!"
  goto :_dlb_loop


@REM --- internal: collect REM body bytes (until 0x00 EOL) into REM_<hex> ---
:_collectRemBody
  set "_body="
:_rb_loop
  set "_bb=!_all:~%_pos%,2!"
  if "!_bb!"=="" goto :_rb_done
  if "!_bb!"=="00" goto :_rb_done
  set "_body=!_body!!_bb!"
  set /a "_pos+=2"
  goto :_rb_loop
:_rb_done
  if defined _body set "_toks=!_toks! REM_!_body!"
  exit /B 0


@REM --- internal: collect apostrophe-REM body, emit REM_<hex> (no preceding REM) ---
@REM Caller has already consumed the 0x8F and 0xD9 marker bytes.
:_collectApoBody
  set "_body="
:_ab_loop
  set "_bb=!_all:~%_pos%,2!"
  if "!_bb!"=="" goto :_ab_done
  if "!_bb!"=="00" goto :_ab_done
  set "_body=!_body!!_bb!"
  set /a "_pos+=2"
  goto :_ab_loop
:_ab_done
  set "_toks=!_toks! REM_!_body!"
  exit /B 0


@REM --- internal: handle an ASCII byte in _b. Emit our token equivalent. ---
@REM Labels are kept at top level (cannot be inside a parenthesised block).
:_asciiToken
  set "_c=%~1"
  if "!_c!"=="28" (set "_toks=!_toks! OPAR" & exit /B 0)
  if "!_c!"=="29" (set "_toks=!_toks! CPAR" & exit /B 0)
  if "!_c!"=="2C" (set "_toks=!_toks! COMA" & exit /B 0)
  if "!_c!"=="3B" (set "_toks=!_toks! SEMICOLON" & exit /B 0)
  if "!_c!"=="3A" (set "_toks=!_toks! COLON" & exit /B 0)
  if "!_c!"=="23" (set "_toks=!_toks! HASH" & exit /B 0)
  set /a "_cv=0x!_c!"
  set "_isLet="
  if !_cv! GEQ 65 if !_cv! LEQ 90 set "_isLet=1"
  if !_cv! GEQ 97 if !_cv! LEQ 122 set "_isLet=1"
  if not defined _isLet exit /B 0
  set "_idHex=!_c!"
:_at_id_loop
  set "_nb=!_all:~%_pos%,2!"
  if "!_nb!"=="" goto :_at_id_done
  set /a "_nv=0x!_nb!"
  set "_isAlnum="
  if !_nv! GEQ 48 if !_nv! LEQ 57 set "_isAlnum=1"
  if !_nv! GEQ 65 if !_nv! LEQ 90 set "_isAlnum=1"
  if !_nv! GEQ 97 if !_nv! LEQ 122 set "_isAlnum=1"
  if not defined _isAlnum goto :_at_id_done
  set "_idHex=!_idHex!!_nb!"
  set /a "_pos+=2"
  goto :_at_id_loop
:_at_id_done
  @REM Binary-format identifier bytes are already uppercase (GW-BASIC normalises
  @REM on SAVE), so no _upper call is needed.
  call %GWSRC%\str\str decode !_idHex! _name
  set "_suf=!_all:~%_pos%,2!"
  set "_typ=UNK"
  if "!_suf!"=="25" (set "_typ=INT" & set /a "_pos+=2")
  if "!_suf!"=="21" (set "_typ=SNG" & set /a "_pos+=2")
  if "!_suf!"=="23" (set "_typ=DBL" & set /a "_pos+=2")
  if "!_suf!"=="24" (set "_typ=STR" & set /a "_pos+=2")
  set "_toks=!_toks! VAR_!_typ!_!_name!"
  exit /B 0


@REM --- internal: uppercase the value of var named by %~1, in place ---
:_upper
  set "_uv=!%~1!"
  for %%a in (a=A b=B c=C d=D e=E f=F g=G h=H i=I j=J k=K l=L m=M
              n=N o=O p=P q=Q r=R s=S t=T u=U v=V w=W x=X y=Y z=Z) do (
    for /f "tokens=1,2 delims==" %%i in ("%%a") do set "_uv=!_uv:%%i=%%j!"
  )
  set "%~1=%_uv%"
  exit /B 0


@REM --- internal: format unsigned 16-bit number as 4-hex string in retVar ---
@REM Uses call-set double-substitution (no setlocal needed): outer %%…%% becomes
@REM %…% after the first pass, then `call` re-parses, expanding %_HD:~N,1% per digit.
:_int16Hex
  set /a "_v=%~1 & 0xFFFF"
  set /a "_h3=(_v>>12) & 15"
  set /a "_h2=(_v>>8)  & 15"
  set /a "_h1=(_v>>4)  & 15"
  set /a "_h0=_v       & 15"
  set "_HD=0123456789ABCDEF"
  call set "%~2=%%_HD:~%_h3%,1%%%%_HD:~%_h2%,1%%%%_HD:~%_h1%,1%%%%_HD:~%_h0%,1%%"
  exit /B 0


@REM --- internal: format 16-bit value as uppercase hex with no leading zeros ---
:_int16HexStrip
  call :_int16Hex %~1 _hs
:_i16hs_loop
  if "!_hs:~0,1!"=="0" if not "!_hs:~1!"=="" (set "_hs=!_hs:~1!" & goto :_i16hs_loop)
  set "%~2=!_hs!"
  exit /B 0


@REM --- internal: format 16-bit value as octal digits (no leading zeros) ---
:_int16Oct
  setlocal EnableDelayedExpansion
  set /a "_v=%~1 & 0xFFFF"
  if !_v!==0 (endlocal & set "%~2=0" & exit /B 0)
  set "_r="
:_oct_loop
  if !_v!==0 goto :_oct_done
  set /a "_d=_v %% 8"
  set /a "_v=_v / 8"
  set "_r=!_d!!_r!"
  goto :_oct_loop
:_oct_done
  endlocal & set "%~2=%_r%" & exit /B 0


@REM --- internal: format 0..255 as 2-hex string in retVar ---
:_byteHex
  set /a "_v=%~1 & 0xFF"
  set /a "_h1=(_v>>4) & 15"
  set /a "_h0=_v      & 15"
  set "_HD=0123456789ABCDEF"
  call set "%~2=%%_HD:~%_h1%,1%%%%_HD:~%_h0%,1%%"
  exit /B 0


@REM --- tokenize PATH: write current _program as binary `.BAS` ---
@REM Builds the file as a hex string in env vars, then certutil -decodehex
@REM writes the bytes to PATH.
:tokenize
  setlocal EnableDelayedExpansion
  set "_path=%~1"
  @REM Start with the FF header byte.
  set "_hex=FF"
  @REM Walk program lines in line-number order.
  for /f "usebackq tokens=1,* delims= " %%a in (`sort "%GWTEMP%\program.dat"`) do (
    call :_tokLine "%%b"
  )
  @REM Trailer: 00 00 (end-of-program ptr) + 1A (DOS Ctrl-Z).
  set "_hex=!_hex!00001A"
  @REM Emit hex to a temp file (no newlines inside hex), then decodehex.
  set "_hf=%TEMP%\_gwbas_save.hex"
  > "!_hf!" echo !_hex!
  del "!_path!" 2>nul
  certutil -decodehex "!_hf!" "!_path!" >nul 2>nul
  del "!_hf!" 2>nul
  endlocal
  exit /B 0


@REM --- internal: tokenize one program line, append to _hex ---
@REM %~1 is the stored token list "LN__nnn TOK TOK ... EOL"
:_tokLine
  set "_t=%~1"
  @REM Extract LN__nnn and the rest.
  set "_first="
  set "_rest="
  for /f "tokens=1*" %%a in ("!_t!") do (
    set "_first=%%a"
    set "_rest=%%b"
  )
  if not "!_first:~0,4!"=="LN__" exit /B 0
  set "_ln=!_first:~4!"
  @REM 2-byte little-endian hex of line number.
  call :_int16LEHex !_ln! _lnHex
  @REM Walk content tokens; insert a 0x20 separator between successive ones.
  set "_content="
  set "_isFirstTok=1"
  set "_prevTok="
  set "_lineRefMode="
  for %%t in (!_rest!) do call :_emitTok %%t
  @REM Pseudo next-line pointer (any 2-byte value; real GW-BASIC uses memory
  @REM addresses, but the loader only needs nonzero to mark "more lines").
  set "_ptr=0101"
  set "_hex=!_hex!!_ptr!!_lnHex!!_content!00"
  exit /B 0


@REM --- internal: emit one token's bytes into _content, with leading 0x20 separator ---
@REM Side effects:
@REM   _prevTok      = this token (used by next call for context-sensitive emit)
@REM   _lineRefMode  = 1 if a line-ref trigger keyword is active; consumed by
@REM                   NUM_i to emit "0E xx xx" instead of generic int encoding.
@REM                   Trigger keywords: GOTO GOSUB THEN ELSE RESUME RESTORE
@REM                   RUN LIST DELETE EDIT AUTO RENUM RETURN.  Preserved by
@REM                   COMA / MINUS / NUM_i; cleared by anything else.
:_emitTok
  set "_tk=%~1"
  @REM EOL marker is implicit; never emit it directly.
  if "!_tk!"=="EOL" exit /B 0
  @REM Track whether to prepend a separator. Most tokens get a leading 0x20,
  @REM except the very first content token (right after the line-number bytes).
  set "_sep=20"
  if defined _isFirstTok set "_sep="
  set "_isFirstTok="
  @REM Dispatch
  set "_pfx=!_tk:~0,4!"
  if "!_pfx!"=="NUM_" (
    call :_emitNum "!_tk!"
    set "_prevTok=!_tk!"
    @REM NUM_i preserves line-ref mode (LIST 10,20,30); NUM_s/d clear it.
    if not "!_tk:~4,1!"=="i" set "_lineRefMode="
    exit /B 0
  )
  if "!_pfx!"=="VAR_" (
    call :_emitVar "!_tk!"
    set "_prevTok=!_tk!"
    set "_lineRefMode="
    exit /B 0
  )
  if "!_pfx!"=="STR_" (
    set "_content=!_content!!_sep!22!_tk:~4!22"
    set "_prevTok=!_tk!"
    set "_lineRefMode="
    exit /B 0
  )
  if "!_pfx!"=="REM_" (
    @REM Three cases:
    @REM   prev=REM:   explicit "REM body" — REM already emitted 8F, just emit body.
    @REM   prev=COLON: apostrophe ":'body" — 3A is already there, emit "8F D9 body"
    @REM               with no separator (GW-BASIC stores ":REM'…" compactly).
    @REM   otherwise:  bare apostrophe at line start or after content — synthesize
    @REM               the leading 3A to match GW-BASIC's canonical form.
    if "!_prevTok!"=="REM" (
      set "_content=!_content!!_tk:~4!"
      set "_prevTok=!_tk!"
      set "_lineRefMode="
      exit /B 0
    )
    if "!_prevTok!"=="COLON" (
      set "_content=!_content!8FD9!_tk:~4!"
      set "_prevTok=!_tk!"
      set "_lineRefMode="
      exit /B 0
    )
    set "_content=!_content!!_sep!3A8FD9!_tk:~4!"
    set "_prevTok=!_tk!"
    set "_lineRefMode="
    exit /B 0
  )
  if "!_pfx!"=="HEX_" (
    call :_parseHex "!_tk:~4!" _v
    call :_int16LEHex !_v! _h
    set "_content=!_content!!_sep!0C!_h!"
    set "_prevTok=!_tk!"
    set "_lineRefMode="
    exit /B 0
  )
  if "!_pfx!"=="OCT_" (
    call :_parseOct "!_tk:~4!" _v
    call :_int16LEHex !_v! _h
    set "_content=!_content!!_sep!0B!_h!"
    set "_prevTok=!_tk!"
    set "_lineRefMode="
    exit /B 0
  )
  @REM Punctuation
  if "!_tk!"=="OPAR"      (set "_content=!_content!!_sep!28" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  if "!_tk!"=="CPAR"      (set "_content=!_content!!_sep!29" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  if "!_tk!"=="COMA"      (set "_content=!_content!!_sep!2C" & set "_prevTok=!_tk!" & exit /B 0)
  if "!_tk!"=="SEMICOLON" (set "_content=!_content!!_sep!3B" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  if "!_tk!"=="COLON"     (set "_content=!_content!!_sep!3A" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  if "!_tk!"=="HASH"      (set "_content=!_content!!_sep!23" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  @REM Operators (single-byte tokens)
  if "!_tk!"=="GT"    (set "_content=!_content!!_sep!E6" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  if "!_tk!"=="EQ"    (set "_content=!_content!!_sep!E7" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  if "!_tk!"=="LT"    (set "_content=!_content!!_sep!E8" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  if "!_tk!"=="PLUS"  (set "_content=!_content!!_sep!E9" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  if "!_tk!"=="MINUS" (set "_content=!_content!!_sep!EA" & set "_prevTok=!_tk!" & exit /B 0)
  if "!_tk!"=="MUL"   (set "_content=!_content!!_sep!EB" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  if "!_tk!"=="DIV"   (set "_content=!_content!!_sep!EC" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  if "!_tk!"=="POW"   (set "_content=!_content!!_sep!ED" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  if "!_tk!"=="IDIV"  (set "_content=!_content!!_sep!F4" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  @REM Multi-byte comparison composites (emit two operator bytes)
  if "!_tk!"=="GE"    (set "_content=!_content!!_sep!E6E7" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  if "!_tk!"=="LE"    (set "_content=!_content!!_sep!E8E7" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  if "!_tk!"=="NE"    (set "_content=!_content!!_sep!E8E6" & set "_prevTok=!_tk!" & set "_lineRefMode=" & exit /B 0)
  @REM Otherwise: a keyword name — look up byte code.
  call %GWSRC%\lexer\keyword toCode "!_tk!" _kc
  if defined _kc (
    set "_content=!_content!!_sep!!_kc!"
    set "_prevTok=!_tk!"
    @REM Trigger keywords arm line-ref mode; any other keyword clears it.
    set "_lineRefMode="
    if "!_tk!"=="GOTO"    set "_lineRefMode=1"
    if "!_tk!"=="GOSUB"   set "_lineRefMode=1"
    if "!_tk!"=="THEN"    set "_lineRefMode=1"
    if "!_tk!"=="ELSE"    set "_lineRefMode=1"
    if "!_tk!"=="RESUME"  set "_lineRefMode=1"
    if "!_tk!"=="RESTORE" set "_lineRefMode=1"
    if "!_tk!"=="RUN"     set "_lineRefMode=1"
    if "!_tk!"=="LIST"    set "_lineRefMode=1"
    if "!_tk!"=="DELETE"  set "_lineRefMode=1"
    if "!_tk!"=="EDIT"    set "_lineRefMode=1"
    if "!_tk!"=="AUTO"    set "_lineRefMode=1"
    if "!_tk!"=="RENUM"   set "_lineRefMode=1"
    if "!_tk!"=="RETURN"  set "_lineRefMode=1"
    exit /B 0
  )
  @REM Unknown token — drop silently.
  set "_prevTok=!_tk!"
  set "_lineRefMode="
  exit /B 0


@REM --- internal: NUM_<tagged> → emit best-fit binary representation ---
:_emitNum
  set "_n=%~1"
  set "_tag=!_n:~4,1!"
  if "!_tag!"=="i" (
    @REM signed 16-bit integer; lexer emits only 0..32767 (negative is MINUS+pos)
    set "_h4=!_n:~5!"
    set /a "_iv=0x!_h4!"
    if !_iv! GTR 32767 set /a "_iv=_iv-65536"
    @REM Line-reference context (after GOTO/GOSUB/THEN/etc.): always use 0E LE-word.
    @REM Required for RENUM to find references; runtime is unchanged.
    if defined _lineRefMode (
      if !_iv! GEQ 0 (
        call :_int16LEHex !_iv! _h
        set "_content=!_content!!_sep!0E!_h!"
        exit /B 0
      )
    )
    if !_iv! GEQ 0 if !_iv! LEQ 9 (
      @REM small int constant 0..9 → 0x11..0x1A
      set /a "_cc=0x11 + _iv"
      call :_byteHex !_cc! _h
      set "_content=!_content!!_sep!!_h!"
      exit /B 0
    )
    if !_iv! GEQ 10 if !_iv! LEQ 255 (
      call :_byteHex !_iv! _h
      set "_content=!_content!!_sep!0F!_h!"
      exit /B 0
    )
    @REM 2-byte LE int
    if !_iv! LSS 0 set /a "_iv=_iv & 0xFFFF"
    call :_int16LEHex !_iv! _h
    set "_content=!_content!!_sep!1C!_h!"
    exit /B 0
  )
  if "!_tag!"=="s" (
    @REM 1D + 4 bytes MBF (LE mantissa, exp last, bias 129 = our 128 + 1)
    set "_eh=!_n:~5,2!"
    set "_m2=!_n:~7,2!"
    set "_m1=!_n:~9,2!"
    set "_m0=!_n:~11,2!"
    set /a "_e=0x!_eh!+1"
    call :_byteHex !_e! _eh2
    set "_content=!_content!!_sep!1D!_m0!!_m1!!_m2!!_eh2!"
    exit /B 0
  )
  if "!_tag!"=="d" (
    set "_eh=!_n:~5,2!"
    set "_m6=!_n:~7,2!"
    set "_m5=!_n:~9,2!"
    set "_m4=!_n:~11,2!"
    set "_m3=!_n:~13,2!"
    set "_m2=!_n:~15,2!"
    set "_m1=!_n:~17,2!"
    set "_m0=!_n:~19,2!"
    set /a "_e=0x!_eh!+1"
    call :_byteHex !_e! _eh2
    set "_content=!_content!!_sep!1F!_m0!!_m1!!_m2!!_m3!!_m4!!_m5!!_m6!!_eh2!"
    exit /B 0
  )
  exit /B 0


@REM --- internal: VAR_TYP_NAME → emit ASCII name + optional type suffix byte ---
:_emitVar
  set "_n=%~1"
  set "_typ=!_n:~4,3!"
  set "_nm=!_n:~8!"
  @REM Encode the name as hex ASCII bytes.
  call %GWSRC%\str\str encode "!_nm!" _nh
  set "_content=!_content!!_sep!!_nh!"
  if "!_typ!"=="INT" set "_content=!_content!25"
  if "!_typ!"=="SNG" set "_content=!_content!21"
  if "!_typ!"=="DBL" set "_content=!_content!23"
  if "!_typ!"=="STR" set "_content=!_content!24"
  exit /B 0


@REM --- internal: format 16-bit value as 4-hex string in little-endian (LO HI) ---
:_int16LEHex
  set /a "_v=%~1 & 0xFFFF"
  set /a "_lo=_v & 0xFF"
  set /a "_hi=(_v>>8) & 0xFF"
  call :_byteHex !_lo! _loh
  call :_byteHex !_hi! _hih
  set "%~2=!_loh!!_hih!"
  exit /B 0


@REM --- internal: parse hex digit string → integer ---
:_parseHex
  set /a "_v=0x%~1"
  set "%~2=!_v!"
  exit /B 0


@REM --- internal: parse octal digit string → integer ---
:_parseOct
  set "_s=%~1"
  set /a "_v=0"
:_po_loop
  if "!_s!"=="" (set "%~2=!_v!" & exit /B 0)
  set /a "_v=_v*8 + !_s:~0,1!"
  set "_s=!_s:~1!"
  goto :_po_loop


:_start
  echo _binary.bat - GW-BASIC .BAS binary tokenizer/detokenizer
