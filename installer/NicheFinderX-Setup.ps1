# ============================================================
#  ORBIX NICHEFINDER X - Windows Installer v1.08
#  Orbix Automation Solutions | getorbix.com
#  (610) ORBIX AI - (610) 672-4924
# ============================================================
#  Run via INSTALL.bat - do not execute directly
# ============================================================

param([string]$InstallPath = "")

$Host.UI.RawUI.WindowTitle = "Orbix NicheFinder X - Installer v1.08"
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
Write-Host "ORBIX NicheFinder X - Windows Installer v1.08" -NoNewline -ForegroundColor White
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
