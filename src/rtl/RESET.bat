@echo off
@REM RESET: close all open files and flush to disk.  Until the file-handle
@REM table (roadmap M1) exists there are no open files to close, so this is
@REM a successful no-op.  When OPEN lands, RESET clears the handle table.
exit /B 0
