
call %test% "xdword.check"
  call expecterr "_xdword check 00000000" 0
  call expecterr "_xdword check FFFFFFFF" 0
  call expecterr "_xdword check 12AB34CD" 0
  call expecterr "_xdword check 0000" 1
  call expecterr "_xdword check 000000000" 1

call %test% "xdword.inc"
  call expect "_xdword inc 00000000" "00000001"
  call expect "_xdword inc 0000FFFF" "00010000"
  call expect "_xdword inc FFFFFFFE" "FFFFFFFF"
  call expect "_xdword inc FFFFFFFF" "00000000"

call %test% "xdword.dec"
  call expect "_xdword dec 00000001" "00000000"
  call expect "_xdword dec 00010000" "0000FFFF"
  call expect "_xdword dec 00000000" "FFFFFFFF"

call %test% "xdword.add"
  call expect "_xdword add 00000000 00000000" "00000000"
  call expect "_xdword add 00000001 00000001" "00000002"
  call expect "_xdword add 0000FFFF 00000001" "00010000"
  call expect "_xdword add FFFFFFFF 00000001" "00000000"
  call expect "_xdword add 12345678 11111111" "23456789"

call %test% "xdword.sub"
  call expect "_xdword sub 00000000 00000000" "00000000"
  call expect "_xdword sub 00010000 00000001" "0000FFFF"
  call expect "_xdword sub 00000000 00000001" "FFFFFFFF"
  call expect "_xdword sub 23456789 11111111" "12345678"

call %test% "xdword.inv"
  call expect "_xdword inv 00000000" "FFFFFFFF"
  call expect "_xdword inv FFFFFFFF" "00000000"
  call expect "_xdword inv A5A5A5A5" "5A5A5A5A"

call %test% "xdword.neg"
  call expect "_xdword neg 00000001" "FFFFFFFF"
  call expect "_xdword neg FFFFFFFF" "00000001"
  call expect "_xdword neg 00000000" "00000000"

call %test% "xdword.and"
  call expect "_xdword and FFFFFFFF FFFFFFFF" "FFFFFFFF"
  call expect "_xdword and FFFFFFFF 00000000" "00000000"
  call expect "_xdword and A5A5A5A5 5A5A5A5A" "00000000"

call %test% "xdword.or"
  call expect "_xdword or 00000000 00000000" "00000000"
  call expect "_xdword or A5A5A5A5 5A5A5A5A" "FFFFFFFF"

call %test% "xdword.xor"
  call expect "_xdword xor 00000000 00000000" "00000000"
  call expect "_xdword xor FFFFFFFF FFFFFFFF" "00000000"
  call expect "_xdword xor A5A5A5A5 5A5A5A5A" "FFFFFFFF"

call %test% "xdword.shr"
  call expect "_xdword shr 00000000" "00000000"
  call expect "_xdword shr 00000002" "00000001"
  call expect "_xdword shr 80000000" "40000000"
  call expect "_xdword shr 00010000" "00008000"

call %test% "xdword.shl"
  call expect "_xdword shl 00000000" "00000000"
  call expect "_xdword shl 00000001" "00000002"
  call expect "_xdword shl 40000000" "80000000"
  call expect "_xdword shl 80000000" "00000000"
  call expect "_xdword shl 00008000" "00010000"
