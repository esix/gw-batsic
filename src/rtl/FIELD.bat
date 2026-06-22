@echo off
@REM FIELD [#]n, w1 AS v1$, w2 AS v2$, ... — declare field vars as live windows
@REM over handle n's record buffer (Architecture A).  Stack (bottom->top):
@REM   handle FIELD_MRK w1 V1 w2 V2 ...   (Vi are VAR_/AREF target tokens).
@REM Registers each Vi at the accumulating byte offset; re-FIELD just replaces
@REM the row, so overlapping/aliased views coexist over one buffer.
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_pairs="
:_fld_pop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_fld_done
  if "!_v!"=="FIELD_MRK" goto :_fld_done
  call %GWSRC%\stl\vec pop %_s% _w
  call %GWSRC%\exec\_resolve !_w! _w
  call :_toInt !_w! _wi
  @REM Prepend so the list ends up in declaration order (offsets accumulate).
  set "_pairs=!_wi! !_v! !_pairs!"
  goto :_fld_pop
:_fld_done
call %GWSRC%\stl\vec pop %_s% _handle
call %GWSRC%\exec\_resolve !_handle! _handle
call :_toInt !_handle! _n
if not exist "%GWTEMP%\recbuf_!_n!.hex" call %GWSRC%\exec\_files bufinit !_n!
set "_off=0"
:_fld_reg
  if "!_pairs!"=="" goto :_fld_end
  for /f "tokens=1,2,*" %%a in ("!_pairs!") do (set "_w=%%a" & set "_v=%%b" & set "_pairs=%%c")
  call %GWSRC%\exec\_files freg !_v! !_n! !_off! !_w!
  set /a "_off+=_w"
  goto :_fld_reg
:_fld_end
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

@REM No setlocal (must return __ in caller scope), so use private names
@REM _tiv/_tit — must NOT touch _v (FIELD reuses _v as the field-var token).
:_toInt
  set "_tiv=%~1" & set "_tit=!_tiv:~0,1!"
  if "!_tit!"=="i" call %GWSRC%\num\int toDec !_tiv!
  if "!_tit!"=="s" (call %GWSRC%\num\sng toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  if "!_tit!"=="d" (call %GWSRC%\num\dbl toInt !_tiv! & call %GWSRC%\num\int toDec !__!)
  set "%~2=%__%"
  exit /B 0
