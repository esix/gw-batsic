# src/num — Numeric Types Module

Implements the three GW-BASIC numeric types: integer, single-precision float, and double-precision float.

## Tagged Values

All values carry a one-letter type prefix so type mismatches are caught early:

| Prefix | Type | Width | Example | Meaning |
|--------|------|-------|---------|---------|
| `i` | Integer | 16-bit signed | `i007B` | 123 |
| `s` | Single | 32-bit MBF float | `s83200000` | 10.0 |
| `d` | Double | 64-bit MBF float | `d8320000000000000` | 10.0 |

Passing a wrong prefix to any facade function returns error 13 (Type mismatch).

## Public API

Only the facade files should be used by code outside `src/num/`. Files starting with `_` are private.

### int.bat — 16-bit Signed Integer

Internal representation: two's complement xword (4 hex chars). Range: -32768 to 32767.

```
call int fromDec 123        __ = "i007B"
call int toDec i007B        __ = "123"
call int add i0001 i0002    __ = "i0003"
call int sub i0005 i0003    __ = "i0002"
call int mul i0003 i0004    __ = "i000C"
call int div i0007 i0002    __ = "i0003", __r = "i0001"   (\ and MOD)
call int neg iFFFF          __ = "i0001"
call int inv i00FF          __ = "iFF00"                    (NOT)
call int and iFFFF i00FF    __ = "i00FF"
call int or  i00F0 i000F    __ = "i00FF"
call int xor iFFFF iFFFF    __ = "i0000"
```

| Error | Meaning |
|-------|---------|
| 11 | Division by zero |
| 13 | Type mismatch |

### sng.bat — Single-Precision Float (MBF)

Internal representation: Microsoft Binary Format, 4 bytes (8 hex chars).
Layout: `EESMMMMM` — 8-bit exponent (biased 128), 1-bit sign, 23-bit mantissa (implied leading 1).

```
call sng fromDec 3.14       __ = "s8148F5C2..."
call sng toDec s80000000    __ = "1"
call sng fromInt i000A      __ = "s83200000"     (CSNG)
call sng toInt s83200000    __ = "i000A"          (CINT, truncates)
call sng add s80000000 s80000000   __ = "s81000000"   (1+1=2)
call sng sub s81400000 s80000000   __ = "s81000000"   (3-1=2)
call sng mul s81000000 s81400000   __ = "s82400000"   (2*3=6)
call sng div s82400000 s81000000   __ = "s81400000"   (6/2=3)
call sng neg s80000000      __ = "s80800000"           (negate)
call sng abs s80800000      __ = "s80000000"           (ABS)
call sng cmp s80000000 s81000000   __ = "2"   (1<2 -> "2"=LT)
```

Comparison result: `"0"` = equal, `"1"` = first > second, `"2"` = first < second.

fromDec accepts: integers (`100`), decimals (`3.14`), negative (`-0.5`), E-notation (`1.5E3`, `5E-1`).

| Error | Meaning |
|-------|---------|
| 6 | Overflow |
| 11 | Division by zero |
| 13 | Type mismatch |

### dbl.bat — Double-Precision Float (MBF)

Internal representation: Microsoft Binary Format, 8 bytes (16 hex chars).
Layout: `EESMMMMMMMMMMMMM` — 8-bit exponent (biased 128), 1-bit sign, 55-bit mantissa (implied leading 1).

Same API as sng.bat with `d` prefix:

```
call dbl fromDec 3.14       __ = "d..."
call dbl toDec d8000000000000000   __ = "1"
call dbl fromInt i000A      __ = "d8320000000000000"    (CDBL)
call dbl toInt d8320000000000000   __ = "i000A"          (CINT, truncates)
call dbl add d8000000000000000 d8000000000000000   __ = "d8100000000000000"   (1+1=2)
call dbl sub d8140000000000000 d8000000000000000   __ = "d8100000000000000"   (3-1=2)
call dbl mul d8100000000000000 d8140000000000000   __ = "d8240000000000000"   (2*3=6)
call dbl div d8240000000000000 d8100000000000000   __ = "d8140000000000000"   (6/2=3)
call dbl neg d8000000000000000   __ = "d8080000000000000"
call dbl abs d8080000000000000   __ = "d8000000000000000"
call dbl cmp d8000000000000000 d8100000000000000   __ = "2"   (1<2 -> "2"=LT)
```

Note: double-precision operations are significantly slower than single due to the deeper call chain (qword -> dword -> word -> byte -> half). Decimal conversion (fromDec/toDec) currently uses 7 significant digits; binary arithmetic is full 56-bit precision.

| Error | Meaning |
|-------|---------|
| 6 | Overflow |
| 11 | Division by zero |
| 13 | Type mismatch |

## Architecture

```
Public facades (use these):
  int.bat ──> _xword.bat ──> _xbyte.bat ──> _xhalf.bat
  sng.bat ──> _mbfs.bat  ──> _xdword.bat ──> _xword.bat ──> ...
  dbl.bat ──> _mbfd.bat  ──> _xqword.bat ──> _xdword.bat ──> ...

Private hex arithmetic (do not use directly):
  _xhalf.bat     4-bit    goto-dispatch lookup tables
  _xbyte.bat     8-bit    delegates to _xhalf
  _xword.bat     16-bit   delegates to _xbyte
  _xdword.bat    32-bit   delegates to _xword
  _xqword.bat    64-bit   delegates to _xdword

Private float internals:
  _mbfs.bat      MBF single (4-byte) operations
  _mbfd.bat      MBF double (8-byte) operations
```

Each `_x*.bat` layer splits its value into two halves and delegates to the layer below. No `set /a` is used above `_xhalf.bat` level (except in conversion functions at the decimal boundary).

## Return Convention

- Result in `__`
- Carry/borrow in `__c` (internal ops only)
- Division remainder in `__r`
- Error via `exit /B` code (0 = success)

## MBF Float Format Reference

```
Single (4 bytes, big-endian hex):  EE SM MM MM
Double (8 bytes, big-endian hex):  EE SM MM MM MM MM MM MM

EE     = exponent, biased by 128. Zero exponent = value is 0.0.
S      = sign bit (MSB of second byte). 0 = positive, 1 = negative.
MMMMMM = mantissa fraction. Leading 1 bit is implied (not stored).
Value  = (-1)^S * 1.mantissa * 2^(EE - 128)
```

Notable values:

| Decimal | MBF Single | MBF Double |
|---------|-----------|-----------|
| 0 | `00000000` | `0000000000000000` |
| 0.5 | `7F000000` | `7F00000000000000` |
| 1.0 | `80000000` | `8000000000000000` |
| -1.0 | `80800000` | `8080000000000000` |
| 2.0 | `81000000` | `8100000000000000` |
| 10.0 | `83200000` | `8320000000000000` |
| 100.0 | `86480000` | `8648000000000000` |
