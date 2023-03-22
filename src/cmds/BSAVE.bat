:: BSAVE Command
:: Purpose:
:: To save portions of user memory on the specified device.
::
:: Syntax:
:: BSAVE filename,offset,length
:: Comments:
:: filename is a valid string expression containing the filename.
::
:: offset is a valid numeric expression within the range of 0 to 65535. This is 
:: the offset into the segment, declared by the last DEF SEG, where saving is to 
:: start.
::
:: length is a valid numeric expression within the range of 0 to 65535, 
:: specifying the length of the memory image to be saved.
::
:: If filename is less than one character, a "Bad File Number" error is issued 
:: and the load is aborted.
::
:: Execute a DEF SEG statement before the BSAVE. The last known DEF SEG address 
:: is always used for the save.
::
:: The DEF SEG statement must be used to set up the segment address to the start 
:: of the screen buffer. An offset of 0 and a length of 16384 specify that the 
:: entire 16K screen buffer is to be saved.
::
:: Examples:
:: 10 DEF SEG=&HB800
:: 20 BSAVE"PICTURE", 0, 16384
:: The DEF SEG statement in line 10 points the segment at the screen buffer.
::
:: The BSAVE command in line 20 saves the screen buffer in the file named 
:: picture.
