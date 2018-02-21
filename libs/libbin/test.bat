@echo off

:: dependencies
if [%libtest%]==[] (
  for %%i in ("%~dp0..\libtest\libtest.bat") do set "libtest=%%~fi"
)
if [%libbin%]==[] (
  for %%i in ("%~dp0libbin.bat") do set "libbin=%%~fi"
)

setlocal enableDelayedExpansion

echo.
echo Should convert one-byte integer to hex
call !libtest! test_case_1_res !libbin! x8  "0"              "00"    || exit /b
call !libtest! test_case_1_res !libbin! x8  "1"              "01"    || exit /b
call !libtest! test_case_1_res !libbin! x8  "2"              "02"    || exit /b
call !libtest! test_case_1_res !libbin! x8  "10"             "0A"    || exit /b
call !libtest! test_case_1_res !libbin! x8  "+10"            "0A"    || exit /b
call !libtest! test_case_1_res !libbin! x8  "127"            "7F"    || exit /b
call !libtest! test_case_1_res !libbin! x8  "128"            "80"    || exit /b
call !libtest! test_case_1_res !libbin! x8  "-128"           "80"    || exit /b
call !libtest! test_case_1_res !libbin! x8  "-127"           "81"    || exit /b
call !libtest! test_case_1_res !libbin! x8  "-1"             "FF"    || exit /b
call !libtest! test_case_1_res !libbin! x8  "255"            "FF"    || exit /b
call !libtest! test_case_1_err !libbin! x8  "256"            1       || exit /b
call !libtest! test_case_1_err !libbin! x8  "9999999999999"  1       || exit /b
call !libtest! test_case_1_err !libbin! x8  "-999999999999"  1       || exit /b
call !libtest! test_case_1_err !libbin! x8  "foo"            2       || exit /b
call !libtest! test_case_1_err !libbin! x8  ""               2       || exit /b

echo.
echo Should convert two-bytes integer to hex
call !libtest! test_case_1_res !libbin! x16 "0"              "0000"  || exit /b
call !libtest! test_case_1_res !libbin! x16 "1"              "0001"  || exit /b
call !libtest! test_case_1_res !libbin! x16 "2"              "0002"  || exit /b
call !libtest! test_case_1_res !libbin! x16 "10"             "000A"  || exit /b
call !libtest! test_case_1_res !libbin! x16 "+10"            "000A"  || exit /b
call !libtest! test_case_1_res !libbin! x16 "127"            "007F"  || exit /b
call !libtest! test_case_1_res !libbin! x16 "128"            "0080"  || exit /b
call !libtest! test_case_1_res !libbin! x16 "-128"           "FF80"  || exit /b
call !libtest! test_case_1_res !libbin! x16 "-127"           "FF81"  || exit /b
call !libtest! test_case_1_res !libbin! x16 "-1"             "FFFF"  || exit /b
call !libtest! test_case_1_res !libbin! x16 "255"            "00FF"  || exit /b
call !libtest! test_case_1_res !libbin! x16 "32767"          "7FFF"  || exit /b
call !libtest! test_case_1_res !libbin! x16 "32768"          "8000"  || exit /b
call !libtest! test_case_1_res !libbin! x16 "-32768"         "8000"  || exit /b
call !libtest! test_case_1_err !libbin! x16 "65536"          1       || exit /b
call !libtest! test_case_1_err !libbin! x16 "9999999999999"  1       || exit /b
call !libtest! test_case_1_err !libbin! x16 "-999999999999"  1       || exit /b
call !libtest! test_case_1_err !libbin! x16 "foo"            2       || exit /b
call !libtest! test_case_1_err !libbin! x16 ""               2       || exit /b

endlocal
