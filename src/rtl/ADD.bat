@echo off
@REM ADD: pop two values; numeric add or string concat depending on types.
@REM   STR_ + STR_           → concatenated STR_ ("ab" + "cd" → "abcd")
@REM   numeric + numeric     → promote to common type, num/<t> add, push
@REM   any other combination → 13 Type mismatch
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _b
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_a! _a
call %GWSRC%\exec\_resolve !_b! _b

@REM String operands
set "_aIsStr="
set "_bIsStr="
if "!_a:~0,4!"=="STR_" set "_aIsStr=1"
if "!_b:~0,4!"=="STR_" set "_bIsStr=1"
if defined _aIsStr if defined _bIsStr goto :_add_concat
if defined _aIsStr goto :_add_mismatch
if defined _bIsStr goto :_add_mismatch

@REM Numeric add
call %GWSRC%\exec\_promote !_a! !_b!
set "_mod="
if "!__t!"=="i" set "_mod=int"
if "!__t!"=="s" set "_mod=sng"
if "!__t!"=="d" set "_mod=dbl"
if not defined _mod (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
call %GWSRC%\num\!_mod! add !__a! !__b!
set "_e=!ERRORLEVEL!"
if !_e! neq 0 (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B %_e%
)
call %GWSRC%\stl\vec push %_s% !__!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_add_concat
call %GWSRC%\stl\vec push %_s% STR_!_a:~4!!_b:~4!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_add_mismatch
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 13
