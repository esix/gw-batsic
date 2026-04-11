@echo off
setlocal EnableDelayedExpansion
set "root=%~dp0"
set "PATH=%root%src;%root%tests;%PATH%"
set "test=%root%tests\testDeclaration.bat"
set "expect=%root%tests\expect.bat"

set numTests=0
set passedTests=0
set failedTests=0

@REM Optional arg: module name (directory under src/)
@REM   test.bat         -> run all modules under src/
@REM   test.bat num     -> run only src/num/
set "module=%~1"

if "%module%" neq "" (
  call :runModule "%root%src\%module%"
) else (
  for /D %%d in ("%root%src\*") do call :runModule "%%d"
)

echo.
echo Total tests: !numTests!
echo      FAILED: !failedTests!
echo      PASSED: !passedTests!

endlocal & exit /B %failedTests%


:runModule
  set "_dir=%~1"
  if not exist "%_dir%" (
    echo Module not found: %_dir%
    exit /B 1
  )
  set "PATH=%_dir%;%PATH%"
  pushd "%_dir%"
  @REM If module has its own test.bat, use it
  if exist "test.bat" (
    echo Testing %_dir%\test.bat
    call test.bat
    popd
    exit /B
  )
  @REM Otherwise auto-discover *.test.bat in this dir and subdirs
  for /f %%f in ('dir /A-D /S /B "%_dir%\*.test.bat" 2^>nul') do (
    set "PATH=%%~dpf;%PATH%"
    echo Testing %%f
    call "%%f"
  )
  popd
  exit /B
