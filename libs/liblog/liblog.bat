@echo off
  if "%~1"=="" (call :usage) else call :%*
exit /b

:usage                             -- Library syntax and general info
::
::  LogLib.bat is a callable library of logging functions used to debug
::
::  syntax:
::
::    [call] [path]LogLib module logType [arguments]
::
::  logType:
::    debug, info, warn. error
::    all for any of these types
::
:: To customize log for each module, define variable DEBUG_module with values like
::
::  DEBUG_module="all"
::  DEBUG_module="error,warn,info"
::
::  DEBUG_module="info=>log_info.txt,info=>log_info2.txt,info"
::  - info messages would go to files log_info.txt, log_info2.txt and screen
::
::  DEBUG_module="all" 
::  - all messages will be put on screen
  call :help Usage
exit /b

