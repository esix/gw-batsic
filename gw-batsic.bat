@echo off
@REM GW-BATSIC: GW-BASIC interpreter in batch files
setlocal EnableDelayedExpansion
set "GWSRC=%~dp0src"
set "GWTEMP=%~dp0temp"
chcp 65001 >nul

@REM Fresh program on startup (CLI args for loading a file go here later,
@REM before the REPL launches).
call %GWSRC%\exec\_program init

@REM Start the executor REPL (interactive mode)
call %GWSRC%\exec\exec
endlocal
