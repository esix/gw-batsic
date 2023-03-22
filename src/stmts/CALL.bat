:: CALL Statement
:: Purpose:
:: To call an assembly (or machine) language subroutine.
::
:: Syntax:
:: CALL numvar[(variables)]
:: Comments:
:: numvar is the starting point in memory of the subroutine being called as an 
:: offset into the current segment.
::
:: variables are the variables or constants, separated by commas and enclosed 
:: in parentheses, that are to be passed to the routine.
::
:: The CALL statement is recommended for interfacing assembly language programs 
:: with GW-BASIC. Although the USR function may also be used, CALL is compatible 
:: with more languages, produces a more readable source code, and can pass 
:: multiple arguments.
::
:: Invocation of the CALL statement causes the following to occur:
::
:: - Each parameter location in the variable is pushed onto the stack. The 
::   parameter location is a 2-byte offset into GW-BASIC's data segment.
:: - The return address code segment (CS) and the offset are pushed onto the 
::   stack.
:: - Control is transferred to the user routine by the segment address given in 
::   the last DEF SEG statement and the offset given in the variable name.
:: - The user routine now has control. Parameters may be referenced by moving 
::   the stack pointer (SP) to the base pointer (BP) and adding a positive 
::   offset to BP.
:: - The called routine may destroy the contents of any registers.
:: - The called program must know how many parameters were passed. Parameters 
::   are referenced by adding a positive offset to BP, assuming the called 
::   routine moved the current stack pointer into BP (that is, MOV BP,SP).
:: - The called program must know the variable type for numeric parameters 
::   passed.
:: - The called routine must do a RET n, where n is the number of parameters in 
::   the variable times 2. This is necessary in order to adjust the stack to the 
::   point at the start of the calling sequence.
:: - Values are returned to GW-BASIC by including in the argument list the name 
::   of the variable that is to receive the result.
:: - If the argument is a string, the parameter offset points to three bytes 
::   called the string descriptor. Byte 0 of the string descriptor contains the 
::   length of the string (0 to 255). Bytes 1 and 2, respectively, are the lower 
::   and upper-eight bits of the string starting address in the string space.
:: - If the argument is a string literal in the program, the string descriptor 
::   points to program text. Be careful not to alter or destroy a program this 
::   way. To avoid unpredictable results, add +"" to the string literal in the 
::   program, as in the following:
::     20 A$="BASIC"+""
::   This forces the string literal to be copied into the string space. Now the 
::   string may be modified without affecting the program.
::
:: Note
::
:: Strings may be altered by user routines, but their length must not be 
:: changed. GW-BASIC cannot correctly erase strings if their lengths are 
:: modified by external routines.
::
:: For more information on the CALL statement and USR function, see Appendix D 
:: in the GW-BASIC User's Guide.
::
:: Example 1:
:: 100 DEF SEG=&H2000
:: 110 ARK=0
:: 120 CALL ARK(A, B$, C)
:: .
:: .
:: .
:: Line 100 sets the segment to hex 2000. ARK is set to zero so that the call to 
:: ARK executes the subroutine at location 2000:0.
::
:: Example 2:
:: The following sequence of 8086 Assembly Language demonstrates access of the 
:: parameters passed and stored in variable C:
::
:: PUSH BP
:: MOV BP, SP      ; Gets current stack position in BP.
:: MOV BX, 8[BP]   ; Gets address of B$ descriptor.
:: MOV CL, [BX]    ; Gets length of B$ in CL.
:: MOV DX, 1[BX]   ; Gets address of B$ text in DX.
:: .
:: .
:: .
:: MOV SI, 10[BP] ; Gets address of A in SI.
:: MOV DI, 6[BP]   ; Gets pointer to C in DI.
:: MOVSW           ; Stores variable A in C.
:: RET 6           ; Restores stack and returns.
:: MOVSW copies only two bytes. This is sufficient if variables A and C are 
:: integer. Four bytes must be copied if they are single precision; eight bytes, 
:: if they are double precision.
::
:: Example 3:
:: 100 DEF SEG=&H2000
:: 110 ACC=&H7FA
:: 120 CALL ACC(A, B$, C)
:: .
:: .
:: .
:: Line 100 sets the segment to hex 2000. The value of variable ACC is added 
:: into the address as the low word after the DEF SEG value is shifted four bits 
:: to the left (this is a function of the microprocessor, not of GW-BASIC). 
:: Here, ACC is set to &H7FA, so that the call to ACC executes the subroutine at
:: the location hex 2000:7FA (absolute address hex 207FA).

