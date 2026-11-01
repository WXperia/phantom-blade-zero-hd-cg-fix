@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Manage.ps1" -Action Install
if errorlevel 1 echo Installation failed. See the message above.
pause
