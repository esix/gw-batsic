@echo off
@REM GW-BATSIC: GW-BASIC interpreter in batch files
@REM
@REM Usage: gw-batsic [file.bas]
@REM   With no args: empty program, start REPL.
@REM   With a filename: load the file then start REPL.

setlocal EnableDelayedExpansion
set "GWSRC=%~dp0src"
set "GWTEMP=%~dp0temp"
chcp 65001 >nul

call %GWSRC%\exec\_program init

@REM If a filename was given, load it before launching the REPL.
if not "%~1"=="" (
  if not exist "%~1" (
    echo File not found: %~1
  ) else (
    call %GWSRC%\file\file load "%~1"
  )
)

call %GWSRC%\exec\exec
endlocal
