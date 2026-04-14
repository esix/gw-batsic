# src/str — String/Hex Conversion

Converts between ASCII text and hex-pair representation used internally throughout the project.

## Hex Format

Each byte is represented as 2 uppercase hex chars: `"HELLO"` = `48454C4C4F`.

This is the same format used by:
- The lexer for string literals (`STR_48454C4C4F`) and comments (`REM_...`)
- The `hexDump` utility for reading binary files
- The `gw.splitLines` utility

## API

```batch
call %GWSRC%\str\str encode "HELLO" __     &:: __ = "48454C4C4F"
call %GWSRC%\str\str decode 48454C4C4F __  &:: __ = "HELLO"
call %GWSRC%\str\str ch2hex A __            &:: __ = "41"
call %GWSRC%\str\str hex2ch 41 __           &:: __ = "A"
```

| Function | Input | Output |
|----------|-------|--------|
| `encode` | ASCII string | hex pairs |
| `decode` | hex pairs | ASCII string |
| `ch2hex` | single char | hex pair |
| `hex2ch` | hex pair | single char |

## Interactive Tool

Running `str.bat` directly starts a text-to-hex converter:

```
> src\str\str.bat
Text to hex converter. Enter empty line to quit.
> HELLO WORLD
48454C4C4F20574F524C44
> 10 PRINT A+B
3130205052494E5420412B42
>
```

## Limitations

Batch variable expansion makes certain characters hard to handle:

- **`%`**: consumed by batch `%var%` expansion before code can see it. Cannot be encoded via `str encode` or the interactive tool.
- **Case sensitivity**: `encode` maps both `A` and `a` to uppercase hex (`41`) because batch environment variable names are case-insensitive. `decode` preserves case correctly (`41`→`A`, `61`→`a`).

**These limitations do NOT affect the GW-BASIC interpreter.** The interpreter pipeline reads user input through `hexDump`, which converts raw bytes to hex pairs directly — bypassing batch variable expansion entirely. All characters including `%`, `!`, `^` arrive as clean hex codes (`25`, `21`, `5E`).

The `str` module is primarily used by:
- Test utilities (converting readable test input to hex)
- The interactive REPL tool (developer convenience)
