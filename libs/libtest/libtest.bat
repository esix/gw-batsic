@echo off
  if "%~1"=="" (call :usage) else call :%*
exit /b

:assert.var   VarName  Value  TestName  -- Check variable value
::                                     -- VarName [in]  - Variable name
::                                     -- Value [in]    - Value to compare
  setlocal enableDelayedExpansion
  set "varName=%~1"
  set "var=!%~1!"
  set "expectedValue=%~2"
  set "testName=%~3"
  set "result=0"

  if NOT [!var!]==[!expectedValue!] (
    echo.
    echo TEST !testName!
    echo assertion "var" failed for variable: !varName! 
    echo actual: !var!
    echo expected: !expectedValue!
    echo.
    set "result=1"
  )

  (endlocal & rem -- return values
    exit /b %result%
  )



:test_case_1 function_file function_name val expected_result expected_error
  setlocal enableDelayedExpansion
  set "function_file=%~1"
  set "function_name=%~2"
  set "val=%~3"
  set "expected_result=%~4"
  set "expected_error=%~5"
  set "actual_result="

  call !function_file! !function_name! val actual_result
  set "actual_error=%ERRORLEVEL%"

  if NOT [!expected_error!]==[0] (
    if NOT [!actual_error!]==[!expected_error!] (
      echo.
      echo Failed test     : !function_name! "!val!"
      echo actual result   : !actual_result!
      echo actual error    : !actual_error!
      echo expected error  : !expected_error!
      echo Failed on errorlevel check
      echo.
      exit /b 1
    )
    echo test !function_name! "!val!"... ok
    exit /b 0
  )

  if NOT [!actual_error!]==[0] (
    echo.
    echo Failed test     : !function_name! "!val!"
    echo actual result   : !actual_result!
    echo actual error    : !actual_error!
    echo expected error  : 0
    echo Failed on errorlevel 0 check
    echo.
    exit /b 1
  )

  if NOT [!actual_result!]==[!expected_result!] (
    echo.
    echo Failed test     : !function_name! "!val!"
    echo actual result   : !actual_result!
    echo actual error    : !actual_error!
    echo expected        : !expected_result!
    echo Failed on result check
    echo.
    exit /b 1
  )
  echo test !function_name! "!val!"... ok
  exit /b 0


:test_case_1_res lib_file function_name param expected_result
  setlocal enableDelayedExpansion
  set "lib_file=%~1"
  set "function_name=%~2"
  set "param=%~3"
  set "expected_result=%~4"
  set "actual_result="

  call !lib_file! !function_name! param actual_result
  set "actual_error=%ERRORLEVEL%"

  if NOT [!actual_error!]==[0] (
    echo.
    echo Failed test     : !function_name! "!param!"
    echo actual result   : !actual_result!
    echo actual error    : !actual_error!
    echo expected error  : 0
    echo Failed on errorlevel 0 check
    echo.
    exit /b 1
  )

  if NOT [!actual_result!]==[!expected_result!] (
    echo.
    echo Failed test     : !function_name! "!param!"
    echo actual result   : !actual_result!
    echo expected result : !expected_result!
    echo Failed on result check
    echo.
    exit /b 1
  )
  echo test !function_name! "!param!"... ok
  exit /b 0


:test_case_1_err lib_file function_name param expected_error
  setlocal enableDelayedExpansion
  set "lib_file=%~1"
  set "function_name=%~2"
  set "param=%~3"
  set "expected_error=%~4"
  set "actual_result="

  call !lib_file! !function_name! param actual_result
  set "actual_error=%ERRORLEVEL%"

  if NOT [!actual_error!]==[!expected_error!] (
    echo.
    echo Failed test     : !function_name! "!param!"
    echo actual error    : !actual_error!
    echo expected error  : !expected_error!
    echo Failed on errorlevel check
    echo.
    exit /b 1
  )

  echo test !function_name! "!param!"... ok
  exit /b 0
