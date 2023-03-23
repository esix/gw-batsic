:: CHAIN Statement
:: Purpose:
:: To transfer control to the specified program and pass (chain) variables to it
:: from the current program.
::
:: Syntax:
:: CHAIN[MERGE] filename[,[line][,[ALL][,DELETE range]]]
:: Comments:
:: MERGE overlays the current program with the called program.
::
:: Note
::
:: The called program must be an ASCII file (previously saved with the a option)
:: if it is to be merged (see the MERGE command).
::
:: filename is the name of the program that is called to be chained to. The .BAS
:: extension is assumed unless another is specified.
::
:: line is a line number or an expression that corresponds to a line number in
:: the called program. It is the starting point for execution of the called
:: program. For example the following begins execution of PROG1.BAS at 
:: line 1000:
::
::   10 CHAIN "PROG1", 1000
::
:: If line is omitted, execution begins at the first line.
::
:: line is not affected by a RENUM command. However, the line numbers in the 
:: specified range are affected by a RENUM command.
::
:: ALL specifies that every variable in the current program is chained to the 
:: called program. For example:
::
::  20 CHAIN "PROG1", 1000, ALL
::
:: If the ALL option is omitted, the current program must contain a COMMON 
:: statement to list the variables that are passed.
::
:: CHAIN executes a RESTORE before it runs the program that it is to be chained
:: to. The READ statement then gets the first item in the DATA statement. 
:: Reading will not resume where it left off in the program that is being 
:: chained.
::
:: After an overlay is executed and used for a specific purpose, it is usually
:: desirable to delete it so that a new overlay may be brought in. To do this,
:: use the DELETE command.
::
:: The CHAIN statement with the MERGE command leaves the files open and 
:: preserves the current option base setting.
::
:: If the MERGE command is omitted, the OPTION BASE setting is preserved, and 
:: CHAIN preserves no variable types or user-defined functions for use by the 
:: chained program. That is, any DEFINT, DEFSNG, DEFDBL, DEFSTR, or DEF FN 
:: statement containing shared variables must be restated in the chained 
:: program.
::
:: When using the merge command, place user-defined functions before any 
:: CHAIN MERGE statements in the program. Otherwise, they will be undefined 
:: after the merge is complete.

