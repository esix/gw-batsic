@echo off
@REM SYSTEM: exit the interpreter.  Flow code 97 unwinds the run loop
@REM (sets _sys_exit) and ends the REPL / runOnce (see exec.bat).
exit /B 97
