
call %test% "xhalf.check"
  call expecterr "_xhalf check 0" 0
  call expecterr "_xhalf check 1" 0
  call expecterr "_xhalf check 9" 0
  call expecterr "_xhalf check A" 0
  call expecterr "_xhalf check F" 0
  call expecterr "_xhalf check a" 1
  call expecterr "_xhalf check G" 1
  call expecterr "_xhalf check :" 1
  call expecterr "_xhalf check" 1
  call expecterr "_xhalf check 00" 1

call %test% "xhalf.serialize"
  call expect "_xhalf serialize 0 __" "0"
  call expect "_xhalf serialize 9 __" "9"
  call expect "_xhalf serialize A __" "10"
  call expect "_xhalf serialize F __" "15"

call %test% "xhalf.parse"
  call expect "_xhalf parse 0 __" "0"
  call expect "_xhalf parse 9 __" "9"
  call expect "_xhalf parse 10 __" "A"
  call expect "_xhalf parse 15 __" "F"

call %test% "xhalf.inc"
  call expect "_xhalf inc 0" "1"
  call expect "_xhalf inc 1" "2"
  call expect "_xhalf inc 9" "A"
  call expect "_xhalf inc E" "F"
  call expect "_xhalf inc F" "0"

call %test% "xhalf.dec"
  call expect "_xhalf dec F" "E"
  call expect "_xhalf dec A" "9"
  call expect "_xhalf dec 1" "0"
  call expect "_xhalf dec 0" "F"

call %test% "xhalf.add"
  call expect "_xhalf add 0 0" "0"
  call expect "_xhalf add 1 2" "3"
  call expect "_xhalf add 7 8" "F"
  call expect "_xhalf add 8 8" "0"
  call expect "_xhalf add F 1" "0"
  call expect "_xhalf add F F" "E"

call %test% "xhalf.sub"
  call expect "_xhalf sub 0 0" "0"
  call expect "_xhalf sub 5 3" "2"
  call expect "_xhalf sub F 1" "E"
  call expect "_xhalf sub 0 1" "F"
  call expect "_xhalf sub 3 5" "E"

call %test% "xhalf.mul"
  call expect "_xhalf mul 0 0" "00"
  call expect "_xhalf mul 1 1" "01"
  call expect "_xhalf mul 2 3" "06"
  call expect "_xhalf mul F F" "E1"
  call expect "_xhalf mul 8 2" "10"

call %test% "xhalf.inv"
  call expect "_xhalf inv 0" "F"
  call expect "_xhalf inv F" "0"
  call expect "_xhalf inv 5" "A"
  call expect "_xhalf inv A" "5"

call %test% "xhalf.and"
  call expect "_xhalf and F F" "F"
  call expect "_xhalf and F 0" "0"
  call expect "_xhalf and A 5" "0"
  call expect "_xhalf and C 6" "4"

call %test% "xhalf.or"
  call expect "_xhalf or 0 0" "0"
  call expect "_xhalf or F 0" "F"
  call expect "_xhalf or A 5" "F"
  call expect "_xhalf or C 6" "E"

call %test% "xhalf.xor"
  call expect "_xhalf xor 0 0" "0"
  call expect "_xhalf xor F F" "0"
  call expect "_xhalf xor A 5" "F"
  call expect "_xhalf xor C 6" "A"

call %test% "xhalf.shr"
  call expect "_xhalf shr 0" "0"
  call expect "_xhalf shr 1" "0"
  call expect "_xhalf shr 2" "1"
  call expect "_xhalf shr 8" "4"
  call expect "_xhalf shr F" "7"

call %test% "xhalf.shl"
  call expect "_xhalf shl 0" "0"
  call expect "_xhalf shl 1" "2"
  call expect "_xhalf shl 4" "8"
  call expect "_xhalf shl 7" "E"
  call expect "_xhalf shl 8" "0"
