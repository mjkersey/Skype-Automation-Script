@echo off
cls

reg delete HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v SkypeAutoAnswer /f
wscript.exe .\killall.vbs

echo.

echo Killed SkypeAutoAnswer processes and removed startup entries from registry.
echo You may delete this folder now.

echo.

pause