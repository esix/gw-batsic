
call %test% "sng.fromInt"
  call expect "sng fromInt i0000" "s00000000"
  call expect "sng fromInt i0001" "s80000000"
  call expect "sng fromInt i000A" "s83200000"
  call expect "sng fromInt iFFFF" "s80800000"

call %test% "sng.fromInt.typeCheck"
  call expecterr "sng fromInt 0001" 13
  call expecterr "sng fromInt s80000000" 13

call %test% "sng.toInt"
  call expect "sng toInt s00000000" "i0000"
  call expect "sng toInt s80000000" "i0001"
  call expect "sng toInt s83200000" "i000A"
  call expect "sng toInt s80800000" "iFFFF"
  call expect "sng toInt s7F000000" "i0000"

call %test% "sng.toInt.typeCheck"
  call expecterr "sng toInt 80000000" 13
  call expecterr "sng toInt i0001" 13

call %test% "sng.neg"
  call expect "sng neg s00000000" "s00000000"
  call expect "sng neg s80000000" "s80800000"
  call expect "sng neg s80800000" "s80000000"

call %test% "sng.abs"
  call expect "sng abs s00000000" "s00000000"
  call expect "sng abs s80000000" "s80000000"
  call expect "sng abs s80800000" "s80000000"

call %test% "sng.add"
  call expect "sng add s80000000 s80000000" "s81000000"
  call expect "sng add s80000000 s80800000" "s00000000"

call %test% "sng.sub"
  call expect "sng sub s81400000 s80000000" "s81000000"

call %test% "sng.cmp"
  call expect "sng cmp s80000000 s81000000" "2"
  call expect "sng cmp s81000000 s80000000" "1"
  call expect "sng cmp s80000000 s80000000" "0"

call %test% "sng.mul"
  @REM 2 * 3 = 6
  call expect "sng mul s81000000 s81400000" "s82400000"

call %test% "sng.div"
  @REM 6 / 2 = 3
  call expect "sng div s82400000 s81000000" "s81400000"
  call expecterr "sng div s80000000 s00000000" 11

call %test% "sng.add.typeCheck"
  call expecterr "sng add s80000000 i0001" 13
  call expecterr "sng add i0001 s80000000" 13

call %test% "sng.fromDec"
  call expect "sng fromDec 0" "s00000000"
  call expect "sng fromDec 1" "s80000000"
  call expect "sng fromDec 100" "s86480000"
  call expect "sng fromDec 0.5" "s7F000000"

call %test% "sng.toDec"
  call expect "sng toDec s00000000" "0"
  call expect "sng toDec s80000000" "1"
  call expect "sng toDec s80800000" "-1"

call %test% "sng.toDec.typeCheck"
  call expecterr "sng toDec 80000000" 13
  call expecterr "sng toDec i0001" 13

call %test% "sng.roundtrip"
  @REM fromInt then toInt should be identity for integers
  call expect "sng fromInt i0064" "s86480000"
  call expect "sng toInt s86480000" "i0064"
