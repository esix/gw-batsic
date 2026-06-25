# Numeric built-in functions

GW-BASIC ships a small library of numeric intrinsics: the sign/rounding
trio (`ABS`, `INT`, `FIX`, `SGN`), the square root and transcendentals
(`SQR`, `SIN`, `COS`, `TAN`, `ATN`, `LOG`, `EXP`), the random-number pair
(`RND` / `RANDOMIZE`), the type-coercion functions (`CINT`, `CSNG`,
`CDBL`), and the clock reader `TIMER`. Each one is a single `.bat` file in
`src/rtl/`, dispatched by the executor when it hits the corresponding
postfix action token.

The thing to keep in mind throughout: these functions do **not** operate
on IEEE 754 floats. Every value is a Microsoft Binary Format number — a
single is 4 bytes, a double is 8 bytes — stored as a tagged uppercase hex
string (`s86480000`, `d8649000000000000`) and manipulated by the hex
arithmetic stack described in [02 — Numerics & MBF](02-numerics.md). The
transcendentals are pure batch: no shelling out to a math library, no
`set /a` floating point (there isn't any). They reduce the argument's
range, run a Taylor or atanh series of MBF adds/muls/divs, and pack the
result back into a 4-byte single. A single `SIN` is on the order of
seconds, because every series term costs several MBF multiplies and every
MBF multiply is hundreds of nibble operations underneath.

## Calling convention

These are ordinary RTL handlers and follow the executor's stack-machine
convention (see the `src/rtl/` and "State" sections of
[01 — Architecture](01-architecture.md)). The executor keeps the eval
stack in an env var and passes its *name* to the handler:

```bat
call %GWSRC%\rtl\FN_SIN %_s%
```

`%_s%` is the stack-variable name. Every handler does the same dance:

```bat
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _a      @REM pop the argument off the stack
call %GWSRC%\exec\_resolve !_a! _a    @REM if it's a VAR_ token, look it up
... compute ...
call %GWSRC%\stl\vec push %_s% !_result!
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & exit /B 0
```

`_resolve` turns a `VAR_…` token into its tagged value (and passes a bare
`i…`/`s…`/`d…` through unchanged), so the same handler works whether the
argument is a literal, a variable, or a sub-expression result.

The return code carries the GW-BASIC error: `0` success, `5` Illegal
function call (e.g. `SQR` of a negative, `LOG` of a non-positive), and `13`
Type mismatch (an argument that isn't `i`/`s`/`d`).
The error propagates up through the executor's `ON ERROR` machinery.

Most of the transcendentals start by coercing the argument to a single:
an `i` argument goes through `sng fromInt`, a `d` argument round-trips
`dbl toDec` → `sng fromDec`, and an `s` argument is used as-is. The result
is always a single (`NUM_s…`), matching GW-BASIC, whose math functions
return single precision.

## Sign and rounding: ABS, INT, FIX, SGN

These are the cheap ones — no series, just hex inspection.

`FN_ABS` preserves the input's type. For an `i` value it checks the high
nibble for the sign bit and calls `int neg` if set; for `s`/`d` it
delegates to `sng abs` / `dbl abs`, which clear the MBF sign bit (the top
bit of the byte after the exponent) with a single `_xbyte and … 7F`.

`FN_SGN` returns an integer `-1` / `0` / `1`. Zero is detected by the
exponent/word being all zeros; sign comes from the high nibble of the sign
byte (`~1,1` for int, `~3,1` for the MBF types).

`FN_FIX` truncates toward zero. For floats it round-trips through `toInt`
then `fromInt` (`sng toInt` truncates toward zero by construction, so
`FIX(-3.7)` lands on `-3`):

```bat
call %GWSRC%\num\sng toInt !_a!
call %GWSRC%\num\sng fromInt !__!
```

`FN_INT` is floor (round toward −∞), which differs from `FIX` only for
negative values with a fractional part. It does the same truncating
round-trip, then — if the original was negative *and* the truncated value
differs from it (i.e. there was a fraction) — subtracts one:

```bat
if not "!_round!"=="!_a!" (
  set "_d=!_a:~3,1!"
  set "_neg="
  for %%c in (8 9 A B C D E F) do if "!_d!"=="%%c" set "_neg=1"
  if defined _neg ( call %GWSRC%\num\int sub !_iv! i0001 ... )
)
```

So `INT(-3.7) = -4` while `FIX(-3.7) = -3`.

## Square root: Newton's method

`FN_SQR` is the simplest of the iterative functions. After coercing to
single and rejecting negatives (error `5`) and short-circuiting zero, it
runs ten Newton iterations of `x ← (x + N/x) / 2` starting from `x₀ = N`:

```bat
set "_x=!_n!"
for /L %%i in (1,1,10) do (
  call %GWSRC%\num\sng div !_n! !_x!
  call %GWSRC%\num\sng add !_x! !__!
  call :_half !__! _x
)
```

Newton roughly doubles the correct digits per step, so ten iterations is
plenty for single precision (~7 significant figures). The `:_half`
helper is the one clever bit: "divide by two" is done by decrementing the
MBF exponent byte rather than running a full `sng div`, with an underflow
guard that flushes to zero:

```bat
set "_eb=!_v:~1,2!"
set /a "_e=0x!_eb! - 1"
if !_e! lss 1 (endlocal & set "%~2=s00000000" & exit /B 0)
```

`SQR` is also reused as a primitive: `FN_ATN`'s half-angle reduction calls
back into `FN_SQR` on a scratch stack.

## Sine and the Taylor family

`FN_SIN` is the centerpiece and the template the others copy. The plan is
**range reduction then Taylor series**.

First it reduces the argument into `[0, 2π)` by subtracting whole
multiples of 2π (`y = x − 2π·trunc(x/2π)`, then add 2π if negative). The
constants π, 2π, π/2, 3π/2 are built once per call from decimal literals
via `sng fromDec` (e.g. `sng fromDec 3.141593` → `_PI`).

Then a quadrant analysis folds `y` down into `[0, π/2]` and records a sign,
using `sng cmp` against `π/2`, `π`, and `3π/2`:

| Quadrant of `y` | reduced `z` | sign |
|---|---|---|
| `[0, π/2]` | `z = y` | `+` |
| `[π/2, π]` | `z = π − y` | `+` |
| `[π, 3π/2]` | `z = y − π` | `−` |
| `[3π/2, 2π]` | `z = 2π − y` | `−` |

Finally the Taylor series `sin(z) = z − z³/3! + z⁵/5! − …` runs as six
terms. Each step multiplies the running term by `−z²` and divides by the
next `(2n)(2n+1)` denominator, so the denominators are hard-coded:

```bat
call %GWSRC%\num\sng mul !_z! !_z!
call %GWSRC%\num\sng neg !__!
set "_nz2=!__!"
set "_sum=!_z!"
set "_term=!_z!"
for %%d in (6 20 42 72 110 156) do (
  call %GWSRC%\num\sng mul !_term! !_nz2!
  set "_term=!__!"
  call %GWSRC%\num\sng fromDec %%d
  call %GWSRC%\num\sng div !_term! !__!
  set "_term=!__!"
  call %GWSRC%\num\sng add !_sum! !_term!
  set "_sum=!__!"
)
```

If the quadrant sign was `−`, negate the sum. Six terms give ~7 digits for
`z` in `[0, π/2]`, which is exactly the range reduction guarantees.

**`FN_COS` and `FN_TAN` delegate.** `COS` uses the identity
`cos(x) = sin(π/2 − x)`: it computes `π/2 − x`, pushes that back on the
stack, and calls `FN_SIN` to do all the work. `TAN` computes
`tan(x) = sin(x) / cos(x)` by running `FN_SIN` and `FN_COS` on a scratch
stack and dividing, with a guard that returns error `5` when `cos(x)`
underflows to zero (the asymptote):

```bat
if "!_cosv:~1,2!"=="00" ( ... endlocal & set "%~1=%_final%" & exit /B 5 )
call %GWSRC%\num\sng div !_sinv! !_cosv!
```

So all of the range-reduction and series logic lives in exactly one place.

## EXP, LOG, ATN

The other three transcendentals follow the same "reduce, then series"
shape, each exploiting the MBF exponent byte to do the cheap part.

`FN_EXP` reduces with `x = k·ln2 + r`, where `k = trunc(x/ln2)` and
`r ∈ (−ln2, ln2)`. Then `eˣ = 2ᵏ · eʳ`, with `eʳ` from an 8-term Taylor
series and `2ᵏ` applied by **adding `k` to the MBF exponent byte** via the
`:_scalePow2` helper (with overflow → unchanged, underflow → zero):

```bat
set /a "_e=0x!_v:~1,2! + _k"
if !_e! LEQ 0 (endlocal & set "%~3=s00000000" & exit /B 0)
if !_e! GTR 255 (endlocal & set "%~3=!_v!" & exit /B 0)
```

`FN_LOG` (natural log; error `5` for `x ≤ 0`) decomposes the MBF value
directly: `x = m · 2ᵉ` with `m ∈ [1, 2)`, read straight off the storage
format — `e = EE − 128` from the exponent byte, and `m` is `x` with its
exponent byte forced to `0x80`:

```bat
set /a "_e=0x!_x:~1,2! - 128"
set "_m=s80!_x:~3!"
```

Then `ln(x) = ln(m) + e·ln2`, with `ln(m)` from the fast atanh series
`ln(m) = 2·(t + t³/3 + t⁵/5 + …)` where `t = (m−1)/(m+1)` is small because
`m ∈ [1, 2)`. `ln2` is the literal `0.693147`.

`FN_ATN` works on `|x|` and reapplies the sign at the end (arctan is odd).
For `a > 1` it uses `atan(a) = π/2 − atan(1/a)` to bring the argument into
`[0, 1]`, then a half-angle reduction `atan(a) = 2·atan(a/(1+√(1+a²)))`
(this is where it calls `FN_SQR`) shrinks the argument below
`tan(π/8) ≈ 0.414`, where `atan(t) = t − t³/3 + t⁵/5 − …` converges in
about seven terms.

## RND and RANDOMIZE

This is the most "best-effort" corner, because `cmd.exe` gives us only
`%RANDOM%` (0..32767) with **no exposed seed**.

`FN_RND` generates the next number by scaling `%RANDOM%` into a 4-decimal
fraction and converting it to a single in `[0, 1)`:

```bat
set /a "_r=%RANDOM%"
set /a "_n4=_r * 10000 / 32768"
set "_padded=0000!_n4!"
set "_padded=!_padded:~-4!"
call %GWSRC%\num\sng fromDec 0.!_padded!
```

It honours GW-BASIC's argument convention as far as it can within one
process: `RND(0)` returns the cached previous result from `_rnd_last`
(remembered across calls within a single `RUN` via the `endlocal & set
"_rnd_last=…"` propagation), while a positive or negative argument
generates a fresh number. True reseeding for a negative argument isn't
meaningful without a seedable PRNG, so it just generates the next number.

`RND_NOARG` handles the bare `RND` with no parentheses by pushing the
default argument `NUM_i0001` — i.e. `RND` is treated as `RND(1)`, "next
number":

```bat
call %GWSRC%\stl\vec push %_s% NUM_i0001
```

`RANDOMIZE` pops its seed expression off the stack and **ignores it** —
there's no seed knob to turn — so it's a no-op apart from the stack
discipline of removing the pushed value. `RANDOMIZE_NOSEED` (the bare
`RANDOMIZE` form, which would normally prompt for a seed) is an even purer
no-op: nothing was pushed, so there's nothing to pop, and the whole file
is `exit /B 0`.

## CINT, CSNG, CDBL, TIMER

The coercion functions convert between the three numeric types using the
facade conversions.

`FN_CINT` rounds to the nearest signed 16-bit integer (range −32768..32767,
else Overflow `6`). It rounds half-away-from-zero by adding `±0.5` before
truncating — GW-BASIC actually rounds half-to-even, which this approximates:

```bat
call %GWSRC%\num\sng fromDec 0.5
if defined _neg (call %GWSRC%\num\sng sub !_a! !_half!) else (call %GWSRC%\num\sng add !_a! !_half!)
call %GWSRC%\num\sng toInt !__!
```

`FN_CSNG` widens or narrows to single: `int → sng fromInt`, `s` passes
through, `d → sng` via a `dbl toDec` → `sng fromDec` round-trip (losing
mantissa bits, as expected). `FN_CDBL` is the mirror: `int → dbl fromInt`,
`s → dbl` via `sng toDec` → `dbl fromDec`, `d` passes through. Both error
`13` on a non-numeric argument.

`FN_TIMER` reads `%TIME%` ("HH:MM:SS.cc") and returns seconds since
midnight as a single. The fields are fed through the `1XX − 100` trick to
dodge `cmd.exe`'s octal interpretation of leading-zero values like `08`;
the fractional hundredths are dropped, so resolution is one second:

```bat
set /a "_total=(1!_h! - 100) * 3600 + (1!_m! - 100) * 60 + (1!_sec! - 100)"
call %GWSRC%\num\sng fromDec !_total!
```

## Problems & gotchas

**Integer assignment truncates instead of rounding.** This is the most
visible deviation from real GW-BASIC, and it lives one layer up in
`src/rtl/ASSIGN.bat`, not in these functions. When a `sng`/`dbl` value is
stored into an integer variable, `ASSIGN` calls `sng toInt` / `dbl toInt`,
which truncate toward zero:

```bat
if "!_tp!"=="i" if "!_vtp!" neq "i" (
  if "!_vtp!"=="s" ( call %GWSRC%\num\sng toInt !_val! ... )
)
```

So `A% = 2.9` stores `2`. Real GW-BASIC applies `CINT` semantics on
assignment to an integer variable, which would round to `3`. If you want
the rounding behaviour, call `CINT` explicitly (`A% = CINT(2.9)`) — that
function adds `±0.5` first, as shown above.

**Divide and multiply round to nearest (and used not to).** The MBF
`mul` and `div` in `_mbfs` / `_mbfd` compute a guard bit below the kept
mantissa and round on it. Earlier versions truncated, biasing every
product and quotient about 1 ULP low (`1.0/10.0` came out as `…CCCC`
instead of `…CCCD`). The fix is visible in `:_mul_rnd` / `:_div_rnd` and
in the `fromDec` rounding path. Because the series functions chain dozens
of these operations, the rounding matters: truncation would let error
accumulate across all six Taylor terms.

**`fromDec` magnitude bug — fixed, with a 16-digit ceiling remaining.**
There was a real conversion bug where `fromDec` dropped the decimal
exponent for numbers with more than ~7 digits, leaving large magnitudes
off by powers of ten (e.g. `1234567.891` came out as `~1234.567` — three
orders of magnitude, a literal ×1000 loss). It was fixed in the double
path that single now routes through: `_mbfd`'s `fromDec` accumulates the
significand across two 8-digit chunks (`hi` and `lo`), tracks dropped
integer digits in `intskip`, and applies `exp10 = intskip − flen` so
out-of-range digits shift the decimal exponent instead of corrupting it.
The regression is pinned by the `sng.fromDec.largeDecimal` test. The
genuine *remaining* limit is that only the first 16 significant digits are
captured (the `_pw_0`..`_pw_8` chunk-combining table covers exactly the
0..8 low-chunk digits); digits past the 16th only adjust the exponent.

**`toDec` last-place drift on single.** The display conversion scales by
multiplying/dividing by 10 (which isn't exact in binary) and extracts
digits one at a time. Single output is now rendered through the *double*
extraction path (`sng toDec` calls `_mbfd toDec … 7 7`) precisely to dodge
the single-precision extraction error that used to render `73` as
`72.99999` and `0.1` as `.09999999`. See the "Conversion" section of
[02 — Numerics & MBF](02-numerics.md) for the full story.

**RND has no real seed.** As above: `RANDOMIZE` cannot reseed, `RND(-N)`
cannot reproduce a stream, and `_rnd_last` only survives within a single
process/`RUN`. Programs relying on a deterministic seeded sequence will not
reproduce GW-BASIC's exact numbers.

**Speed.** Pure-batch transcendentals are slow — a single
`SIN`/`COS`/`TAN`/`LOG`/`EXP`/`ATN` is on the order of seconds, since each
series term is several MBF multiplies and each multiply is hundreds of
nibble operations. A deliberate "research-clean, no shell-out" tradeoff,
not a bug.

## How it is tested

The numeric layer these functions stand on is covered by the per-module
suites in `src/num/` — `sng.test.bat`, `dbl.test.bat`, `_mbfs.test.bat`,
and `_mbfd.test.bat` — run through the `tests/expect.bat` /
`tests/expecterr.bat` harness. The conversion war stories above each have
a named regression case:

- `sng.fromDec.largeDecimal` pins the ×1000 / decimal-exponent fix
  (`1234567.891` → `s9416B43F`, not `1234.567`).
- `sng.fromDec.rounding` pins round-to-nearest (`0.1` → `s7C4CCCCD`).
- `sng.toDec.accuracy` pins exact display (`73` → `73`, not `72.99999`).

The function handlers themselves are exercised end-to-end by the example
`.BAS` programs under `examples/` and the smoke test in
`tests/cli.test.bat`. Run the whole tree with the root `test.bat`.
