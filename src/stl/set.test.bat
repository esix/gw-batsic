
call %test% "set.add"
  set "_s="
  call set add _s A
  call set add _s B
  call set add _s C
  call expect "set size _s __" "3"
  call expecterr "set has _s A" 0
  call expecterr "set has _s B" 0
  call expecterr "set has _s C" 0

call %test% "set.add.noDup"
  set "_s=A B"
  call expecterr "set add _s A" 1
  call expecterr "set add _s B" 1
  call set add _s C
  call expect "set size _s __" "3"

call %test% "set.has"
  set "_s=A B C"
  call expecterr "set has _s A" 0
  call expecterr "set has _s C" 0
  call expecterr "set has _s D" 1
  set "_s="
  call expecterr "set has _s A" 1

call %test% "set.remove"
  set "_s=A B C"
  call set remove _s B
  call expect "set size _s __" "2"
  call expecterr "set has _s A" 0
  call expecterr "set has _s C" 0
  call expecterr "set has _s B" 1
  call set remove _s A
  call set remove _s C
  call expect "set size _s __" "0"
  set "_s=X Y"
  call expecterr "set remove _s Z" 1

call %test% "set.size"
  set "_s=A B C"
  call expect "set size _s __" "3"
  set "_s="
  call expect "set size _s __" "0"

call %test% "set.clear"
  set "_s=A B C"
  call set clear _s
  call expect "set size _s __" "0"

call %test% "set.union"
  set "_a=A B C"
  set "_b=B C D"
  call set union _a _b _r
  call expect "set size _r __" "4"
  call expecterr "set has _r A" 0
  call expecterr "set has _r B" 0
  call expecterr "set has _r C" 0
  call expecterr "set has _r D" 0

call %test% "set.intersect"
  set "_a=A B C"
  set "_b=B C D"
  call set intersect _a _b _r
  call expect "set size _r __" "2"
  call expecterr "set has _r B" 0
  call expecterr "set has _r C" 0
  call expecterr "set has _r A" 1

call %test% "set.diff"
  set "_a=A B C"
  set "_b=B C D"
  call set diff _a _b _r
  call expect "set size _r __" "1"
  call expecterr "set has _r A" 0
  call expecterr "set has _r B" 1

call %test% "set.equal"
  set "_a=A B C"
  set "_b=C A B"
  call expecterr "set equal _a _b" 0
  set "_b=A B"
  call expecterr "set equal _a _b" 1
  set "_b=A B C D"
  call expecterr "set equal _a _b" 1
