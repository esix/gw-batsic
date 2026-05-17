@echo off
@REM STOP: halt program with "Break in <line>".  Exit code 99 is a
@REM flow-control signal (not an error); the executor consumes it.
setlocal EnableDelayedExpansion
if not defined _cur_line set "_cur_line=65535"
if "!_cur_line!"=="65535" (
  echo Break
) else (
  echo Break in !_cur_line!
)
endlocal & exit /B 99
