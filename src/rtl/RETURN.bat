@echo off
@REM RETURN: pop return address from gosub stack into _next_line
setlocal EnableDelayedExpansion
call %GWSRC%\stl\vec pop _gosub_stack _t
if not defined _t (
  echo RETURN without GOSUB 1>&2
  endlocal & exit /B 3
)
endlocal & set "_next_line=%_t%" & set "_gosub_stack=%_gosub_stack%" & exit /B 0
