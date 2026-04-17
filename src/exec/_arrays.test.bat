@REM Array storage tests

call %test% "_arrays.init.empty"
  call %GWSRC%\exec\_arrays init
  call expect "%GWSRC%\exec\_arrays exists ARR_UNK_A __" ""

call %test% "_arrays.dim.1d"
  call %GWSRC%\exec\_arrays init
  call %GWSRC%\exec\_arrays dim ARR_UNK_A 3
  call expect "%GWSRC%\exec\_arrays exists ARR_UNK_A __" "1"

call %test% "_arrays.dim.duplicate"
  call %GWSRC%\exec\_arrays init
  call %GWSRC%\exec\_arrays dim ARR_UNK_A 3
  call expecterr "%GWSRC%\exec\_arrays dim ARR_UNK_A 5" 10

call %test% "_arrays.typeof"
  call %GWSRC%\exec\_vars init
  call expect "%GWSRC%\exec\_arrays typeof ARR_INT_A __" "i"
  call expect "%GWSRC%\exec\_arrays typeof ARR_SNG_A __" "s"
  call expect "%GWSRC%\exec\_arrays typeof ARR_DBL_A __" "d"
  call expect "%GWSRC%\exec\_arrays typeof ARR_STR_A __" "t"
  call expect "%GWSRC%\exec\_arrays typeof ARR_UNK_A __" "s"

call %test% "_arrays.set.get.1d"
  call %GWSRC%\exec\_arrays init
  call %GWSRC%\exec\_arrays dim ARR_INT_A 5
  call %GWSRC%\exec\_arrays set ARR_INT_A 2 i002A
  call expect "%GWSRC%\exec\_arrays get ARR_INT_A 2 __" "i002A"

call %test% "_arrays.set.get.2d"
  call %GWSRC%\exec\_arrays init
  call %GWSRC%\exec\_arrays dim ARR_INT_B 2 3
  call %GWSRC%\exec\_arrays set ARR_INT_B 1 2 i0037
  call expect "%GWSRC%\exec\_arrays get ARR_INT_B 1 2 __" "i0037"
  call expect "%GWSRC%\exec\_arrays get ARR_INT_B 0 0 __" "i0000"

call %test% "_arrays.get.outOfRange"
  call %GWSRC%\exec\_arrays init
  call %GWSRC%\exec\_arrays dim ARR_INT_A 3
  call expecterr "%GWSRC%\exec\_arrays get ARR_INT_A 10 __" 9

call %test% "_arrays.get.negativeIdx"
  call %GWSRC%\exec\_arrays init
  call %GWSRC%\exec\_arrays dim ARR_INT_A 3
  call expecterr "%GWSRC%\exec\_arrays get ARR_INT_A -1 __" 5

call %test% "_arrays.unk.canonicalizes"
  @REM ARR_UNK_X (with default single) should be the same array as ARR_SNG_X
  call %GWSRC%\exec\_vars init
  call %GWSRC%\exec\_arrays init
  call %GWSRC%\exec\_arrays dim ARR_UNK_A 3
  call %GWSRC%\exec\_arrays set ARR_SNG_A 1 s80000000
  call expect "%GWSRC%\exec\_arrays get ARR_UNK_A 1 __" "s80000000"

exit /B
