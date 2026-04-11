
call %test% "xbyte.check"
  call expecterr "_xbyte check 00" 0
  call expecterr "_xbyte check FF" 0
  call expecterr "_xbyte check A3" 0
  call expecterr "_xbyte check 0" 1
  call expecterr "_xbyte check 000" 1
  call expecterr "_xbyte check GG" 1

call %test% "xbyte.inc"
  call expect "_xbyte inc 00" "01"
  call expect "_xbyte inc 0F" "10"
  call expect "_xbyte inc 09" "0A"
  call expect "_xbyte inc FE" "FF"
  call expect "_xbyte inc FF" "00"

call %test% "xbyte.dec"
  call expect "_xbyte dec 01" "00"
  call expect "_xbyte dec 10" "0F"
  call expect "_xbyte dec 00" "FF"
  call expect "_xbyte dec FF" "FE"

call %test% "xbyte.add"
  call expect "_xbyte add 00 00" "00"
  call expect "_xbyte add 01 01" "02"
  call expect "_xbyte add 0F 01" "10"
  call expect "_xbyte add FF 01" "00"
  call expect "_xbyte add 80 80" "00"
  call expect "_xbyte add 12 34" "46"
  call expect "_xbyte add AB CD" "78"

call %test% "xbyte.sub"
  call expect "_xbyte sub 00 00" "00"
  call expect "_xbyte sub 10 01" "0F"
  call expect "_xbyte sub FF 01" "FE"
  call expect "_xbyte sub 00 01" "FF"
  call expect "_xbyte sub 46 34" "12"

call %test% "xbyte.mul"
  call expect "_xbyte mul 00 00" "00"
  call expect "_xbyte mul 01 01" "01"
  call expect "_xbyte mul 02 03" "06"
  call expect "_xbyte mul 10 10" "00"
  call expect "_xbyte mul 0F 0F" "E1"
  call expect "_xbyte mul 12 02" "24"

call %test% "xbyte.inv"
  call expect "_xbyte inv 00" "FF"
  call expect "_xbyte inv FF" "00"
  call expect "_xbyte inv A5" "5A"
  call expect "_xbyte inv 0F" "F0"

call %test% "xbyte.and"
  call expect "_xbyte and FF FF" "FF"
  call expect "_xbyte and FF 00" "00"
  call expect "_xbyte and A5 5A" "00"
  call expect "_xbyte and CF 3F" "0F"

call %test% "xbyte.or"
  call expect "_xbyte or 00 00" "00"
  call expect "_xbyte or A5 5A" "FF"
  call expect "_xbyte or C0 0F" "CF"

call %test% "xbyte.xor"
  call expect "_xbyte xor 00 00" "00"
  call expect "_xbyte xor FF FF" "00"
  call expect "_xbyte xor A5 5A" "FF"
  call expect "_xbyte xor FF 00" "FF"

call %test% "xbyte.shr"
  call expect "_xbyte shr 00" "00"
  call expect "_xbyte shr 01" "00"
  call expect "_xbyte shr 02" "01"
  call expect "_xbyte shr 80" "40"
  call expect "_xbyte shr FF" "7F"
  call expect "_xbyte shr 10" "08"

call %test% "xbyte.shl"
  call expect "_xbyte shl 00" "00"
  call expect "_xbyte shl 01" "02"
  call expect "_xbyte shl 40" "80"
  call expect "_xbyte shl 80" "00"
  call expect "_xbyte shl FF" "FE"
  call expect "_xbyte shl 08" "10"
