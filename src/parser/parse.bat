@echo off
setlocal EnableDelayedExpansion

set "tokens=%~1 EOL"
echo "Parser: tokens=!tokens!"

set stack="$ E"


exit /b