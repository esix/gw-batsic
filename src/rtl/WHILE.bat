@echo off
@REM WHILE: pop the condition.  If true, remember this line so WEND can jump
@REM back and re-evaluate.  If false, scan forward in program.dat to the
@REM matching WEND and resume after it.
@REM
@REM Loop stack: _while_stack — top is the line number of the WHILE statement
@REM that opened the currently-active loop.
@REM
@REM Errors:
@REM   29 — WHILE without WEND (scan reached end of program without matching WEND)
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _cond
call %GWSRC%\exec\_resolve !_cond! _cond
set "_t=!_cond:~0,1!"
set "_truthy=0"
if "!_t!"=="i" if not "!_cond:~1!"=="0000" set "_truthy=1"
if "!_t!"=="s" if not "!_cond:~1!"=="00000000" set "_truthy=1"
if "!_t!"=="d" if not "!_cond:~1!"=="0000000000000000" set "_truthy=1"

if "!_truthy!"=="1" (
  call %GWSRC%\stl\vec push _while_stack !_cur_line!
  goto :_while_push_done
)

@REM Cond false — find the matching WEND.
call :_findWend !_cur_line! _after
if errorlevel 1 goto :_while_no_wend
goto :_while_skip_done

:_while_push_done
@REM Single-line endlocal so %_while_stack% is parse-time captured AFTER the push.
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_while_stack=%_while_stack%" & exit /B 0

:_while_no_wend
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 29

:_while_skip_done
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_next_line=%_after%" & exit /B 0


@REM _findWend FROM_LINE retVar
@REM Walks program.dat lines in sorted order, looking for the WEND that
@REM matches the WHILE on FROM_LINE.  retVar gets the line number that
@REM comes AFTER the matching WEND (empty if there is none — program ends).
@REM Returns retVar unset only if no matching WEND was found.
:_findWend
  setlocal EnableDelayedExpansion
  set "_from=%~1"
  set /a "_depth=1"
  set "_phase=before"
  set "_matched="
  set "_after="
  for /f "usebackq tokens=1*" %%k in (`sort "%GWTEMP%\program.dat"`) do (
    if not defined _after if "!_phase!" neq "done" (
      set "_keyL=%%k"
      set "_toksL=%%l"
      call :_keyToLn !_keyL! _ln
      if "!_phase!"=="after_match" (
        set "_after=!_ln!"
        set "_phase=done"
      ) else (
        if "!_phase!"=="scan" (
          @REM Stored tokens always start with LN__nnn; second word is the
          @REM first real statement token.
          for /f "tokens=2" %%w in ("!_toksL!") do set "_fw=%%w"
          if "!_fw!"=="WHILE" set /a "_depth+=1"
          if "!_fw!"=="WEND" (
            set /a "_depth-=1"
            if !_depth! LEQ 0 (
              set "_matched=!_ln!"
              set "_phase=after_match"
            )
          )
        )
        if "!_ln!"=="!_from!" set "_phase=scan"
      )
    )
  )
  if defined _matched (
    endlocal & set "%~2=%_after%" & exit /B 0
  )
  endlocal & exit /B 1

@REM _keyToLn KEY retVar — strip leading zeros from a 5-digit sort key
:_keyToLn
  setlocal EnableDelayedExpansion
  set "_k=%~1"
:_kln_loop
  if "!_k:~0,1!"=="0" if not "!_k:~1!"=="" (set "_k=!_k:~1!" & goto :_kln_loop)
  endlocal & set "%~2=%_k%" & exit /B 0
