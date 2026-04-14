
call %test% "str.ch2hex"
  call expect "str ch2hex A __" "41"
  call expect "str ch2hex Z __" "5A"
  call expect "str ch2hex 0 __" "30"
  call expect "str ch2hex 9 __" "39"
  call expect "str ch2hex + __" "2B"
  @REM Note: ch2hex for lowercase letters may not work reliably
  @REM due to batch case-insensitive var names. Use encode instead.

call %test% "str.hex2ch"
  call expect "str hex2ch 41 __" "A"
  call expect "str hex2ch 5A __" "Z"
  call expect "str hex2ch 61 __" "a"
  call expect "str hex2ch 30 __" "0"
  call expect "str hex2ch 20 __" " "

call %test% "str.encode"
  call expect "str encode HELLO __" "48454C4C4F"
  call expect "str encode AB __" "4142"
  call expect "str encode 123 __" "313233"
  call expect "str encode A+B __" "412B42"

call %test% "str.decode"
  call expect "str decode 48454C4C4F __" "HELLO"
  call expect "str decode 68656C6C6F __" "hello"
  call expect "str decode 4142 __" "AB"
  call expect "str decode 313233 __" "123"

call %test% "str.roundtrip"
  @REM encode -> decode roundtrips to uppercase (expected for GW-BASIC)
  call str encode "HELLO" _h
  call expect "str decode %_h% __" "HELLO"
  call str encode "1+2*3" _h
  call expect "str decode %_h% __" "1+2*3"
