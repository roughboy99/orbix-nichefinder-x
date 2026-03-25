@echo off
title Orbix NicheFinder X — Auto Updater
color 0B

echo.
echo  ============================================================
echo   ORBIX NicheFinder X  ^|  Auto Updater
echo   Orbix Automation Solutions  ^|  getorbix.com
echo  ============================================================
echo.

:: Find the Downloads folder
set DOWNLOADS=%USERPROFILE%\Downloads
set NEWJSX=%DOWNLOADS%\orbix-nichefinder-x.jsx

:: Check the downloaded file exists
if not exist "%NEWJSX%" (
    echo  [ERROR] orbix-nichefinder-x.jsx not found in Downloads folder.
    echo          Please download the update first from the app.
    echo.
    pause
    exit /b 1
)

:: Find the install directory — check common locations
set INSTALLDIR=
if exist "%USERPROFILE%\NicheFinderX\src\orbix-nichefinder-x.jsx" (
    set INSTALLDIR=%USERPROFILE%\NicheFinderX
)
if exist "%USERPROFILE%\Desktop\NicheFinderX\src\orbix-nichefinder-x.jsx" (
    set INSTALLDIR=%USERPROFILE%\Desktop\NicheFinderX
)

:: If not found, ask the user
if "%INSTALLDIR%"=="" (
    echo  Could not auto-detect install directory.
    echo.
    set /p INSTALLDIR="  Enter your NicheFinderX install path: "
)

if not exist "%INSTALLDIR%\src\orbix-nichefinder-x.jsx" (
    echo  [ERROR] Install directory not found or invalid: %INSTALLDIR%
    echo          Run the original INSTALL.bat to set up the app first.
    echo.
    pause
    exit /b 1
)

echo  Install directory: %INSTALLDIR%
echo.

:: Stop any running server on port 5173
echo  Stopping any running server on port 5173...
for /f "tokens=5" %%a in ('netstat -ano 2^>nul ^| findstr ":5173"') do (
    taskkill /F /PID %%a >nul 2>&1
)
timeout /t 1 /nobreak >nul

:: Backup the old file
echo  Backing up old version...
copy /Y "%INSTALLDIR%\src\orbix-nichefinder-x.jsx" "%INSTALLDIR%\src\orbix-nichefinder-x.jsx.bak" >nul
echo  [OK] Backup saved as orbix-nichefinder-x.jsx.bak

:: Copy the new file
echo  Installing new version...
copy /Y "%NEWJSX%" "%INSTALLDIR%\src\orbix-nichefinder-x.jsx" >nul
if %errorlevel% neq 0 (
    echo  [ERROR] Failed to copy new file. Try running as Administrator.
    pause
    exit /b 1
)
echo  [OK] New version installed

:: Clean up downloaded file
del /Q "%NEWJSX%" >nul 2>&1

echo.
echo  ============================================================
echo   UPDATE COMPLETE!
echo  ============================================================
echo.
echo  Starting NicheFinder X...
echo.

:: Restart the server
cd /d "%INSTALLDIR%"
start "" "%INSTALLDIR%\NicheFinderX-Start.bat"

timeout /t 2 /nobreak >nul
exit /b 0
