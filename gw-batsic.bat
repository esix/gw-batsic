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

@REM Lexer needs the keyword table populated before LOAD runs, since LOAD
@REM tokenizes each source line as it reads it.  (exec.bat re-inits the
@REM table itself when it starts the REPL — harmless to do it twice.)
call %GWSRC%\lexer\keyword init
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
