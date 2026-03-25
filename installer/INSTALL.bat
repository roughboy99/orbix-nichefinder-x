@echo off
title Orbix NicheFinder X - Installer v1.06
color 0B

echo.
echo  ============================================================
echo   ORBIX NicheFinder X  v1.06  ^|  Windows Installer
echo   Orbix Automation Solutions  ^|  getorbix.com
echo  ============================================================
echo.
echo  Starting installer...
echo.

:: Check if PowerShell is available
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERROR] PowerShell is required but was not found.
    echo          PowerShell is included with Windows 7 and later.
    echo.
    pause
    exit /b 1
)

:: Check if the PS1 file exists alongside this bat
if not exist "%~dp0NicheFinderX-Setup.ps1" (
    echo  [ERROR] NicheFinderX-Setup.ps1 not found.
    echo          Please place INSTALL.bat and NicheFinderX-Setup.ps1
    echo          in the same folder and try again.
    echo.
    pause
    exit /b 1
)

:: Run the PowerShell installer with execution policy bypass
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0NicheFinderX-Setup.ps1"

if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Installer exited with an error (code %errorlevel%).
    echo          Check the output above for details.
    echo.
    pause
    exit /b %errorlevel%
)

exit /b 0
