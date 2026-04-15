# src/rtl — Runtime Library

One batch file per parser action. Each file is called by the executor when it encounters that action in the postfix stream.

## Calling Convention

Each RTL action receives the stack variable name as `%~1`. It pops operands, performs the operation, and pushes the result (if any).

```batch
@REM Example: ADD.bat
call %GWSRC%\stl\vec pop %~1 _b    &:: pop second operand
call %GWSRC%\stl\vec pop %~1 _a    &:: pop first operand
call %GWSRC%\exec\_resolve !_a! _a  &:: resolve if VAR_ token
call %GWSRC%\exec\_resolve !_b! _b
call %GWSRC%\num\int add !_a! !_b!  &:: compute
call %GWSRC%\stl\vec push %~1 %__%  &:: push result
```

## Implemented Actions

### Arithmetic
| Action | Stack effect | Description |
|--------|-------------|-------------|
| `ADD` | a b → a+b | Addition |
| `SUB` | a b → a-b | Subtraction |
| `MUL` | a b → a*b | Multiplication |
| `DIV` | a b → a/b | Division |
| `NEG` | a → -a | Unary negation |

### Output
| Action | Stack effect | Description |
|--------|-------------|-------------|
| `PEND` | a → | Print value + newline |
| `PSEMI` | a → | Print value (no newline) |

### Variables
| Action | Stack effect | Description |
|--------|-------------|-------------|
| `ASSIGN` | var val → | Store value in variable |

### Type Definitions
| Action | Stack effect | Description |
|--------|-------------|-------------|
| `DEFINT` | from to → | Set letter range to integer |
| `DEFSNG` | from to → | Set letter range to single |
| `DEFDBL` | from to → | Set letter range to double |
| `DEFSTR` | from to → | Set letter range to string |

### Control
| Action | Stack effect | Description |
|--------|-------------|-------------|
| `END` | → | End program (errorlevel 99) |
| `STOP` | → | Break program (errorlevel 99) |
| `CLS` | → | Clear screen |
| `BEEP` | → | Beep sound |
| `REM` | text → | Discard comment |

### Not Yet Implemented
GOTO, GOSUB, RETURN, IF, ENDIF, ELSE, IF_GOTO, FOR, NEXT, WHILE, WEND, DIM, INPUT, READ, DATA, POKE, SOUND, all FN_* functions, comparison operators, logical operators.
