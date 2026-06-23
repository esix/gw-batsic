@echo off
@REM DEF FN: store a user function as name -> (param tokens, body postfix).
@REM The body postfix was captured by exec.bat into _capBuf (it is NOT run at
@REM definition time).  Stack: name PARAM_MRK p1 p2 ...  ->  (consumed).
@REM deffns.dat line: <nametoken> <nparams> <p1> ... <pn> <body postfix>
setlocal EnableDelayedExpansion
set "_s=%~1"
set "_body=!_capBuf!"
if "!_body:~0,1!"==" " set "_body=!_body:~1!"
set "_params="
set "_np=0"
:_pop
  call %GWSRC%\stl\vec pop %_s% _v
  if not defined _v goto :_done
  if "!_v!"=="PARAM_MRK" goto :_done
  set "_params=!_v! !_params!"
  set /a "_np+=1"
  goto :_pop
:_done
call %GWSRC%\stl\vec pop %_s% _name
set "_line=!_name! !_np! !_params!!_body!"
if exist "%GWTEMP%\deffns.dat" (
  type nul > "%GWTEMP%\deffns.dat.tmp"
  for /f "usebackq tokens=1*" %%a in ("%GWTEMP%\deffns.dat") do (
    if /I not "%%a"=="!_name!" >> "%GWTEMP%\deffns.dat.tmp" echo %%a %%b
  )
  move /Y "%GWTEMP%\deffns.dat.tmp" "%GWTEMP%\deffns.dat" >nul
)
>> "%GWTEMP%\deffns.dat" echo !_line!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
