@echo off
@REM GW-BATSIC: GW-BASIC interpreter in batch files
@REM
@REM Usage: gw-batsic [/R] [file.bas]
@REM   no args        empty program, start REPL.
@REM   file.bas       load the file then start REPL.
@REM   /R file.bas    load, RUN, exit (no REPL).  Exit code = GW-BASIC err code.

setlocal EnableDelayedExpansion
set "GWSRC=%~dp0src"
set "GWTEMP=%~dp0temp"
chcp 65001 >nul

@REM Parse /R switch (case-insensitive).  Shifts file arg into %~1.
set "_runonce="
if /I "%~1"=="/R" (
  set "_runonce=1"
  shift
)

@REM Lexer needs the keyword table populated before LOAD runs, since LOAD
@REM tokenizes each source line as it reads it.  (exec.bat re-inits the
@REM table itself when it starts the REPL — harmless to do it twice.)
call %GWSRC%\lexer\keyword init
call %GWSRC%\exec\_program init

@REM If a filename was given, load it before launching the REPL.
if not "%~1"=="" (
  if not exist "%~1" (
    echo File not found: %~1
    endlocal
    exit /B 1
  ) else (
    call %GWSRC%\file\file load "%~1"
  )
)

if defined _runonce (
  call %GWSRC%\exec\exec runOnce
) else (
  call %GWSRC%\exec\exec
)
endlocal
