@echo off
@REM RSET [#]target$ = expr : pack expr into the FIELD window for target$
@REM (right-justify, space-pad/truncate to the field WIDTH).  If target$ is
@REM not a field var, fall back to a plain string assignment (GW behaviour).
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _val
call %GWSRC%\stl\vec pop %_s% _tgt
call %GWSRC%\exec\_resolve !_val! _val
set "_vhex="
if "!_val:~0,4!"=="STR_" if not "!_val!"=="STR_" set "_vhex=!_val:~4!"
call %GWSRC%\exec\_files fget !_tgt! _f
if errorlevel 1 goto :_ls_plain
@REM field hit: build WIDTH bytes, right-justified
set /a "_max=_fwidth*2"
set "_take=!_vhex:~0,%_max%!"
call :_hexlen "!_take!" _tk
set /a "_pn=_fwidth-_tk"
if !_pn! LSS 0 set "_pn=0"
set "_pad="
if !_pn! GTR 0 for /L %%i in (1,1,!_pn!) do set "_pad=!_pad!20"
set "_field=!_pad!!_take!"
@REM splice _field (WIDTH bytes) into the buffer at offset _foff
call %GWSRC%\exec\_files bufget !_fn! _buf
set /a "_p=_foff*2"
set /a "_aft=_p+_max"
set "_buf=!_buf:~0,%_p%!!_field!!_buf:~%_aft%!"
call %GWSRC%\exec\_files bufput !_fn! !_buf!
goto :_ls_done
:_ls_plain
@REM not a field var: plain assignment (left part into the existing string)
call %GWSRC%\exec\_vars set !_tgt! !_val!
:_ls_done
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

@REM _hexlen HEX retvar -> number of BYTES (hex chars / 2)
:_hexlen
  setlocal EnableDelayedExpansion
  set "_hl=%~1" & set /a "_n=0"
:_hl_loop
  if not "!_hl!"=="" (set "_hl=!_hl:~2!" & set /a "_n+=1" & goto :_hl_loop)
  endlocal & set "%~2=%_n%" & exit /B 0
