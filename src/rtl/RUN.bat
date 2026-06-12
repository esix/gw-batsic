@echo off
@REM RUN: restart the current program from its first line.  Signals the
@REM run loop / REPL with flow code 98; the handler clears variables,
@REM rebuilds the caches and jumps to the first line (see exec.bat).
set "_run_file="
set "_run_line="
exit /B 98
