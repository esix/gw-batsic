
call %test% "int.fromDec"
  call expect "int fromDec 0" "i0000"
  call expect "int fromDec 1" "i0001"
  call expect "int fromDec 32767" "i7FFF"
  call expect "int fromDec -1" "iFFFF"
  call expect "int fromDec -32768" "i8000"
  call expecterr "int fromDec 32768" 1
  call expecterr "int fromDec -32769" 1

call %test% "int.toDec"
  call expect "int toDec i0000" "0"
  call expect "int toDec i0001" "1"
  call expect "int toDec i7FFF" "32767"
  call expect "int toDec iFFFF" "-1"
  call expect "int toDec i8000" "-32768"

call %test% "int.toDec.typeCheck"
  call expecterr "int toDec 0000" 13
  call expecterr "int toDec s00000000" 13

call %test% "int.add"
  call expect "int add i0001 i0002" "i0003"
  call expect "int add i7FFF i0001" "i8000"

call %test% "int.add.typeCheck"
  call expecterr "int add 0001 i0002" 13
  call expecterr "int add i0001 0002" 13

call %test% "int.sub"
  call expect "int sub i0005 i0003" "i0002"
  call expect "int sub i0000 i0001" "iFFFF"

call %test% "int.mul"
  call expect "int mul i0003 i0004" "i000C"
  call expect "int mul iFFFF i0002" "iFFFE"
  call expect "int mul iFFFF iFFFF" "i0001"

call %test% "int.div"
  call expect "int div i0007 i0002" "i0003"
  call expecterr "int div i0001 i0000" 11

call %test% "int.neg"
  call expect "int neg i0001" "iFFFF"
  call expect "int neg iFFFF" "i0001"
  call expect "int neg i0000" "i0000"

call %test% "int.inv"
  call expect "int inv i0000" "iFFFF"
  call expect "int inv iFFFF" "i0000"
  call expect "int inv i00FF" "iFF00"

call %test% "int.bitwise"
  call expect "int and iFFFF i00FF" "i00FF"
  call expect "int or i00F0 i000F" "i00FF"
  call expect "int xor iFFFF iFFFF" "i0000"

call %test% "int.typeCheck"
  call expecterr "int neg 0001" 13
  call expecterr "int inv s00000000" 13
  call expecterr "int and iFFFF 00FF" 13
  call expecterr "int or 00F0 i000F" 13
