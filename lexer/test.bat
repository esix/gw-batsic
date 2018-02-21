@echo off

:: dependencies
if [%libtest%]==[] (
  for %%i in ("%~dp0..\libs\libtest\libtest.bat") do set "libtest=%%~fi"
)
if [%lexer%]==[] (
  for %%i in ("%~dp0lexer.bat") do set "lexer=%%~fi"
)


setlocal enableDelayedExpansion
echo Should tokenize simple lines

call !libtest! test_case_1_res !lexer! tokenize "0"         "I16_0000"        || exit /b 1
call !libtest! test_case_1_res !lexer! tokenize "16"        "I16_0010"        || exit /b 1
call !libtest! test_case_1_res !lexer! tokenize "32767"     "I16_0010"        || exit /b 1
call !libtest! test_case_1_res !lexer! tokenize "+"         "PLUS"            || exit /b 1
call !libtest! test_case_1_res !lexer! tokenize ""Hello""   "STR_48656C6C6F"  || exit /b 1
call !libtest! test_case_1_res !lexer! tokenize "*"         "STR_48656C6C6F"  || exit /b 1
rem strange feature of basic lexer: it ignores spaces in numbers
call !libtest! test_case_1_res !lexer! tokenize "1 2   3"   "I16_123"         || exit /b 1
call !libtest! test_case_1_res !lexer! tokenize ">   ="     "GEQU"            || exit /b 1

endlocal
exit /b 0
