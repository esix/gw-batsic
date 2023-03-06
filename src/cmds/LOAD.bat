:: LOAD Command
:: Purpose:
:: To load a file from diskette into memory.
::
:: Syntax:
:: LOAD filename[,r]
:: Comments:
:: filename is the filename used when the file was saved. If the extension was 
:: omitted, .BAS will be used.
::
:: LOAD closes all open files and deletes all variables and program lines 
:: currently residing in memory before it loads the designated program.
::
:: If the r option is used with LOAD, the program runs after it is loaded, and 
:: all open data files are kept open.
::
:: LOAD with the r option lets you chain several programs (or segments of the 
:: same program). Information can be passed between the programs using the disk 
:: data files.
:: 
:: Examples:
:: LOAD "STRTRK",R
:: Loads the file strtrk.bas and runs it, retaining all open files and variables 
:: from a previous program intact.

