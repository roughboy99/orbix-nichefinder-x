@echo off
title Orbix NicheFinder X - Installer v1.07
color 0B

echo.
echo  ============================================================
echo   ORBIX NicheFinder X  v1.07  ^|  Windows Installer
echo   Orbix Automation Solutions  ^|  getorbix.com
echo  ============================================================
echo.
echo  Choose your installation method:
echo.
echo    [1]  npm  (RECOMMENDED - one command, automatic updates)
echo         Requires Node.js 18+
echo         Install: npm install -g orbix-nichefinder-x
echo         Run:     nichefinder
echo.
echo    [2]  Full Installer (PowerShell - all steps automated)
echo         Installs Node.js if missing, creates Desktop shortcut
echo.
echo    [3]  Exit
echo.

set /p CHOICE="  Enter 1, 2 or 3: "

if "%CHOICE%"=="1" goto NPM_INSTALL
if "%CHOICE%"=="2" goto FULL_INSTALL
if "%CHOICE%"=="3" goto END
echo  Invalid choice. Please run again and enter 1, 2 or 3.
pause
exit /b 1

:NPM_INSTALL
echo.
echo  ============================================================
echo   Installing via npm...
echo  ============================================================
echo.
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo  [!!] Node.js not found.
    echo       Download from: https://nodejs.org
    echo       Install Node.js 18 LTS, then run this installer again.
    echo.
    pause
    exit /b 1
)
echo  [OK] Node.js found
echo.
echo  Running: npm install -g orbix-nichefinder-x
echo  (This may take 30-60 seconds on first run...)
echo.
npm install -g orbix-nichefinder-x
if %errorlevel% neq 0 (
    echo.
    echo  [XX] npm install failed. Check your internet connection.
    pause
    exit /b 1
)
echo.
echo  +============================================================+
echo  ^|   INSTALLATION COMPLETE                                    ^|
echo  ^|                                                            ^|
echo  ^|   Run the app anytime with:  nichefinder                  ^|
echo  ^|   Or:                        nichefinder-x                ^|
echo  ^|                                                            ^|
echo  ^|   Update anytime:  npm update -g orbix-nichefinder-x      ^|
echo  ^|   Uninstall:       npm uninstall -g orbix-nichefinder-x   ^|
echo  ^|                                                            ^|
echo  ^|   API key: twitterapi.io?ref=roughboy666                  ^|
echo  +============================================================+
echo.
set /p LAUNCH="  Launch NicheFinder X now? (Y/N): "
if /i "%LAUNCH%"=="Y" (
    echo  Starting...
    start "" cmd /c "nichefinder"
)
goto END

:FULL_INSTALL
echo.
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo  [XX] PowerShell is required but was not found.
    pause
    exit /b 1
)
if not exist "%~dp0NicheFinderX-Setup.ps1" (
    echo  [XX] NicheFinderX-Setup.ps1 not found.
    echo       Place INSTALL.bat and NicheFinderX-Setup.ps1 in the same folder.
    pause
    exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0NicheFinderX-Setup.ps1"
if %errorlevel% neq 0 (
    echo.
    echo  [XX] Installer exited with error (code %errorlevel%).
    pause
    exit /b %errorlevel%
)

:END
exit /b 0
