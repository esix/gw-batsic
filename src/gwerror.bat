@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start

:ErrorCodeToString code result
  setlocal EnableDelayedExpansion
  set "code=%~1"
  set "result="
  
  if "!code!"=="1" set "result=NEXT without FOR"
  rem NEXT statement does not have a corresponding FOR statement. Check 
  rem variable at FOR statement for a match with the NEXT statement variable.

  if "!code!"=="2" set "result=Syntax error"
  rem A line is encountered that contains an incorrect sequence of characters 
  rem (such as unmatched parentheses, a misspelled command or statement, 
  rem incorrect punctuation). This error causes GW-BASIC to display the 
  rem incorrect line in edit mode.

  if "!code!"=="3" set "result=RETURN without GOSUB"
  rem A RETURN statement is encountered for which there is no previous GOSUB 
  rem statement.

  if "!code!"=="4" set "result=Out of DATA"
  rem A READ statement is executed when there are no DATA statements with 
  rem unread data remaining in the program.

  if "!code!"=="5" set "result=Illegal function call"
  rem An out-of-range parameter is passed to a math or string function. An 
  rem illegal function call error may also occur as the result of:
  rem - a negative or unreasonably large subscript
  rem - a negative or zero argument with LOG
  rem - a negative argument to SQR
  rem - a negative mantissa with a noninteger power
  rem - a call to a USR function for which the starting address has not yet 
  rem   been given
  rem - an improper argument to MID$, LEFT$, RIGHT$, INP, OUT, WAIT, PEEK, POKE,
  rem TAB, SPC, STRING$, SPACE$, INSTR, or ON...GOTO

  if "!code!"=="6" set "result=Overflow"
  rem The result of a calculation is too large to be represented in GW-BASIC's 
  rem number format. If underflow occurs, the result is zero, and execution 
  rem continues without an error.

  if "!code!"=="7" set "result=Out of memory"
  rem A program is too large, has too many FOR loops, GOSUBs, variables, or 
  rem expressions that are too complicated. Use the CLEAR statement to set aside
  rem more stack space or memory area.

  if "!code!"=="8" set "result=Undefined line number"
  rem A line reference in a GOTO, GOSUB, IF-THEN...ELSE, or DELETE is a 
  rem nonexistent line.

  if "!code!"=="9" set "result=Subscript out of range"
  rem An array element is referenced either with a subscript that is outside the
  rem dimensions of the array, or with the wrong number of subscripts.

  if "!code!"=="10" set "result=Duplicate Definition"
  rem Two DIM statements are given for the same array, or a DIM statement is 
  rem given for an array after the default dimension of 10 has been established
  rem for that array.

  if "!code!"=="11" set "result=Division by zero"
  rem A division by zero is encountered in an expression, or the operation of 
  rem involution results in zero being raised to a negative power. Machine 
  rem infinity with the sign of the numerator is supplied as the result of the 
  rem division, or positive machine infinity is supplied as the result of the 
  rem involution, and execution continues.

  if "!code!"=="12" set "result=Illegal direct"
  rem A statement that is illegal in direct mode is entered as a direct mode 
  rem command.

  if "!code!"=="13" set "result=Type mismatch"
  rem A string variable name is assigned a numeric value or vice versa; a 
  rem function that expects a numeric argument is given a string argument or 
  rem vice versa.

  if "!code!"=="14" set "result=Out of string space"
  rem String variables have caused GW-BASIC to exceed the amount of free memory
  rem remaining. GW-BASIC allocates string space dynamically until it runs out
  rem of memory.

  if "!code!"=="15" set "result=String too long"
  rem An attempt is made to create a string more than 255 characters long.

  if "!code!"=="16" set "result=String formula too complex"
  rem A string expression is too long or too complex. Break the expression into
  rem smaller expressions.

  if "!code!"=="17" set "result=Can't continue"
  rem An attempt is made to continue a program that
  rem - Has halted because of an error
  rem - Has been modified during a break in execution
  rem - Does not exist

  if "!code!"=="18" set "result=Undefined user function"
  rem A USR function is called before the function definition (DEF statement) is
  rem given.

  if "!code!"=="19" set "result=No RESUME"
  rem An error-trapping routine is entered but contains no RESUME statement.

  if "!code!"=="20" set "result=RESUME without error"
  rem A RESUME statement is encountered before an error-trapping routine is 
  rem entered.

  if "!code!"=="21" set "result=Unprintable error"
  rem No error message is available for the existing error condition. This is
  rem usually caused by an error with an undefined error code.

  if "!code!"=="22" set "result=Missing operand"
  rem An expression contains an operator with no operand following it.

  if "!code!"=="23" set "result=Line buffer overflow"
  rem An attempt is made to input a line that has too many characters.

  if "!code!"=="24" set "result=Device Timeout"
  rem GW-BASIC did not receive information from an I/O device within a 
  rem predetermined amount of time.

  if "!code!"=="25" set "result=Device Fault"
  rem Indicates a hardware error in the printer or interface card.

  if "!code!"=="26" set "result=FOR Without NEXT"
  rem A FOR was encountered without a matching NEXT.

  if "!code!"=="27" set "result=Out of Paper"
  rem The printer is out of paper; or, a printer fault.

  if "!code!"=="28" set "result=Unprintable error"
  rem No error message is available for the existing error condition. This is 
  rem usually caused by an error with an undefined error code.

  if "!code!"=="29" set "result=WHILE without WEND"
  rem A WHILE statement does not have a matching WEND.

  if "!code!"=="30" set "result=WEND without WHILE"
  rem A WEND was encountered without a matching WHILE.

  if "!code!"=="31" set "result=Unprintable error"
  if "!code!"=="32" set "result=Unprintable error"
  if "!code!"=="33" set "result=Unprintable error"
  if "!code!"=="34" set "result=Unprintable error"
  if "!code!"=="35" set "result=Unprintable error"
  if "!code!"=="36" set "result=Unprintable error"
  if "!code!"=="37" set "result=Unprintable error"
  if "!code!"=="38" set "result=Unprintable error"
  if "!code!"=="39" set "result=Unprintable error"
  if "!code!"=="40" set "result=Unprintable error"
  if "!code!"=="41" set "result=Unprintable error"
  if "!code!"=="42" set "result=Unprintable error"
  if "!code!"=="43" set "result=Unprintable error"
  if "!code!"=="44" set "result=Unprintable error"
  if "!code!"=="45" set "result=Unprintable error"
  if "!code!"=="46" set "result=Unprintable error"
  if "!code!"=="47" set "result=Unprintable error"
  if "!code!"=="48" set "result=Unprintable error"
  if "!code!"=="49" set "result=Unprintable error"
  rem No error message is available for the existing error condition. This is 
  rem usually caused by an error with an undefined error code.

  if "!code!"=="50" set "result=FIELD overflow"
  rem A FIELD statement is attempting to allocate more bytes than were specified
  rem for the record length of a random file.

  if "!code!"=="51" set "result=Internal error"
  rem An internal malfunction has occurred in GW-BASIC. Report to your dealer 
  rem the conditions under which the message appeared.

  if "!code!"=="52" set "result=Bad file number"
  rem A statement or command references a file with a file number that is not 
  rem open or is out of range of file numbers specified at initialization.

  if "!code!"=="53" set "result=File not found"
  rem A LOAD, KILL, NAME, FILES, or OPEN statement references a file that does
  rem not exist on the current diskette.

  if "!code!"=="54" set "result=Bad file mode"
  rem An attempt is made to use PUT, GET, or LOF with a sequential file, to LOAD
  rem a random file, or to execute an OPEN with a file mode other than I, O, A, 
  rem or R.

  if "!code!"=="55" set "result=File already open"
  rem A sequential output mode OPEN is issued for a file that is already open, 
  rem or a KILL is given for a file that is open.

  if "!code!"=="56" set "result=Unprintable error"
  rem An error message is not available for the error condition which exists. 
  rem This is usually caused by an error with an undefined error code.

  if "!code!"=="57" set result="Device I/O Error"
  rem Usually a disk I/O error, but generalized to include all I/O devices. It 
  rem is a fatal error; that is, the operating system cannot recover from the 
  rem error.

  if "!code!"=="58" set "result=File already exists"
  rem The filename specified in a NAME statement is identical to a filename 
  rem already in use on the diskette.

  if "!code!"=="59" set "result=Unprintable error"
  if "!code!"=="60" set "result=Unprintable error"
  rem No error message is available for the existing error condition. This is 
  rem usually caused by an error with an undefined error code.

  if "!code!"=="61" set "result=Disk full"
  rem All disk storage space is in use.

  if "!code!"=="62" set "result=Input past end"
  rem An INPUT statement is executed after all the data in the file has been 
  rem input, or for a null (empty) file. To avoid this error, use the EOF 
  rem function to detect the end of file.

  if "!code!"=="63" set "result=Bad record number"
  rem In a PUT or GET statement, the record number is either greater than the 
  rem maximum allowed (16,777,215) or equal to zero.

  if "!code!"=="64" set "result=Bad filename"
  rem An illegal form is used for the filename with LOAD, SAVE, KILL, or OPEN; 
  rem for example, a filename with too many characters.

  if "!code!"=="65" set "result=Unprintable error"
  rem No error message is available for the existing error condition. This is 
  rem usually caused by an error with an undefined error code.

  if "!code!"=="66" set "result=Direct statement in file"
  rem A direct statement is encountered while loading a ASCII-format file. The 
  rem LOAD is terminated.

  if "!code!"=="67" set "result=Too many files"
  rem An attempt is made to create a new file (using SAVE or OPEN) when all 
  rem directory entries are full or the file specifications are invalid.

  if "!code!"=="68" set "result=Device Unavailable"
  rem An attempt is made to open a file to a nonexistent device. It may be that 
  rem hardware does not exist to support the device, such as lpt2: or lpt3:, or 
  rem is disabled by the user. This occurs if an OPEN "COM1: statement is 
  rem executed but the user disables RS-232 support with the /c: switch 
  rem directive on the command line.

  if "!code!"=="69" set "result=Communication buffer overflow"
  rem Occurs when a communications input statement is executed, but the input 
  rem queue is already full. Use an ON ERROR GOTO statement to retry the input 
  rem when this condition occurs. Subsequent inputs attempt to clear this fault 
  rem unless characters continue to be received faster than the program can 
  rem process them. In this case several options are available:
  rem - Increase the size of the COM receive buffer with the /c: switch.
  rem - Implement a hand-shaking protocol with the host/satellite (such as: 
  rem   XON/XOFF, as demonstrated in the TTY programming example) to turn 
  rem   transmit off long enough to catch up.
  rem - Use a lower baud rate for transmit and receive.

  if "!code!"=="70" set "result=Permission Denied"
  rem This is one of three hard disk errors returned from the diskette 
  rem controller.
  rem - An attempt has been made to write onto a diskette that is write 
  rem   protected.
  rem - Another process has attempted to access a file already in use.
  rem - The UNLOCK range specified does not match the preceding LOCK statement.

  if "!code!"=="71" set "result=Disk not Ready"
  rem Occurs when the diskette drive door is open or a diskette is not in the
  rem drive. Use an ON ERROR GOTO statement to recover.

  if "!code!"=="72" set "result=Disk media error"
  rem Occurs when the diskette controller detects a hardware or media fault. 
  rem This usually indicates damaged media. Copy any existing files to a new 
  rem diskette, and reformat the damaged diskette. FORMAT maps the bad tracks 
  rem in the file allocation table. The remainder of the diskette is now usable.

  if "!code!"=="73" set "result=Advanced Feature"
  rem An attempt was made to use a reserved word that is not available in this 
  rem version of GW-BASIC.

  if "!code!"=="74" set "result=Rename across disks"
  rem Occurs when an attempt is made to rename a file to a new name declared to 
  rem be on a disk other than the disk specified for the old name. The naming 
  rem operation is not performed.

  if "!code!"=="75" set "result=Path/File Access Error"
  :: During an OPEN, MKDIR, CHDIR, or RMDIR operation, MS-DOS is unable to make
  :: a correct path-to-filename connection. The operation is not completed.

  if "!code!"=="76" set "result=Path not found"
  :: During an OPEN, MKDIR, CHDIR, or RMDIR operation, MS-DOS is unable to find
  :: the path specified. The operation is not completed.

  if "!result!"=="" (
    endlocal && exit /b 1
  )

  endlocal && if "%~2"=="" (
    echo %result%
  ) else (
    set "%~2=%result%"
  )
exit /b 0


:: -----------------------------------------------------------------------------

:_start
setlocal EnableDelayedExpansion
  set PATH=%~dp0..\tests;%~dp0..\src;%PATH%
  set "numTests=0"
  set "passedTests=0"
  set "failedTests=0"

  call expect "gwerror ErrorCodeToString 27 __" "Out of Paper"
  call expect "gwerror ErrorCodeToString 5 __" "Illegal function call"
  call expecterr "gwerror ErrorCodeToString 0 __" 1


  echo Ran %numTests% tests
  echo      FAILED: %failedTests%
  echo      PASSED: %passedTests%

endlocal
