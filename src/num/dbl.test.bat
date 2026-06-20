
call %test% "dbl.fromInt"
  call expect "dbl fromInt i0000" "d0000000000000000"
  call expect "dbl fromInt i0001" "d8000000000000000"
  call expect "dbl fromInt i000A" "d8320000000000000"
  call expect "dbl fromInt iFFFF" "d8080000000000000"

call %test% "dbl.fromInt.typeCheck"
  call expecterr "dbl fromInt 0001" 13
  call expecterr "dbl fromInt s80000000" 13

call %test% "dbl.toInt"
  call expect "dbl toInt d0000000000000000" "i0000"
  call expect "dbl toInt d8000000000000000" "i0001"
  call expect "dbl toInt d8320000000000000" "i000A"

call %test% "dbl.add"
  call expect "dbl add d8000000000000000 d8000000000000000" "d8100000000000000"

call %test% "dbl.sub"
  call expect "dbl sub d8140000000000000 d8000000000000000" "d8100000000000000"

call %test% "dbl.mul"
  call expect "dbl mul d8100000000000000 d8140000000000000" "d8240000000000000"

call %test% "dbl.div"
  call expect "dbl div d8240000000000000 d8100000000000000" "d8140000000000000"
  call expecterr "dbl div d8000000000000000 d0000000000000000" 11

call %test% "dbl.neg"
  call expect "dbl neg d8000000000000000" "d8080000000000000"
  call expect "dbl neg d8080000000000000" "d8000000000000000"

call %test% "dbl.cmp"
  call expect "dbl cmp d8100000000000000 d8000000000000000" "1"
  call expect "dbl cmp d8000000000000000 d8000000000000000" "0"

call %test% "dbl.fromDec"
  call expect "dbl fromDec 0" "d0000000000000000"
  call expect "dbl fromDec 1" "d8000000000000000"
  call expect "dbl fromDec 10" "d8320000000000000"

call %test% "dbl.fromDec.largeDecimal"
  @REM Regression: digits past the accumulator limit must not corrupt the
  @REM exponent (1234567.891 must stay ~1.23e6, not 1234.567).  Double now
  @REM keeps ~16 significant digits (64-bit significand), so 1234567.891 is
  @REM stored to full precision and round-trips exactly.
  call expect "dbl fromDec 1234567.891" "d9416B43F20C49BA4"
  call expect "dbl toDec d9416B43F20C49BA4" "1234567.891"

call %test% "dbl.precision.roundtrip"
  @REM 15-16 significant digits round-trip (was capped at 7).
  call expect "dbl toDec d8A1A522B6AE7D566" "1234.5678"
  call expect "dbl fromDec 1234.5678" "d8A1A522B6AE7D566"
  call expect "dbl fromDec 314159265358979" "dB00EDCF3B5124180"
  call expect "dbl toDec dB00EDCF3B5124180" "314159265358979"

call %test% "dbl.toDec"
  call expect "dbl toDec d0000000000000000" "0"
  call expect "dbl toDec d8000000000000000" "1"
  call expect "dbl toDec d8080000000000000" "-1"

call %test% "dbl.typeCheck"
  call expecterr "dbl add d8000000000000000 s80000000" 13
  call expecterr "dbl neg s80000000" 13
  call expecterr "dbl toDec s80000000" 13
