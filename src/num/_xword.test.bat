
call %test% "xword.check"
  call expecterr "_xword check 0000" 0
  call expecterr "_xword check FFFF" 0
  call expecterr "_xword check A3B2" 0
  call expecterr "_xword check 00" 1
  call expecterr "_xword check 00000" 1
  call expecterr "_xword check GGGG" 1

call %test% "xword.inc"
  call expect "_xword inc 0000" "0001"
  call expect "_xword inc 00FF" "0100"
  call expect "_xword inc 0FFF" "1000"
  call expect "_xword inc FFFE" "FFFF"
  call expect "_xword inc FFFF" "0000"

call %test% "xword.dec"
  call expect "_xword dec 0001" "0000"
  call expect "_xword dec 0100" "00FF"
  call expect "_xword dec 0000" "FFFF"
  call expect "_xword dec FFFF" "FFFE"

call %test% "xword.add"
  call expect "_xword add 0000 0000" "0000"
  call expect "_xword add 0001 0001" "0002"
  call expect "_xword add 00FF 0001" "0100"
  call expect "_xword add FFFF 0001" "0000"
  call expect "_xword add 1234 5678" "68AC"
  call expect "_xword add 8000 8000" "0000"

call %test% "xword.sub"
  call expect "_xword sub 0000 0000" "0000"
  call expect "_xword sub 0100 0001" "00FF"
  call expect "_xword sub FFFF 0001" "FFFE"
  call expect "_xword sub 0000 0001" "FFFF"
  call expect "_xword sub 68AC 5678" "1234"

call %test% "xword.inv"
  call expect "_xword inv 0000" "FFFF"
  call expect "_xword inv FFFF" "0000"
  call expect "_xword inv A5A5" "5A5A"

call %test% "xword.and"
  call expect "_xword and FFFF FFFF" "FFFF"
  call expect "_xword and FFFF 0000" "0000"
  call expect "_xword and A5A5 5A5A" "0000"

call %test% "xword.or"
  call expect "_xword or 0000 0000" "0000"
  call expect "_xword or A5A5 5A5A" "FFFF"

call %test% "xword.xor"
  call expect "_xword xor 0000 0000" "0000"
  call expect "_xword xor FFFF FFFF" "0000"
  call expect "_xword xor A5A5 5A5A" "FFFF"

call %test% "xword.shr"
  call expect "_xword shr 0000" "0000"
  call expect "_xword shr 0002" "0001"
  call expect "_xword shr 8000" "4000"
  call expect "_xword shr FFFF" "7FFF"
  call expect "_xword shr 0100" "0080"

call %test% "xword.shl"
  call expect "_xword shl 0000" "0000"
  call expect "_xword shl 0001" "0002"
  call expect "_xword shl 4000" "8000"
  call expect "_xword shl 8000" "0000"
  call expect "_xword shl 0080" "0100"

call %test% "xword.fromDec"
  call expect "_xword fromDec 0" "0000"
  call expect "_xword fromDec 1" "0001"
  call expect "_xword fromDec 255" "00FF"
  call expect "_xword fromDec 256" "0100"
  call expect "_xword fromDec 32767" "7FFF"
  call expect "_xword fromDec -1" "FFFF"
  call expect "_xword fromDec -2" "FFFE"
  call expect "_xword fromDec -32768" "8000"
  call expecterr "_xword fromDec 32768" 1
  call expecterr "_xword fromDec -32769" 1

call %test% "xword.toDec"
  call expect "_xword toDec 0000" "0"
  call expect "_xword toDec 0001" "1"
  call expect "_xword toDec 00FF" "255"
  call expect "_xword toDec 7FFF" "32767"
  call expect "_xword toDec FFFF" "-1"
  call expect "_xword toDec FFFE" "-2"
  call expect "_xword toDec 8000" "-32768"

call %test% "xword.neg"
  call expect "_xword neg 0001" "FFFF"
  call expect "_xword neg FFFF" "0001"
  call expect "_xword neg 0000" "0000"
  call expect "_xword neg 8000" "8000"
  call expect "_xword neg 7FFF" "8001"

call %test% "xword.mul"
  call expect "_xword mul 0000 0000" "0000"
  call expect "_xword mul 0001 0001" "0001"
  call expect "_xword mul 0002 0003" "0006"
  call expect "_xword mul 00FF 00FF" "FE01"
  call expect "_xword mul 0100 0100" "0000"
  call expect "_xword mul 000A 000A" "0064"
  call expect "_xword mul 0064 0064" "2710"

call %test% "xword.div"
  call expect "_xword div 0006 0003" "0002"
  call expect "_xword div 0007 0003" "0002"
  call expect "_xword div 0064 000A" "000A"
  call expect "_xword div 0001 0001" "0001"
  call expect "_xword div 0000 0001" "0000"
  call expect "_xword div FFFF 0001" "FFFF"
  call expect "_xword div 2710 0064" "0064"
  call expecterr "_xword div 0001 0000" 11

call %test% "xword.smul"
  call expect "_xword smul 0002 0003" "0006"
  call expect "_xword smul FFFF 0002" "FFFE"
  call expect "_xword smul FFFF FFFF" "0001"
  call expect "_xword smul 000A FFF6" "FF9C"

call %test% "xword.sdiv"
  call expect "_xword sdiv 0006 0003" "0002"
  call expect "_xword sdiv FFFA 0002" "FFFD"
  call expect "_xword sdiv 0007 FFFD" "FFFE"
  call expect "_xword sdiv FFFA FFFE" "0003"
