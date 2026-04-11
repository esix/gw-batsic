
call %test% "mbfd.neg"
  call expect "_mbfd neg 0000000000000000" "0000000000000000"
  call expect "_mbfd neg 8000000000000000" "8080000000000000"
  call expect "_mbfd neg 8080000000000000" "8000000000000000"

call %test% "mbfd.abs"
  call expect "_mbfd abs 8080000000000000" "8000000000000000"
  call expect "_mbfd abs 8000000000000000" "8000000000000000"

call %test% "mbfd.fromInt"
  call expect "_mbfd fromInt 0000" "0000000000000000"
  call expect "_mbfd fromInt 0001" "8000000000000000"
  call expect "_mbfd fromInt 0002" "8100000000000000"
  call expect "_mbfd fromInt 000A" "8320000000000000"
  call expect "_mbfd fromInt FFFF" "8080000000000000"

call %test% "mbfd.toInt"
  call expect "_mbfd toInt 0000000000000000" "0000"
  call expect "_mbfd toInt 8000000000000000" "0001"
  call expect "_mbfd toInt 8100000000000000" "0002"
  call expect "_mbfd toInt 8320000000000000" "000A"
  call expect "_mbfd toInt 8080000000000000" "FFFF"

call %test% "mbfd.cmp"
  call expect "_mbfd cmp 0000000000000000 0000000000000000" "0"
  call expect "_mbfd cmp 8100000000000000 8000000000000000" "1"
  call expect "_mbfd cmp 8000000000000000 8100000000000000" "2"

call %test% "mbfd.add"
  call expect "_mbfd add 0000000000000000 8000000000000000" "8000000000000000"
  call expect "_mbfd add 8000000000000000 8000000000000000" "8100000000000000"
  call expect "_mbfd add 8000000000000000 8080000000000000" "0000000000000000"

call %test% "mbfd.sub"
  call expect "_mbfd sub 8140000000000000 8000000000000000" "8100000000000000"
  call expect "_mbfd sub 8000000000000000 8000000000000000" "0000000000000000"

call %test% "mbfd.mul"
  call expect "_mbfd mul 0000000000000000 8000000000000000" "0000000000000000"
  call expect "_mbfd mul 8000000000000000 8000000000000000" "8000000000000000"
  call expect "_mbfd mul 8100000000000000 8140000000000000" "8240000000000000"
  call expect "_mbfd mul 8320000000000000 8320000000000000" "8648000000000000"

call %test% "mbfd.div"
  call expect "_mbfd div 8000000000000000 8000000000000000" "8000000000000000"
  call expect "_mbfd div 8240000000000000 8140000000000000" "8100000000000000"
  call expect "_mbfd div 8240000000000000 8100000000000000" "8140000000000000"
  call expecterr "_mbfd div 8000000000000000 0000000000000000" 11

call %test% "mbfd.fromDec"
  call expect "_mbfd fromDec 0" "0000000000000000"
  call expect "_mbfd fromDec 1" "8000000000000000"
  call expect "_mbfd fromDec 10" "8320000000000000"
  call expect "_mbfd fromDec -1" "8080000000000000"
  call expect "_mbfd fromDec 0.5" "7F00000000000000"

call %test% "mbfd.toDec"
  call expect "_mbfd toDec 0000000000000000" "0"
  call expect "_mbfd toDec 8000000000000000" "1"
  call expect "_mbfd toDec 8080000000000000" "-1"
  call expect "_mbfd toDec 8100000000000000" "2"
