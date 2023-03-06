:: ASC Function
:: Purpose:
:: To return a numeric value that is the ASCII code for the first character of the string x$.
::
:: Syntax:
:: ASC(x$)
:: Comments:
:: If x$ is null, an Illegal Function Call error is returned.
::
:: If x$ begins with an uppercase letter, the value returned will be within the range of 65 to 90.
::
:: If x$ begins with a lowercase letter, the range is 97 to 122.
::
:: Numbers 0 to 9 return 48 to 57, sequentially.
::
:: See the CHR$ function for ASCII-to-string conversion.
::
:: See Appendix C in the GW-BASIC User's Guide for ASCII codes.
::
:: Examples:
:: 10 X$="TEN"
:: 20 PRINT ASC(X$)
:: RUN
:: 84
:: 84 is the ASCII code for the letter T.
