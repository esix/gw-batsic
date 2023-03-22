:: BLOAD Command
:: Purpose:
:: To load an image file anywhere in user memory.
::
:: Syntax:
:: BLOAD filename[,offset]
:: Comments:
:: filename is a valid string expression containing the device and filename.
::
:: offset is a valid numeric expression within the range of 0 to 65535. This is 
:: the offset into the segment, declared by the last DEF SEG statement, where 
:: loading is to start.
::
:: If offset is omitted, the offset specified at BSAVE is assumed; that is, the 
:: file is loaded into the same location it was saved from.
::
:: Note
::
:: BLOAD does not perform an address range check. It is possible to BLOAD 
:: anywhere in memory. You must not BLOAD over the GW-BASIC stack space, a 
:: GW-BASIC program, or the GW-BASIC variable area.
:: 
:: While BLOAD and BSAVE are useful for loading and saving machine language 
:: programs, they are not restricted to them. The DEF SEG statement lets you 
:: specify any segment as the source or target for BLOAD and BSAVE. For example, 
:: this allows the video screen buffer to be read from or written to the 
:: diskette. BLOAD and BSAVE are useful in saving and displaying graphic images.
::
:: Examples:
:: 10 DEF SEG=&HB800
:: 20 BLOAD"PICTURE", 0
:: The DEF SEG statement in line 10 points the segment at the screen buffer.
::
:: The DEF SEG statement in line 10 and the offset of 0 in line 20 guarantee 
:: that the correct address is used.
::
:: The BLOAD command in line 20 loads the file named picture into the screen 
:: buffer.
::
:: Note
::
:: The BSAVE example in the next section illustrates how the file named picture 
:: is saved.
