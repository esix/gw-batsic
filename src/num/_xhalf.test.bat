
call %test% "xhalf.check"
  call expecterr "_xhalf check 0" 0
  call expecterr "_xhalf check 1" 0
  call expecterr "_xhalf check 2" 0
  call expecterr "_xhalf check 1" 0
  call expecterr "_xhalf check 2" 0
  call expecterr "_xhalf check 9" 0
  call expecterr "_xhalf check A" 0
  call expecterr "_xhalf check B" 0
  call expecterr "_xhalf check F" 0
  call expecterr "_xhalf check a" 1
  call expecterr "_xhalf check b" 1
  call expecterr "_xhalf check f" 1
  call expecterr "_xhalf check g" 1
  call expecterr "_xhalf check G" 1
  call expecterr "_xhalf check :" 1
  call expecterr "_xhalf check" 1
  call expecterr "_xhalf check 00" 1
  call expecterr "_xhalf check ^"  1

