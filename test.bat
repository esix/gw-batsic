@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start

:_start
  setlocal EnableDelayedExpansion
  set PATH=%~dp0\src;%~dp0\tests;%PATH%

  set numTests=0
  set passedTests=0
  set failedTests=0


  for /f %%f in ('dir /A-D /S /B *.test.bat') do (
    call:runTest %%f
  )

  echo Total tests: %numTests%
  echo      FAILED: %failedTests%
  echo      PASSED: %passedTests%

  endlocal
exit /B


:runTest testFile
  set "testFile=%~1"
  set "testPath=%~dp1"
  set "test=%~dp0tests\testDeclaration.bat"
  set "expect=%~dp0tests\expect.bat"

  pushd "%testPath%"
  echo Testing %testFile%
  call %testFile%
  popd
exit /B
