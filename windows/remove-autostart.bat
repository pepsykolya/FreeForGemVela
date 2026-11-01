@echo off
rem FreeForGemVela (ffgv): remove the autostart task made by install-autostart.bat (a miner window that is open
rem keeps running; close it yourself). Only a task created by ffgv is removed. Needs Administrator: Windows asks.
cd /d "%~dp0"
rem the same name as in install-autostart.bat
set TASK=FreeForGemVela

if "%~1"=="elevated" goto admin
net session >nul 2>&1
if not errorlevel 1 goto admin
echo Removing the autostart task needs Administrator rights; asking Windows...
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList elevated -Verb RunAs" >nul 2>&1 && exit /b
echo Not elevated. Right-click remove-autostart.bat, Run as administrator.
pause
exit /b 1

:admin
"%~dp0ffgv.exe" --remove-autostart --task-name "%TASK%"
pause
