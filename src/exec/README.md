# src/exec — GW-BASIC Executor

Stack-based virtual machine that executes postfix output from the parser.

## Architecture

```
Postfix tokens → Executor loop → RTL actions → Output/State changes
                      ↕
                 Stack (vec)
                      ↕
              Variables (vars.dat)
```

The executor walks the postfix token stream left to right:
- **Values** (`NUM_*`, `VAR_*`, `STR_*`) → pushed onto the stack
- **Actions** (everything else) → dispatched to RTL action files (`src/rtl/ACTION.bat`)

The stack is a space-separated env var managed via `stl/vec` (push/pop).

## Files

| File | Purpose |
|------|---------|
| `exec.bat` | Main executor loop + interactive REPL |
| `_vars.bat` | Variable storage (file-based) + DEF type settings |
| `_resolve.bat` | Resolve VAR_ tokens to their values |

## Variable System

Variables are stored in `temp/vars.dat` (one per line: `NAME=taggedvalue`).

Variable types are determined by:
1. **Explicit suffix** always wins: `A%`=int, `A!`=single, `A#`=double, `A$`=string
2. **First letter + DEF settings** for untyped variables (`A`, `XY`, `COUNT`)
3. **Default**: all letters → single precision

DEF settings are stored in `_deftypes` env var (26 chars, one per letter A-Z):
```
ssssssssssssssssssssssssss   (all single, default)
iiiiiiiiiiiiisssssssssssss   (after DEFINT A-M)
```

## Usage

```batch
@REM Initialize
call %GWSRC%\exec\_vars init

@REM Execute postfix
call %GWSRC%\exec\exec run "NUM_i0001 NUM_i0002 ADD PEND"

@REM Variable operations
call %GWSRC%\exec\_vars set VAR_UNK_A i000A
call %GWSRC%\exec\_vars get VAR_UNK_A __
call %GWSRC%\exec\_vars typeof VAR_UNK_A __
call %GWSRC%\exec\_vars defrange A M i
```

## Interactive REPL

Running `exec.bat` directly starts an interactive GW-BASIC session:

```
> src\exec\exec.bat
GW-BASIC Executor. Enter a line. Empty to quit.
> PRINT 1+2*3
 7
> A = 100
> PRINT A-37
 63
>
```
