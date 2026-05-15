# Numerics & MBF

Three numeric types — `int`, `sng`, `dbl` — built on top of a 4-layer hex
arithmetic stack. Everything is stored as fixed-width hex strings in env
vars and passed around as-is.

## Why hex strings

`cmd.exe`'s `set /a` does signed 32-bit integer arithmetic and that's it.
No 64-bit integers, no floats, no overflow trapping. GW-BASIC needs:

- signed 16-bit integers (`A%`),
- 4-byte single-precision MBF floats (`A!`),
- 8-byte double-precision MBF floats (`A#`).

The single approach that scales for everything: represent numbers as
**fixed-width uppercase hex strings**, do arithmetic by walking the digits.
That gives:

- arbitrary widths without overflow surprises,
- bit-level control (necessary for IEEE/MBF mantissa packing),
- one stable representation that crosses module boundaries, env vars,
  files, and `endlocal &` propagation,
- comparisons by string equality (`if "%a%"=="%b%"`),
- portable: no external tools beyond what ships with Windows.

Costs: arithmetic is slow (hundreds of `cmd.exe` commands per multiply),
and lookup tables have to be loaded into env vars on every script entry.
We accept both — the constraint is the project.

## The four hex layers

Arithmetic is implemented in four widths, each one delegating to the next
smaller. Every layer exposes the same operations: `add`, `sub`, `inc`,
`dec`, `neg`, `inv`, `and`, `or`, `xor`, `shl`, `shr`, and (where it makes
sense) `mul` and `div`. Plus `fromDec` / `toDec` at the integer layers for
human-readable conversion.

| Layer | Width | What it stores | Implementation |
|---|---|---|---|
| `_xhalf` | 4 bits, 1 hex char | `0` … `F` | Direct lookup tables (`set "_inc_0=1"`, `set "_inc_1=2"`, etc.) and `set /a` for compound operations. The bedrock. |
| `_xbyte` | 8 bits, 2 hex chars | `00` … `FF` | Splits into two halves, defers to `_xhalf` for each, glues results. Handles cross-half carry. |
| `_xword` | 16 bits, 4 hex chars | `0000` … `FFFF` | Two bytes via `_xbyte`. Has signed variants `smul` / `sdiv` for `int`. `fromDec` / `toDec` accept decimal strings. |
| `_xdword` | 32 bits, 8 hex chars | `00000000` … `FFFFFFFF` | Two words via `_xword`. `mul` produces a 64-bit (16-char) product. Used as the underlying word for single-precision mantissas. |
| `_xqword` | 64 bits, 16 hex chars | `0000…0000` … `FFFF…FFFF` | Two dwords via `_xdword`. Used by double-precision mantissas. |

`set /a` is allowed only inside `_xhalf` — that keeps the layer
self-contained. Everything above does string surgery on hex digits.

`__` is the conventional output variable; binary ops also set `__c` to
carry/borrow when meaningful. Example:

```
call _xword add 1234 ABCD
@REM → __ = BE01, __c = empty (no carry)
call _xbyte mul 0F 0F
@REM → __ = E1 (low), __h = 00 (high)  — multiplication returns hi/lo pair
```

## Microsoft Binary Format (MBF)

GW-BASIC predates IEEE 754 and uses MBF, a slightly different layout:

```
single (4 bytes):  EE  S MMMMMM        — biased-128 exponent, implied leading 1
double (8 bytes):  EE  S MMMMMMMMMMMMMM
```

- `EE` is the biased exponent. `EE=00` means the whole value is zero;
  otherwise the unbiased exponent is `EE - 128`.
- `S` is the sign bit — the top bit of the byte after `EE`. The remaining
  7 bits of that byte hold the high mantissa fraction.
- The implied leading `1.` is stripped from storage but restored for
  arithmetic.

So `s83200000` is single 10.0: exponent `0x83` (unbiased `3`), sign `0`,
mantissa fraction `0x200000` → `1.25 × 2³ = 10`.

`_mbfs.bat` / `_mbfd.bat` implement the float internals:

| Operation | What it does |
|---|---|
| `getMant` | Unpacks the mantissa back to a `_xdword`/`_xqword` with the implied 1 restored — internal representation for arithmetic. |
| `pack` | Inverse: clears the implied 1, glues sign and exponent back, produces a tagged storage value. |
| `normalize` | Shifts a mantissa left until the top bit is set; adjusts the exponent. Called after every operation that could leave a denormal result. |
| `add` / `sub` | Aligns exponents, adds or subtracts mantissas via `_xdword` / `_xqword`, renormalises. |
| `mul` / `div` | Multiplies/divides mantissas, adds/subtracts exponents, renormalises. |
| `fromDec` / `toDec` | Decimal ↔ MBF. See "Conversion" below. |
| `fromInt` / `toInt` | int ↔ MBF. Exact for values that fit. |
| `cmp` | Three-way compare. |

## Facades — `int`, `sng`, `dbl`

User code never touches `_xword` or `_mbfs` directly. The three facade
files in `src/num/` are the public API:

```
call %GWSRC%\num\int add i0001 i0002        → __ = i0003
call %GWSRC%\num\sng mul s83200000 s83200000 → __ = s86480000   (10 × 10 = 100)
call %GWSRC%\num\dbl toDec d8649000000000000 → __ = 100
```

Each facade:

- prefixes the result with the type tag (`i`, `s`, `d`),
- checks the input tags and errors with `13` (Type mismatch) on mismatch,
- delegates the actual work to the underlying `_xword` / `_mbfs` / `_mbfd`
  routines.

The facades also expose a tiny REPL when run with no arguments — useful
for poking at the math interactively (`src\num\sng.bat`, then type
`10 + 1`).

## Conversion: `fromDec` / `toDec`

The most subtle pieces.

**`fromDec`** parses a decimal literal (`3.14`, `-1.5E3`, `.25`, `100`)
into the binary representation. The algorithm:

1. Parse the sign, then accumulate up to N decimal digits into a 32-bit
   significand (with `set /a` — this is the conversion boundary, not
   number arithmetic).
2. Track the implied decimal-exponent shift.
3. Convert the significand to a normalised MBF mantissa.
4. Apply the decimal exponent by repeatedly multiplying or dividing by
   `10.0` in MBF.

**`toDec`** is the inverse: scale the value into `[1.0, 10.0)` by
multiplying or dividing by 10, then extract digits one at a time
(`floor`, subtract, multiply by 10, repeat). After all digits are
extracted, format the result with a chosen point position.

Both algorithms are bit-faithful to MBF, but the division-by-10 in
`toDec`'s scaling and the multiply-by-10 in the digit loop are both
inexact (1/10 isn't representable in binary). Errors accumulate at ~1 ULP
per operation, so for 7-digit single-precision output the displayed value
can drift by 1 in the last place.

That's the source of the known wart: `sng toDec` rounds `10` cleanly,
because the result extracted to 8 digits then rounded to 7 lands on
`10000000`. But it returns `.09999999` for `0.1`, because the 8th
extracted digit comes out too low to round up, and `9999999 × 10⁻²`
formats as `.09999999`.

Double-precision toDec uses the same algorithm but with a 52-bit mantissa.
The relative error per operation is ~4 orders of magnitude smaller, far
below 7-digit display precision — so `dbl toDec` rounds cleanly for any
value that fits in dbl, including the `65535` shown in `PRINT ERL` from
direct mode.

## Endlocal propagation

Every num routine wraps its work in `setlocal EnableDelayedExpansion` and
returns through the standard endlocal-set idiom:

```
endlocal & set "__=%result%" & exit /B 0
```

`%result%` is expanded at parse time, before `endlocal` runs — so the
inner-scope value is captured as a literal and the assignment in the
outer scope receives it intact. The same pattern is used for `__h` (high
word for `_xdword mul`), `__c` (carry/borrow), and `__r` (remainder for
`_xword sdiv`).

This is the one batch idiom you have to understand to read any file in
`src/num/`.

## What you can build on top

- The `int` facade is used directly by `NUM_iXXXX` postfix tokens and the
  16-bit signed-integer arithmetic RTLs (`ADD`, `SUB`, etc.).
- The `sng` and `dbl` facades back the `s` and `d` tagged values; the
  promotion helper at `src/exec/_promote.bat` lifts a mixed pair of
  operands to the highest type before the arithmetic RTL dispatches.
- The MBF storage format is bit-compatible with original GW-BASIC, so
  when we get to loading and saving `.BAS` binary files (planned), the
  numeric tokens already match.
