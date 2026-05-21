@echo off
@REM FN_MID: MID$(s, start [, len]) — substring from 1-based position.
@REM Stack always has three operands (the grammar's @MID_DEFAULT_LEN pushes
@REM i7FFF as a sentinel when the user wrote no length).
@REM Stack: STR_<hex> NUM_i<start> NUM_i<len> → STR_<sub>
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _lenT
call %GWSRC%\stl\vec pop %_s% _startT
call %GWSRC%\stl\vec pop %_s% _a
call %GWSRC%\exec\_resolve !_lenT! _lenT
call %GWSRC%\exec\_resolve !_startT! _startT
call %GWSRC%\exec\_resolve !_a! _a

if not "!_a:~0,4!"=="STR_" (
  set "_final=!%_s%!"
  endlocal & set "%~1=%_final%" & exit /B 13
)
call :_toIntDec !_startT! _startN
call :_toIntDec !_lenT! _lenN
if !_startN! LSS 1 goto :_fnmid_err
if !_lenN! LSS 0 goto :_fnmid_err

set "_h=!_a:~4!"
set /a "_skip=(_startN-1)*2"
set /a "_take=_lenN*2"
@REM Clamp take to remaining length
set "_rem=!_h:~%_skip%!"
set "_out=!_rem:~0,%_take%!"
call %GWSRC%\stl\vec push %_s% STR_!_out!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0

:_fnmid_err
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 5

:_toIntDec
  set "_v=%~1"
  set "_t=!_v:~0,1!"
  if "!_t!"=="i" (call %GWSRC%\num\int toDec !_v! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="s" (call %GWSRC%\num\sng toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  if "!_t!"=="d" (call %GWSRC%\num\dbl toInt !_v! & call %GWSRC%\num\int toDec !__! & set "%~2=!__!" & exit /B 0)
  exit /B 13
