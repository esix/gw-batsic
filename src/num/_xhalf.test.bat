
echo xhalf test

call %test% "xhalf.check"
  call expect "_xhalf check 0" "1"
  call %expect% "_xhalf check 1" "1"
  call %expect% "_xhalf check 2" "1"
