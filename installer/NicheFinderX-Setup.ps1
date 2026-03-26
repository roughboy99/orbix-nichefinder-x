# ============================================================
#  ORBIX NICHEFINDER X - Windows Installer v1.07
#  Orbix Automation Solutions | getorbix.com
#  (610) ORBIX AI - (610) 672-4924
# ============================================================
#  Run via INSTALL.bat - do not execute directly
# ============================================================

param([string]$InstallPath = "")

$Host.UI.RawUI.WindowTitle = "Orbix NicheFinder X - Installer v1.07"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Step   { param($msg) Write-Host "" ; Write-Host "  >>> $msg" -ForegroundColor Yellow }
function Write-OK     { param($msg) Write-Host "  [OK]  $msg" -ForegroundColor Green }
function Write-Warn   { param($msg) Write-Host "  [!!]  $msg" -ForegroundColor DarkYellow }
function Write-Fail   { param($msg) Write-Host "  [XX]  $msg" -ForegroundColor Red }
function Write-Info   { param($msg) Write-Host "        $msg" -ForegroundColor Gray }
function Write-Div    { Write-Host "  ================================================================" -ForegroundColor DarkGray }

# --- HEADER ---
Clear-Host
Write-Host ""
Write-Host "  +============================================================+" -ForegroundColor DarkCyan
Write-Host "  |                                                            |" -ForegroundColor DarkCyan
Write-Host "  |   " -NoNewline -ForegroundColor DarkCyan
Write-Host "ORBIX NicheFinder X - Windows Installer v1.07" -NoNewline -ForegroundColor White
Write-Host "   |" -ForegroundColor DarkCyan
Write-Host "  |   " -NoNewline -ForegroundColor DarkCyan
Write-Host "The perfect companion to Andy Hafell's Content Mate" -NoNewline -ForegroundColor Yellow
Write-Host "   |" -ForegroundColor DarkCyan
Write-Host "  |                                                            |" -ForegroundColor DarkCyan
Write-Host "  |   " -NoNewline -ForegroundColor DarkCyan
Write-Host "getorbix.com  |  (610) ORBIX AI  |  twitterapi.io" -NoNewline -ForegroundColor Gray
Write-Host "      |" -ForegroundColor DarkCyan
Write-Host "  +============================================================+" -ForegroundColor DarkCyan
Write-Host ""

# --- DETECT EXISTING INSTALLATION ---
$npmInstalled  = $false
$fullInstalled = $false
$fullInstDir   = ""
$installedVia  = ""

# Check npm install (nichefinder command exists)
try {
    $nfCmd = Get-Command nichefinder -ErrorAction Stop
    $npmInstalled = $true
    $installedVia = "npm"
} catch {}

# Check full install (NicheFinderX directory with jsx file)
$candidates = @(
    (Join-Path $env:USERPROFILE "NicheFinderX"),
    (Join-Path $env:LOCALAPPDATA "NicheFinderX"),
    "C:\NicheFinderX"
)
foreach ($c in $candidates) {
    if (Test-Path (Join-Path $c "src\orbix-nichefinder-x.jsx")) {
        $fullInstalled = $true
        $fullInstDir   = $c
        $installedVia  = if ($npmInstalled) { "both" } else { "full" }
        break
    }
}

# --- EXISTING INSTALL DETECTED ---
if ($npmInstalled -or $fullInstalled) {
    Write-Host ""
    Write-Host "  +============================================================+" -ForegroundColor Yellow
    Write-Host "  |                                                            |" -ForegroundColor Yellow
    Write-Host "  |   " -NoNewline -ForegroundColor Yellow
    Write-Host "NicheFinder X is already installed on this computer." -NoNewline -ForegroundColor White
    Write-Host "   |" -ForegroundColor Yellow
    if ($npmInstalled)  { Write-Host "  |   via npm:       nichefinder command found" -ForegroundColor Yellow }
    if ($fullInstalled) { Write-Host "  |   via installer: $fullInstDir" -ForegroundColor Yellow }
    Write-Host "  |                                                            |" -ForegroundColor Yellow
    Write-Host "  +============================================================+" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  What would you like to do?" -ForegroundColor White
    Write-Host ""
    Write-Host "  " -NoNewline; Write-Host "[1]" -NoNewline -ForegroundColor Green
    Write-Host "  Update" -NoNewline -ForegroundColor White
    Write-Host " - launch the app and update from inside (recommended)"
    Write-Host "      The app checks GitHub and downloads updates automatically." -ForegroundColor Gray
    Write-Host ""
    Write-Host "  " -NoNewline; Write-Host "[2]" -NoNewline -ForegroundColor Red
    Write-Host "  Uninstall" -NoNewline -ForegroundColor White
    Write-Host " - remove NicheFinder X from this computer"
    Write-Host ""
    Write-Host "  " -NoNewline; Write-Host "[3]" -NoNewline -ForegroundColor Cyan
    Write-Host "  Fresh Install" -NoNewline -ForegroundColor White
    Write-Host " - reinstall from scratch (overwrites existing)"
    Write-Host ""
    Write-Host "  " -NoNewline; Write-Host "[4]" -NoNewline -ForegroundColor Gray
    Write-Host "  Exit"
    Write-Host ""

    $existChoice = Read-Host "  Enter 1, 2, 3 or 4"

    # --- UPDATE ---
    if ($existChoice -eq "1") {
        Write-Host ""
        Write-OK "Launching NicheFinder X for update..."
        Write-Host ""
        Write-Info "The app will open in your browser."
        Write-Info "Click 'Check for Updates' or wait for the startup auto-check."
        Write-Info "Follow the on-screen instructions to download and install."
        Write-Host ""
        if ($npmInstalled) {
            Start-Process cmd -ArgumentList "/c nichefinder"
        } elseif ($fullInstalled) {
            $launcher = Join-Path $fullInstDir "NicheFinderX-Start.bat"
            if (Test-Path $launcher) {
                Start-Process $launcher
            } else {
                Start-Process cmd -ArgumentList "/c cd /d `"$fullInstDir`" && npm run dev"
            }
        }
        Write-Host ""
        Read-Host "  Press ENTER to exit the installer"
        exit 0
    }

    # --- UNINSTALL ---
    elseif ($existChoice -eq "2") {
        Write-Host ""
        Write-Warn "Uninstalling NicheFinder X..."
        Write-Host ""

        if ($npmInstalled) {
            Write-Info "Running: npm uninstall -g orbix-nichefinder-x"
            try {
                $npmPath = (Get-Command npm -ErrorAction Stop).Source
                & $npmPath uninstall -g orbix-nichefinder-x
                Write-OK "npm package removed"
            } catch { Write-Warn "npm uninstall failed - may need to run manually" }
            $localApp = Join-Path $env:USERPROFILE ".nichefinder-x"
            if (Test-Path $localApp) {
                Remove-Item -Recurse -Force $localApp -ErrorAction SilentlyContinue
                Write-OK "Local app files removed"
            }
        }

        if ($fullInstalled) {
            Write-Info "Removing: $fullInstDir"
            Remove-Item -Recurse -Force $fullInstDir -ErrorAction SilentlyContinue
            Write-OK "App directory removed"
            $desktopSC = Join-Path ([Environment]::GetFolderPath("Desktop")) "NicheFinder X.lnk"
            if (Test-Path $desktopSC) { Remove-Item $desktopSC -Force; Write-OK "Desktop shortcut removed" }
            $smDir = Join-Path ([Environment]::GetFolderPath("Programs")) "Orbix"
            if (Test-Path $smDir) { Remove-Item -Recurse -Force $smDir; Write-OK "Start Menu entry removed" }
        }

        Write-Host ""
        Write-Host "  +============================================================+" -ForegroundColor Green
        Write-Host "  |   UNINSTALL COMPLETE                                       |" -ForegroundColor Green
        Write-Host "  |   NicheFinder X has been removed. Node.js was NOT removed. |" -ForegroundColor Green
        Write-Host "  +============================================================+" -ForegroundColor Green
        Write-Host ""
        Read-Host "  Press ENTER to exit"
        exit 0
    }

    # --- EXIT ---
    elseif ($existChoice -eq "4") {
        Write-Info "Exiting."
        exit 0
    }

    # --- FRESH INSTALL (3) falls through ---
    elseif ($existChoice -ne "3") {
        Write-Fail "Invalid choice. Run again and enter 1, 2, 3 or 4."
        Read-Host "  Press ENTER to exit"
        exit 1
    }

    Write-Host ""
    Write-Info "Proceeding with fresh install..."
    Write-Host ""
}

# --- INSTALLATION METHOD (new install) ---
Write-Host "  Choose your installation method:" -ForegroundColor White
Write-Host ""
Write-Host "  " -NoNewline; Write-Host "[1]" -NoNewline -ForegroundColor Cyan
Write-Host "  npm " -NoNewline -ForegroundColor White
Write-Host "(RECOMMENDED)" -NoNewline -ForegroundColor Green
Write-Host " - one command, automatic updates"
Write-Host "      Install: npm install -g orbix-nichefinder-x" -ForegroundColor Gray
Write-Host "      Run:     nichefinder" -ForegroundColor Gray
Write-Host ""
Write-Host "  " -NoNewline; Write-Host "[2]" -NoNewline -ForegroundColor Cyan
Write-Host "  Full Installer" -NoNewline -ForegroundColor White
Write-Host " - installs Node.js if missing, creates Desktop shortcut"
Write-Host ""
Write-Host "  " -NoNewline; Write-Host "[3]" -NoNewline -ForegroundColor Cyan
Write-Host "  Exit"
Write-Host ""

$method = Read-Host "  Enter 1, 2 or 3"

if ($method -eq "1") {
    Write-Host ""
    Write-Step "Installing via npm..."
    Write-Host ""

    $nodeExists = $null
    try { $nodeExists = (Get-Command node -ErrorAction Stop).Source } catch {}

    if (-not $nodeExists) {
        Write-Fail "Node.js not found."
        Write-Info "Download from: https://nodejs.org"
        Write-Info "Install Node.js 18 LTS, then run this installer again."
        Write-Host ""
        Read-Host "  Press ENTER to exit"
        exit 1
    }
    $nodeVer = (node --version 2>$null)
    Write-OK "Node.js $nodeVer found"
    Write-Host ""
    Write-Info "Running: npm install -g orbix-nichefinder-x"
    Write-Info "(This may take 30-60 seconds on first run...)"
    Write-Host ""

    $npmPath = (Get-Command npm -ErrorAction Stop).Source
    & $npmPath install -g orbix-nichefinder-x
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "npm install failed. Check your internet connection."
        Read-Host "  Press ENTER to exit"
        exit 1
    }

    Write-Host ""
    Write-Host "  +============================================================+" -ForegroundColor Green
    Write-Host "  |   INSTALLATION COMPLETE                                    |" -ForegroundColor Green
    Write-Host "  |                                                            |" -ForegroundColor Green
    Write-Host "  |   Run anytime:   nichefinder                               |" -ForegroundColor Green
    Write-Host "  |   Update:        npm update -g orbix-nichefinder-x         |" -ForegroundColor Green
    Write-Host "  |   Uninstall:     npm uninstall -g orbix-nichefinder-x      |" -ForegroundColor Green
    Write-Host "  |   API key:       twitterapi.io?ref=roughboy666              |" -ForegroundColor Green
    Write-Host "  +============================================================+" -ForegroundColor Green
    Write-Host ""

    $launch = Read-Host "  Launch NicheFinder X now? (Y/N)"
    if ($launch.ToUpper() -eq "Y") {
        Write-Info "Starting..."
        Start-Process cmd -ArgumentList "/c nichefinder"
    }
    exit 0
}
elseif ($method -eq "3") {
    Write-Info "Installation cancelled."
    exit 0
}
elseif ($method -ne "2") {
    Write-Fail "Invalid choice. Run the installer again and enter 1, 2 or 3."
    Read-Host "  Press ENTER to exit"
    exit 1
}

Write-Host ""
Write-Info "Continuing with full installer..."
Write-Host ""

# --- STEP 1 - CHOOSE INSTALL LOCATION ---
Write-Step "STEP 1 - Installation Location"
Write-Div

$defaultPath = Join-Path $env:USERPROFILE "NicheFinderX"

if ($InstallPath -ne "") {
    $appDir = $InstallPath
} else {
    Write-Info "Default install location: $defaultPath"
    Write-Host ""
    $choice = Read-Host "  Press ENTER to accept or type a custom path"
    $appDir = if ($choice.Trim() -eq "") { $defaultPath } else { $choice.Trim() }
}

Write-OK "Install location: $appDir"

# --- STEP 2 - CHECK NODE.JS ---
Write-Step "STEP 2 - Checking Node.js"
Write-Div

$nodeOK = $false
$npmOK  = $false

try {
    $nodeVer = (node --version 2>$null)
    if ($nodeVer -match "v(\d+)") {
        $major = [int]$Matches[1]
        if ($major -ge 18) {
            Write-OK "Node.js $nodeVer found (>=18 required)"
            $nodeOK = $true
        } else {
            Write-Warn "Node.js $nodeVer found but version 18+ is required"
        }
    }
} catch { Write-Warn "Node.js not found in PATH" }

try {
    $npmVer = (npm --version 2>$null)
    if ($npmVer) {
        Write-OK "npm v$npmVer found"
        $npmOK = $true
    }
} catch { Write-Warn "npm not found" }

if (-not $nodeOK) {
    Write-Warn "Node.js 18+ is required. Attempting install..."
    Write-Host ""

    $wingetAvail = $null
    try { $wingetAvail = (winget --version 2>$null) } catch {}

    if ($wingetAvail) {
        Write-Info "Using winget to install Node.js LTS..."
        try {
            winget install --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements -e
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                        [System.Environment]::GetEnvironmentVariable("Path","User")
            $nodeVer = (node --version 2>$null)
            Write-OK "Node.js $nodeVer installed via winget"
            $nodeOK = $true
            $npmOK  = $true
        } catch {
            Write-Warn "winget install failed. Falling back to manual download..."
        }
    }

    if (-not $nodeOK) {
        Write-Info "Downloading Node.js 20 LTS installer..."
        $nodeUrl = "https://nodejs.org/dist/v20.18.1/node-v20.18.1-x64.msi"
        $tmpMsi  = Join-Path $env:TEMP "node_setup.msi"
        try {
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($nodeUrl, $tmpMsi)
            Write-Info "Running Node.js installer (this may take a minute)..."
            Start-Process msiexec.exe -ArgumentList "/i `"$tmpMsi`" /qn ADDLOCAL=ALL" -Wait -NoNewWindow
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                        [System.Environment]::GetEnvironmentVariable("Path","User")
            $nodeVer = (node --version 2>$null)
            Write-OK "Node.js $nodeVer installed"
            $nodeOK = $true
            $npmOK  = $true
        } catch {
            Write-Fail "Could not auto-install Node.js."
            Write-Info "Please install manually from: https://nodejs.org"
            Write-Info "Then run this installer again."
            Write-Host ""
            Read-Host "  Press ENTER to exit"
            exit 1
        }
    }
}

if (-not $nodeOK -or -not $npmOK) {
    Write-Fail "Node.js / npm not available. Cannot continue."
    Read-Host "  Press ENTER to exit"
    exit 1
}

# --- STEP 3 - CREATE APP DIRECTORY ---
Write-Step "STEP 3 - Creating Application Directory"
Write-Div

if (Test-Path $appDir) {
    Write-Warn "Directory already exists: $appDir"
    $overwrite = Read-Host "  Overwrite existing installation? (Y/N)"
    if ($overwrite.ToUpper() -ne "Y") {
        Write-Info "Installation cancelled."
        Read-Host "  Press ENTER to exit"
        exit 0
    }
    Write-Info "Removing existing installation..."
    Remove-Item -Recurse -Force $appDir -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Force -Path $appDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $appDir "src") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $appDir "public") | Out-Null
Write-OK "Directory created: $appDir"

# --- STEP 4 - WRITE APP FILES ---
Write-Step "STEP 4 - Writing Application Files"
Write-Div

# package.json
$packageJson = @'
{
  "name": "nichefinder-x",
  "private": true,
  "version": "1.05.0",
  "description": "Orbix NicheFinder X",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@types/react": "^18.3.1",
    "@types/react-dom": "^18.3.1",
    "@vitejs/plugin-react": "^4.3.4",
    "vite": "^6.3.5"
  }
}
'@
Set-Content -Path (Join-Path $appDir "package.json") -Value $packageJson -Encoding UTF8
Write-OK "package.json written"

# vite.config.js
$viteConfig = @"
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    strictPort: false,
    open: true,
    proxy: {
      '/twitterapi': {
        target: 'https://api.twitterapi.io',
        changeOrigin: true,
        rewrite: path => path.replace(/^\/twitterapi/, ''),
        secure: true,
      }
    }
  }
})
"@
Set-Content -Path (Join-Path $appDir "vite.config.js") -Value $viteConfig -Encoding UTF8
Write-OK "vite.config.js written"

# index.html
$indexHtml = @'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Orbix NicheFinder X</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
'@
Set-Content -Path (Join-Path $appDir "index.html") -Value $indexHtml -Encoding UTF8
Write-OK "index.html written"

# favicon
$faviconSvg = @'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="6" fill="#0D1117"/>
  <path d="M8 8h6l4 6 4-6h6l-7 10 7 10h-6l-4-6-4 6H8l7-10z" fill="#2B5BA8"/>
</svg>
'@
Set-Content -Path (Join-Path $appDir "public\favicon.svg") -Value $faviconSvg -Encoding UTF8

# src/main.jsx
$mainJsx = @'
import React from 'react'
import ReactDOM from 'react-dom/client'
import NicheFinderX from './orbix-nichefinder-x.jsx'
ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode><NicheFinderX /></React.StrictMode>
)
'@
Set-Content -Path (Join-Path $appDir "src\main.jsx") -Value $mainJsx -Encoding UTF8
Write-OK "src/main.jsx written"

# Extract embedded JSX
Write-Info "Extracting orbix-nichefinder-x.jsx..."
$b64 = "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"
$bytes      = [Convert]::FromBase64String($b64)
$memIn      = New-Object System.IO.MemoryStream(,$bytes)
$gzip       = New-Object System.IO.Compression.GZipStream($memIn, [System.IO.Compression.CompressionMode]::Decompress)
$memOut     = New-Object System.IO.MemoryStream
$gzip.CopyTo($memOut)
$gzip.Close()
$jsxContent = [System.Text.Encoding]::UTF8.GetString($memOut.ToArray())
$jsxPath    = Join-Path $appDir "src\orbix-nichefinder-x.jsx"
[System.IO.File]::WriteAllText($jsxPath, $jsxContent, [System.Text.Encoding]::UTF8)
$jsxKB = [math]::Round($jsxContent.Length / 1024, 1)
Write-OK "orbix-nichefinder-x.jsx extracted ($jsxKB KB)"

# --- STEP 5 - NPM INSTALL ---
Write-Step "STEP 5 - Installing Dependencies"
Write-Div
Write-Info "Running npm install (30-60 seconds)..."
Write-Host ""

Push-Location $appDir
try {
    # Run npm install directly in the current PowerShell session (PATH is inherited correctly)
    $npmPath = (Get-Command npm -ErrorAction Stop).Source
    Write-Info "npm found at: $npmPath"
    & $npmPath install
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "npm install failed (exit code $LASTEXITCODE)"
        Pop-Location
        Read-Host "  Press ENTER to exit"
        exit 1
    }
    Write-OK "npm packages installed successfully"
} catch {
    # Fallback: try npm directly by name
    try {
        npm install
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "npm install failed (exit code $LASTEXITCODE)"
            Pop-Location
            Read-Host "  Press ENTER to exit"
            exit 1
        }
        Write-OK "npm packages installed successfully"
    } catch {
        Write-Fail "npm install error: $_"
        Write-Info "Try running manually: cd `"$appDir`" && npm install"
        Pop-Location
        Read-Host "  Press ENTER to exit"
        exit 1
    }
}
Pop-Location

# --- STEP 6 - CREATE LAUNCHER ---
Write-Step "STEP 6 - Creating Launcher"
Write-Div

$launcherContent = "@echo off`r`ntitle Orbix NicheFinder X`r`ncd /d `"$appDir`"`r`necho.`r`necho   Orbix NicheFinder X v1.05 - Starting...`r`necho   Vite opens your browser automatically.`r`necho   If port 5173 is busy, Vite picks the next free port.`r`necho   Press Ctrl+C to stop the server.`r`necho.`r`nnpm run dev`r`npause`r`n"
$launcherPath = Join-Path $appDir "NicheFinderX-Start.bat"
Set-Content -Path $launcherPath -Value $launcherContent -Encoding ASCII
Write-OK "Launcher created: NicheFinderX-Start.bat"

# --- STEP 7 - DESKTOP SHORTCUT ---
Write-Step "STEP 7 - Creating Desktop Shortcut"
Write-Div

$desktopPath  = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "NicheFinder X.lnk"

try {
    $WshShell  = New-Object -ComObject WScript.Shell
    $shortcut  = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath       = $launcherPath
    $shortcut.WorkingDirectory = $appDir
    $shortcut.WindowStyle      = 1
    $shortcut.Description      = "Orbix NicheFinder X v1.05"
    $shortcut.IconLocation     = "%SystemRoot%\System32\SHELL32.dll,14"
    $shortcut.Save()
    Write-OK "Desktop shortcut created: NicheFinder X"
} catch {
    Write-Warn "Could not create desktop shortcut: $_"
    Write-Info "You can still launch from: $launcherPath"
}

try {
    $startMenuDir = Join-Path ([Environment]::GetFolderPath("Programs")) "Orbix"
    if (-not (Test-Path $startMenuDir)) { New-Item -ItemType Directory -Force -Path $startMenuDir | Out-Null }
    $smPath = Join-Path $startMenuDir "NicheFinder X.lnk"
    $WshShell2 = New-Object -ComObject WScript.Shell
    $sm = $WshShell2.CreateShortcut($smPath)
    $sm.TargetPath       = $launcherPath
    $sm.WorkingDirectory = $appDir
    $sm.WindowStyle      = 1
    $sm.Description      = "Orbix NicheFinder X v1.05"
    $sm.IconLocation     = "%SystemRoot%\System32\SHELL32.dll,14"
    $sm.Save()
    Write-OK "Start Menu shortcut created: Orbix > NicheFinder X"
} catch {
    Write-Warn "Could not create Start Menu shortcut (non-critical)"
}

# --- DONE ---
Write-Host ""
Write-Host "  +============================================================+" -ForegroundColor Green
Write-Host "  |                                                            |" -ForegroundColor Green
Write-Host "  |   INSTALLATION COMPLETE                                    |" -ForegroundColor Green
Write-Host "  |                                                            |" -ForegroundColor Green
Write-Host "  |   Installed to:" -NoNewline -ForegroundColor Green
Write-Host " $appDir" -ForegroundColor White
Write-Host "  |                                                            |" -ForegroundColor Green
Write-Host "  |   TO LAUNCH:                                               |" -ForegroundColor Green
Write-Host "  |     - Double-click 'NicheFinder X' on your Desktop         |" -ForegroundColor Green
Write-Host "  |     - Or: Start Menu > Orbix > NicheFinder X               |" -ForegroundColor Green
Write-Host "  |     - Browser opens automatically (port 5173 or next free) |" -ForegroundColor Green
Write-Host "  |                                                            |" -ForegroundColor Green
Write-Host "  |   API key required: twitterapi.io?ref=roughboy666          |" -ForegroundColor Green
Write-Host "  |                                                            |" -ForegroundColor Green
Write-Host "  +============================================================+" -ForegroundColor Green
Write-Host ""

$launch = Read-Host "  Launch NicheFinder X now? (Y/N)"
if ($launch.ToUpper() -eq "Y") {
    Write-Info "Starting server..."
    Start-Process $launcherPath
}

Write-Host ""
Write-Host "  Thank you for using Orbix NicheFinder X!" -ForegroundColor Cyan
Write-Host "  getorbix.com  |  (610) ORBIX AI" -ForegroundColor Gray
Write-Host ""
