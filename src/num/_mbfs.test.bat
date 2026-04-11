
call %test% "mbfs.isZero"
  call expect "_mbfs isZero 00000000" "1"
  call expect "_mbfs isZero 80000000" ""
  call expect "_mbfs isZero 00123456" "1"

call %test% "mbfs.neg"
  call expect "_mbfs neg 00000000" "00000000"
  call expect "_mbfs neg 80000000" "80800000"
  call expect "_mbfs neg 80800000" "80000000"
  call expect "_mbfs neg 83200000" "83A00000"

call %test% "mbfs.abs"
  call expect "_mbfs abs 00000000" "00000000"
  call expect "_mbfs abs 80000000" "80000000"
  call expect "_mbfs abs 80800000" "80000000"
  call expect "_mbfs abs 83A00000" "83200000"

call %test% "mbfs.getMant"
  @REM 1.0: exp=80, stored=000000 -> mantissa with implied 1 = 00800000
  call expect "_mbfs getMant 80000000" "00800000"
  @REM 1.5: exp=80, stored=400000 -> mantissa = 00C00000
  call expect "_mbfs getMant 80400000" "00C00000"
  @REM -1.0: exp=80, stored=800000 -> mantissa = 00800000 (sign cleared, 1 set)
  call expect "_mbfs getMant 80800000" "00800000"

call %test% "mbfs.pack"
  @REM pack(80, 0, 00800000) -> 80000000 (1.0)
  call expect "_mbfs pack 80 0 00800000" "80000000"
  @REM pack(80, 1, 00800000) -> 80800000 (-1.0)
  call expect "_mbfs pack 80 1 00800000" "80800000"
  @REM pack(80, 0, 00C00000) -> 80400000 (1.5)
  call expect "_mbfs pack 80 0 00C00000" "80400000"
  @REM pack(00, ...) -> 00000000 (zero)
  call expect "_mbfs pack 00 0 00000000" "00000000"

call %test% "mbfs.normalize"
  @REM Already normalized (bit 23 set)
  call expect "_mbfs normalize 80 00800000" "00800000"
  @REM Needs 1 shift: 00400000 -> 00800000, exp 80->7F
  call expect "_mbfs normalize 80 00400000" "00800000"
  @REM Zero mantissa -> zero
  call expect "_mbfs normalize 80 00000000" "00000000"

call %test% "mbfs.fromInt"
  @REM 0
  call expect "_mbfs fromInt 0000" "00000000"
  @REM 1 = 1.0 * 2^0, exp=128=0x80
  call expect "_mbfs fromInt 0001" "80000000"
  @REM 2 = 1.0 * 2^1, exp=129=0x81
  call expect "_mbfs fromInt 0002" "81000000"
  @REM 3 = 1.1 * 2^1, exp=129
  call expect "_mbfs fromInt 0003" "81400000"
  @REM 10 = 1.01 * 2^3, exp=131=0x83
  call expect "_mbfs fromInt 000A" "83200000"
  @REM 100 = 1.100100 * 2^6, exp=134=0x86
  call expect "_mbfs fromInt 0064" "86480000"
  @REM 32767 = 0x7FFF
  call expect "_mbfs fromInt 7FFF" "8E7FFE00"
  @REM -1
  call expect "_mbfs fromInt FFFF" "80800000"
  @REM -10
  call expect "_mbfs fromInt FFF6" "83A00000"
  @REM -32768 = 0x8000 -> sign=1, 1.0 * 2^15, exp=8F
  call expect "_mbfs fromInt 8000" "8F800000"

call %test% "mbfs.cmp"
  @REM Equal
  call expect "_mbfs cmp 00000000 00000000" "0"
  call expect "_mbfs cmp 80000000 80000000" "0"
  @REM Zero vs positive/negative
  call expect "_mbfs cmp 00000000 80000000" "2"
  call expect "_mbfs cmp 80000000 00000000" "1"
  call expect "_mbfs cmp 00000000 80800000" "1"
  call expect "_mbfs cmp 80800000 00000000" "2"
  @REM Positive comparisons
  call expect "_mbfs cmp 81000000 80000000" "1"
  call expect "_mbfs cmp 80000000 81000000" "2"
  @REM Negative comparisons (-1 vs -2: -1 > -2)
  call expect "_mbfs cmp 80800000 81800000" "1"
  call expect "_mbfs cmp 81800000 80800000" "2"
  @REM Mixed signs
  call expect "_mbfs cmp 80000000 80800000" "1"
  call expect "_mbfs cmp 80800000 80000000" "2"

call %test% "mbfs.add"
  @REM 0 + x = x
  call expect "_mbfs add 00000000 80000000" "80000000"
  call expect "_mbfs add 80000000 00000000" "80000000"
  @REM 1 + 1 = 2
  call expect "_mbfs add 80000000 80000000" "81000000"
  @REM 1 + 2 = 3
  call expect "_mbfs add 80000000 81000000" "81400000"
  @REM 10 + 10 = 20 (83200000 + 83200000 = 84200000)
  @REM 20 = 1.01 * 2^4, exp=132=0x84
  call expect "_mbfs add 83200000 83200000" "84200000"
  @REM 1 + (-1) = 0
  call expect "_mbfs add 80000000 80800000" "00000000"
  @REM 3 + (-1) = 2 (81400000 + 80800000)
  call expect "_mbfs add 81400000 80800000" "81000000"
  @REM (-5) + (-3) = -8
  @REM 5 = 82200000, -5 = 82A00000
  @REM 3 = 81400000, -3 = 81C00000
  @REM 8 = 1.0 * 2^3, exp=131=0x83, -8 = 83800000
  call expect "_mbfs add 82A00000 81C00000" "83800000"

call %test% "mbfs.sub"
  @REM 3 - 1 = 2
  call expect "_mbfs sub 81400000 80000000" "81000000"
  @REM 1 - 1 = 0
  call expect "_mbfs sub 80000000 80000000" "00000000"
  @REM 1 - 3 = -2 (81000000 with sign = 81800000)
  call expect "_mbfs sub 80000000 81400000" "81800000"

call %test% "mbfs.mul"
  @REM 0 * x = 0
  call expect "_mbfs mul 00000000 80000000" "00000000"
  @REM 1 * 1 = 1
  call expect "_mbfs mul 80000000 80000000" "80000000"
  @REM 2 * 3 = 6 (81000000 * 81400000)
  @REM 6 = 1.1 * 2^2, exp=130=0x82, mant frac=.1 -> byte2=40
  call expect "_mbfs mul 81000000 81400000" "82400000"
  @REM 10 * 10 = 100 (83200000 * 83200000 = 86480000)
  call expect "_mbfs mul 83200000 83200000" "86480000"
  @REM 2 * (-3) = -6 (81000000 * 81C00000)
  call expect "_mbfs mul 81000000 81C00000" "82C00000"
  @REM (-2) * (-3) = 6
  call expect "_mbfs mul 81800000 81C00000" "82400000"

call %test% "mbfs.div"
  @REM 0 / x = 0
  call expect "_mbfs div 00000000 80000000" "00000000"
  @REM x / 0 = error 11
  call expecterr "_mbfs div 80000000 00000000" 11
  @REM 1 / 1 = 1
  call expect "_mbfs div 80000000 80000000" "80000000"
  @REM 6 / 3 = 2 (82400000 / 81400000 = 81000000)
  call expect "_mbfs div 82400000 81400000" "81000000"
  @REM 6 / 2 = 3 (82400000 / 81000000 = 81400000)
  call expect "_mbfs div 82400000 81000000" "81400000"
  @REM 100 / 10 = 10 (86480000 / 83200000 = 83200000)
  call expect "_mbfs div 86480000 83200000" "83200000"
  @REM -6 / 3 = -2
  call expect "_mbfs div 82C00000 81400000" "81800000"
  @REM 6 / (-3) = -2
  call expect "_mbfs div 82400000 81C00000" "81800000"

call %test% "mbfs.fromDec"
  call expect "_mbfs fromDec 0" "00000000"
  call expect "_mbfs fromDec 1" "80000000"
  call expect "_mbfs fromDec -1" "80800000"
  call expect "_mbfs fromDec 10" "83200000"
  call expect "_mbfs fromDec 100" "86480000"
  call expect "_mbfs fromDec 0.5" "7F000000"
  @REM 3.14: significand=314, exp10=-2 -> mul by 10^(-2)
  @REM Verify roundtrip rather than exact hex (float precision)

call %test% "mbfs.toDec"
  call expect "_mbfs toDec 00000000" "0"
  call expect "_mbfs toDec 80000000" "1"
  call expect "_mbfs toDec 80800000" "-1"
  call expect "_mbfs toDec 81000000" "2"
  call expect "_mbfs toDec 83200000" "1E1"

call %test% "mbfs.toDec.more"
  @REM 100 = 86480000: should output "1E2" (1.0 * 10^2)
  call expect "_mbfs toDec 86480000" "1E2"
  @REM 0.5 = 7F000000
  call expect "_mbfs toDec 7F000000" "5E-1"
  @REM -10
  call expect "_mbfs toDec 83A00000" "-1E1"

call %test% "mbfs.fromDec.Enotation"
  @REM 1E2 = 100
  call expect "_mbfs fromDec 1E2" "86480000"
  @REM 5E-1 = 0.5
  call expect "_mbfs fromDec 5E-1" "7F000000"
  @REM -2.5E1 = -25
  @REM -25 = -1.1001 * 2^4, exp=84, byte2=C8 (sign=1, frac=48)
  call expect "_mbfs fromDec -2.5E1" "84C80000"

call %test% "mbfs.fromDec.roundtrip"

call %test% "mbfs.toInt"
  @REM 0
  call expect "_mbfs toInt 00000000" "0000"
  @REM 1.0
  call expect "_mbfs toInt 80000000" "0001"
  @REM 2.0
  call expect "_mbfs toInt 81000000" "0002"
  @REM 10.0
  call expect "_mbfs toInt 83200000" "000A"
  @REM 100.0
  call expect "_mbfs toInt 86480000" "0064"
  @REM 32767.0 (8E7FFE00, not 8EFFFE00 which is -32767)
  call expect "_mbfs toInt 8E7FFE00" "7FFF"
  @REM -1.0
  call expect "_mbfs toInt 80800000" "FFFF"
  @REM -10.0
  call expect "_mbfs toInt 83A00000" "FFF6"
  @REM 0.5 -> truncates to 0
  call expect "_mbfs toInt 7F000000" "0000"
  @REM 1.5 -> truncates to 1
  call expect "_mbfs toInt 80400000" "0001"
