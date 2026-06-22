@echo off
@REM LINE INPUT [#n,] var$ : read an ENTIRE line (no comma split, no quote
@REM handling) into one string variable.  Console reads stdin; with _input_fh
@REM set (LINE INPUT #n) it reads the next line from the file channel.
@REM The prompt, if any, was already printed by @PROMPT.  Error 62 at EOF.
setlocal EnableDelayedExpansion
set "_s=%~1"
call %GWSRC%\stl\vec pop %_s% _var
set "_ph="
set "_e=0"
if defined _input_fh goto :_li_file
set "_line="
set /p "_line="
call %GWSRC%\str\str encodeRaw "!_line!" _ph
goto :_li_assign
:_li_file
call %GWSRC%\exec\_files readseq !_input_fh! _lh _feof
if "!_feof!"=="1" (set "_e=62" & goto :_li_end)
set "_ph=!_lh!"
:_li_assign
call %GWSRC%\exec\_vars set !_var! STR_!_ph!
:_li_end
set "_final=!%_s%!"
endlocal & set "%~1=%_final%" & set "_input_fh=" & set "_input_prompted=" & exit /B %_e%
