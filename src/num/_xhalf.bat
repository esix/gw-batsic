@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start

:check v
    echo "check@xhalf.bat"
exit /B



:_start
echo _start@xhalf.bat
