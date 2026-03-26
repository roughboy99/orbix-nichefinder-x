@echo off
title Orbix NicheFinder X - Uninstaller v1.07
color 0C

echo.
echo  ============================================================
echo   ORBIX NicheFinder X  v1.07  ^|  Uninstaller
echo   Orbix Automation Solutions  ^|  getorbix.com
echo  ============================================================
echo.
echo  Choose your uninstall method:
echo.
echo    [1]  npm uninstall  (if you installed via npm)
echo         Command: npm uninstall -g orbix-nichefinder-x
echo.
echo    [2]  Full Uninstaller  (if you used the PowerShell installer)
echo         Removes app folder, shortcuts, and optionally Node.js
echo.
echo    [3]  Exit
echo.

set /p CHOICE="  Enter 1, 2 or 3: "

if "%CHOICE%"=="1" goto NPM_UNINSTALL
if "%CHOICE%"=="2" goto FULL_UNINSTALL
if "%CHOICE%"=="3" goto END
echo  Invalid choice. Please run again.
pause
exit /b 1

:NPM_UNINSTALL
echo.
echo  ============================================================
echo   Uninstalling via npm...
echo  ============================================================
echo.
where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo  [XX] npm not found. Node.js may already be removed.
    pause
    exit /b 1
)
echo  Running: npm uninstall -g orbix-nichefinder-x
npm uninstall -g orbix-nichefinder-x
if %errorlevel% neq 0 (
    echo  [!!] Package may not have been installed via npm.
    echo       Try Option 2 (Full Uninstaller) instead.
    pause
    exit /b 1
)
echo.
echo  Also removing local app files (~\.nichefinder-x)...
if exist "%USERPROFILE%\.nichefinder-x" (
    rmdir /s /q "%USERPROFILE%\.nichefinder-x"
    echo  [OK] Local app files removed
) else (
    echo       Local app files not found - already clean
)
echo.
echo  +============================================================+
echo  ^|   UNINSTALL COMPLETE                                       ^|
echo  ^|                                                            ^|
echo  ^|   NicheFinder X has been removed.                         ^|
echo  ^|   Node.js was NOT removed.                                 ^|
echo  +============================================================+
echo.
goto END

:FULL_UNINSTALL
echo.
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo  [XX] PowerShell is required but was not found.
    pause
    exit /b 1
)
if not exist "%~dp0NicheFinderX-Uninstall.ps1" (
    echo  [XX] NicheFinderX-Uninstall.ps1 not found.
    echo       Place UNINSTALL.bat and NicheFinderX-Uninstall.ps1 in the same folder.
    pause
    exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0NicheFinderX-Uninstall.ps1"
if %errorlevel% neq 0 (
    echo.
    echo  [XX] Uninstaller exited with error (code %errorlevel%).
    pause
    exit /b %errorlevel%
)

:END
exit /b 0
