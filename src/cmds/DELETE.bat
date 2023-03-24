:: DELETE Command
:: Purpose:
:: To delete program lines or line ranges.
::
:: Syntax:
:: DELETE [line number1][-line number2]
:: DELETE line number1-
:: Comments:
:: line number1 is the first line to be deleted.
::
:: line number2 is the last line to be deleted.
::
:: GW-BASIC always returns to command level after a DELETE command is executed.
:: Unless at least one line number is given, an "Illegal Function Call" error 
:: occurs.
:: 
:: The period (.) may be used to substitute for either line number to indicate the current line.
::
:: Examples:
:: DELETE 40 
:: Deletes line 40.
::
:: DELETE 40-100 
:: Deletes lines 40 through 100, inclusively.
::
:: DELETE -40
:: Deletes all lines up to and including line 40.
::
:: DELETE 40- 
:: Deletes all lines from line 40 to the end of the program.

set DELETE_START_LINE=%~1
set DELETE_END_LINE=%~2

for %%a in (%GW_LINE%) do (
  call:CheckDeleteLine %%a
  if NOT ERRORLEVEL 1 (
    echo "REALLY DELETE LINE %%a"
    set GW_LINE[%%a]=
    REM TODO delete from GW_LINE
  )
)
set DELETE_START=
set DELETE_END=
exit /b 0


:CheckDeleteLine
  if defined DELETE_START (
    if %~1 LSS DELETE_START exit /b 1
  )
  if defined DELETE_END (
    if %~1 GTR DELETE_END exit /b 1
  )
exit /b 0
