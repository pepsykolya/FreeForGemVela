@echo off
rem FreeForGemVela (ffgv): start start.bat (this folder) automatically when you log on to Windows.
rem Creates a Task Scheduler task: at your logon (+DELAY s), in a visible window on your desktop, with the highest
rem privileges (MODE / AUTO_UV / LOCK_* work without a UAC prompt), also on battery. Run it again after moving the
rem folder. Undo: remove-autostart.bat. Needs Administrator once: Windows asks for it.
cd /d "%~dp0"
rem task name in Task Scheduler (letters, digits, space, _ - .)
set TASK=FreeForGemVela
rem seconds after logon before the miner starts (lets the driver and network come up), 0 = at once
set DELAY=30
rem 1 = do not start when the laptop runs on battery (a running miner keeps running when the cable is pulled)
set AC_ONLY=

rem the user who logs on = who ran this file (an Administrator prompt may run us as another account)
set FFGV_USER=%~1
if "%FFGV_USER%"=="" set FFGV_USER=%USERDOMAIN%\%USERNAME%
rem relaunched by the prompt below: go on (ffgv checks the rights itself; no second prompt)
if not "%~1"=="" goto admin
net session >nul 2>&1
if not errorlevel 1 goto admin
echo Creating the autostart task needs Administrator rights; asking Windows...
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '\"%FFGV_USER%\"' -Verb RunAs" >nul 2>&1 && exit /b
echo Not elevated. Right-click install-autostart.bat, Run as administrator.
pause
exit /b 1

:admin
set ARGS=--install-autostart --task-name "%TASK%" --autostart-delay %DELAY% --task-user "%FFGV_USER%" --autostart-bat "%~dp0start.bat"
if "%AC_ONLY%"=="1" set ARGS=%ARGS% --autostart-ac-only
"%~dp0ffgv.exe" %ARGS%
pause
