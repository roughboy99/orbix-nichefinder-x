@echo off
title Orbix NicheFinder X - Uninstaller v1.07
color 0C

echo.
echo  ============================================================
echo   ORBIX NicheFinder X  v1.07  ^|  Uninstaller
echo   Orbix Automation Solutions  ^|  getorbix.com
echo  ============================================================
echo.
echo  Starting uninstaller...
echo.

where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERROR] PowerShell is required but was not found.
    pause
    exit /b 1
)

if not exist "%~dp0NicheFinderX-Uninstall.ps1" (
    echo  [ERROR] NicheFinderX-Uninstall.ps1 not found.
    echo          Place UNINSTALL.bat and NicheFinderX-Uninstall.ps1 in the same folder.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0NicheFinderX-Uninstall.ps1"

if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Uninstaller exited with an error (code %errorlevel%).
    pause
    exit /b %errorlevel%
)

exit /b 0
