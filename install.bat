@echo off
cls

SET sourcedir=%~dp0

powershell $PSVersionTable.PSVersion > NUL
if %ERRORLEVEL% EQU 0 goto :unblock

echo Error! Powershell is either broken or missing.
echo Error! You'll have to manually unblock the following files:
echo.
echo nircmd.exe
echo nircmdc.exe
echo NirCmd.chm
echo.
echo If you don't, you'll get a signature warning when the script tries
echo to call them!

:unblock

REM Unblock all files so they don't prompt to run in the middle of the script
powershell Unblock-File *.*

:startup
set /p startthething=Add to startup [this user only] (Y/n)?
if [%startthething%] EQU [n] goto :run
reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v SkypeAutoAnswer /t REG_SZ /d "wscript.exe \"%sourcedir%SkypeAutoAnswer.vbs\"" /f

:run

set /p dothething=Run now (Y/n)?
if [%dothething%] EQU [n] echo natch
wscript.exe .\SkypeAutoAnswer.vbs

echo Running! Switch to Skype and give the script access to skype.
echo There's a big bar at the top of the Skype window asking for confirmation.

pause