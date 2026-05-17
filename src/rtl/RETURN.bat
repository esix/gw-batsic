@echo off
@REM RETURN: pop return address from gosub stack into _next_line.
@REM Exit 3 → GW-BASIC "RETURN without GOSUB"; the central printer emits it.
setlocal EnableDelayedExpansion
call %GWSRC%\stl\vec pop _gosub_stack _t
if not defined _t (endlocal & exit /B 3)
endlocal & set "_next_line=%_t%" & set "_gosub_stack=%_gosub_stack%" & exit /B 0
