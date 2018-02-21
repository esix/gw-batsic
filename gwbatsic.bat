@ECHO ON
SETLOCAL
SETLOCAL EnableDelayedExpansion


:: initialization (some globals)
SET g_ansi=
SET g_filename=

::
:: Parse arguments 
::
:Args_Parse_Start
  SHIFT
  IF /I [%0]==[] GOTO Args_Parse_End
  IF /I [%0]==[--ansi] (SET g_ansi=1 & GOTO Args_Parse_Start)
  IF /I [%0]==[-a]     (SET g_ansi=1 & GOTO Args_Parse_Start)
  if [!g_filename!]==[]  (SET g_filename=%0 & GOTO Args_Parse_Start)
  GOTO Args_Parse_Start
:Args_Parse_End


::
:: Initialize constants and modules
::
CALL SYNTAX\INIT.BAT



::
:: Start
::
IF [!g_filename!]==[] GOTO Start_Interactive_Shell
IF NOT EXIST !g_filename! GOTO Error_File_Not_Found
  ECHO Load file...
  ECHO Run file...
  GOTO Interactive_Shell

:Start_Interactive_Shell
  CLS
  ECHO GW-BATSIC 3.23
  ECHO (C) Copyright M*******t 1983,1984,1985,1986,1987,1988
  ECHO 60300 Bytes free
  GOTO Interactive_Shell_Ok

:Interactive_Shell
  SET /p input=
  :: parse...
  IF NOT EXIST COMMANDS\%input%.BAT GOTO Interactive_Shell_Syntax_Error
  CALL COMMANDS\%input%.BAT
  :: check code
  GOTO Interactive_Shell


:Interactive_Shell_Ok
  ECHO Ok
  GOTO Interactive_Shell

:Interactive_Shell_Syntax_Error
  ECHO Syntax error
  GOTO Interactive_Shell

:Interactive_Shell_Undefined_Line_Number
  ECHO Undefined Line Number
  GOTO Interactive_Shell

:Error_File_Not_Found
  ECHO File not found
  GOTO Exit



:Exit
ENDLOCAL
