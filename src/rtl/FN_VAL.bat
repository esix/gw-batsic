@echo off
@REM FN_VAL: VAL(s) — string → number.  Returns 0 if the string doesn't
@REM start with a numeric form.  Supports leading sign, digits, optional
@REM decimal point.  Returns single-precision result.
@REM Stack: STR_<hex> → NUM_s<...>.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
if not "!_a:~0,4!"=="STR_" (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
call %GWSRC%\str\str decode !_a:~4! _txt
@REM Strip leading whitespace
:_val_lstrip
  if not defined _txt goto :_val_parse
  if "!_txt:~0,1!"==" " (set "_txt=!_txt:~1!" & goto :_val_lstrip)
:_val_parse
@REM Take chars matching [+-]?[0-9]*\.?[0-9]*[eEdD][+-]?[0-9]*
set "_num="
set "_c=!_txt:~0,1!"
if "!_c!"=="+" (set "_num=+" & set "_txt=!_txt:~1!")
if "!_c!"=="-" (set "_num=-" & set "_txt=!_txt:~1!")
:_val_digits
  set "_c=!_txt:~0,1!"
  if "!_c!"=="" goto :_val_done
  set "_ok="
  for %%d in (0 1 2 3 4 5 6 7 8 9 .) do if "!_c!"=="%%d" set "_ok=1"
  if not defined _ok goto :_val_done
  set "_num=!_num!!_c!"
  set "_txt=!_txt:~1!"
  goto :_val_digits
:_val_done
@REM Empty (or just a sign) → 0.
if not defined _num set "_num=0"
if "!_num!"=="+" set "_num=0"
if "!_num!"=="-" set "_num=0"
@REM Parse via sng fromDec.
call %GWSRC%\num\sng fromDec !_num!
if errorlevel 1 (
  @REM Couldn't parse — return 0.
  call %GWSRC%\num\sng fromDec 0
)
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
