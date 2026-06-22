@echo off
@REM PU_NL: emit the trailing newline for a PRINT USING that did not end
@REM with a ; or , separator.  Resets the print column.
if defined _print_path (call %GWSRC%\exec\_pemit "") else (echo()
set "_print_col=0"
exit /B 0
