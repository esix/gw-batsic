@echo off
@REM Rebuild parse table from bnf.txt
@REM Run this manually when bnf.txt changes.
@REM Produces: _table.dat (committed to git, used by parser at runtime)

setlocal EnableDelayedExpansion
set "PATH=%~dp0;%~dp0..\stl;%PATH%"

echo [rebuild] Reading grammar...
call _nonterminals read "%~dp0bnf.txt"
call _terminals compute
echo [rebuild] Computing FIRST sets...
call _first compute
echo [rebuild] Computing FOLLOW sets...
call _follow compute
echo [rebuild] Building parse table...
call _table compute
echo [rebuild] Saving _table.dat...
call _table saveCache "%~dp0_table.dat"
echo [rebuild] Done.
echo.
call _table dump

endlocal
