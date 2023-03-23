:: CDBL Function
:: Purpose:
:: To convert x to a double-precision number.
::
:: Syntax:
:: CDBL(x)
:: Comments:
:: x must be a numeric expression.
::
:: Example:
:: 10 A=454.67
:: 20 PRINT A; CDBL(A)
:: RUN
:: 454.67 454.6700134277344
:: Prints a double-precision version of the single-precision value stored in the
:: variable named A.
::
:: The last 11 numbers in the double-precision number have no meaning in this 
:: example, since A was previously defined to only two-decimal place accuracy.
::
:: Note
::
:: See the CINT and CSNG functions for converting numbers to integer and single
:: precision, respectively.
