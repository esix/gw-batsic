
call %test% "vec.push"
  set "_v="
  call vec push _v X
  call vec push _v Y
  call vec push _v Z
  call expect "vec size _v __" "3"
  call expecterr "vec includes _v X" 0
  call expecterr "vec includes _v Y" 0
  call expecterr "vec includes _v Z" 0

call %test% "vec.front"
  set "_v=A B C"
  call expect "vec front _v __" "A"

call %test% "vec.shift"
  set "_v=A B C"
  call vec shift _v
  call expect "vec front _v __" "B"
  call vec shift _v
  call expect "vec front _v __" "C"
  call vec shift _v
  call expect "vec size _v __" "0"

call %test% "vec.back"
  set "_v=A B C"
  call expect "vec back _v __" "C"
  set "_v=X"
  call expect "vec back _v __" "X"

call %test% "vec.pop"
  set "_v=A B C"
  call expect "vec pop _v __" "C"
  call expect "vec pop _v __" "B"
  call expect "vec pop _v __" "A"
  call expect "vec size _v __" "0"

call %test% "vec.stack"
  @REM push/pop as LIFO stack
  set "_v="
  call vec push _v X
  call vec push _v Y
  call vec push _v Z
  call expect "vec pop _v __" "Z"
  call expect "vec pop _v __" "Y"
  call expect "vec pop _v __" "X"

call %test% "vec.includes"
  set "_v=A B C"
  call expecterr "vec includes _v A" 0
  call expecterr "vec includes _v C" 0
  call expecterr "vec includes _v D" 1

call %test% "vec.push_uniq"
  set "_v="
  call vec push_uniq _v A
  call vec push_uniq _v B
  call expecterr "vec push_uniq _v A" 1
  call expect "vec size _v __" "2"
  call expecterr "vec includes _v A" 0
  call expecterr "vec includes _v B" 0

call %test% "vec.size"
  set "_v=A B C"
  call expect "vec size _v __" "3"
  set "_v="
  call expect "vec size _v __" "0"

call %test% "vec.clear"
  set "_v=A B C"
  call vec clear _v
  call expect "vec size _v __" "0"
