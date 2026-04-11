
call %test% "xqword.check"
  call expecterr "_xqword check 0000000000000000" 0
  call expecterr "_xqword check FFFFFFFFFFFFFFFF" 0
  call expecterr "_xqword check 00000000" 1
  call expecterr "_xqword check 00000000000000000" 1

call %test% "xqword.inc"
  call expect "_xqword inc 0000000000000000" "0000000000000001"
  call expect "_xqword inc 00000000FFFFFFFF" "0000000100000000"
  call expect "_xqword inc FFFFFFFFFFFFFFFE" "FFFFFFFFFFFFFFFF"
  call expect "_xqword inc FFFFFFFFFFFFFFFF" "0000000000000000"

call %test% "xqword.dec"
  call expect "_xqword dec 0000000000000001" "0000000000000000"
  call expect "_xqword dec 0000000100000000" "00000000FFFFFFFF"
  call expect "_xqword dec 0000000000000000" "FFFFFFFFFFFFFFFF"

call %test% "xqword.add"
  call expect "_xqword add 0000000000000000 0000000000000000" "0000000000000000"
  call expect "_xqword add 0000000000000001 0000000000000001" "0000000000000002"
  call expect "_xqword add 00000000FFFFFFFF 0000000000000001" "0000000100000000"
  call expect "_xqword add FFFFFFFFFFFFFFFF 0000000000000001" "0000000000000000"

call %test% "xqword.sub"
  call expect "_xqword sub 0000000000000000 0000000000000000" "0000000000000000"
  call expect "_xqword sub 0000000100000000 0000000000000001" "00000000FFFFFFFF"
  call expect "_xqword sub 0000000000000000 0000000000000001" "FFFFFFFFFFFFFFFF"

call %test% "xqword.inv"
  call expect "_xqword inv 0000000000000000" "FFFFFFFFFFFFFFFF"
  call expect "_xqword inv FFFFFFFFFFFFFFFF" "0000000000000000"

call %test% "xqword.shr"
  call expect "_xqword shr 0000000000000002" "0000000000000001"
  call expect "_xqword shr 0000000100000000" "0000000080000000"
  call expect "_xqword shr 8000000000000000" "4000000000000000"

call %test% "xqword.shl"
  call expect "_xqword shl 0000000000000001" "0000000000000002"
  call expect "_xqword shl 0000000080000000" "0000000100000000"
  call expect "_xqword shl 4000000000000000" "8000000000000000"
  call expect "_xqword shl 8000000000000000" "0000000000000000"
