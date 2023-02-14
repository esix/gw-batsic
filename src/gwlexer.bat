@echo off
shift & goto :%~1

:ParseTxt ret file
  echo "line=%~2"

exit /b