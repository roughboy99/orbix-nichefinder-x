# ============================================================
#  ORBIX NICHEFINDER X — Windows Installer
#  Version: 1.05
#  Orbix Automation Solutions | getorbix.com
#  (610) ORBIX AI — (610) 672-4924
# ============================================================
#  Run via INSTALL.bat — do not execute directly
# ============================================================

param([string]$InstallPath = "")

# ── CONSOLE SETUP ──────────────────────────────────────────
$Host.UI.RawUI.WindowTitle = "Orbix NicheFinder X — Installer v1.05"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Brand  { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Step   { param($msg) Write-Host "`n  >>> $msg" -ForegroundColor Yellow }
function Write-OK     { param($msg) Write-Host "  [OK]  $msg" -ForegroundColor Green }
function Write-Warn   { param($msg) Write-Host "  [!!]  $msg" -ForegroundColor DarkYellow }
function Write-Fail   { param($msg) Write-Host "  [XX]  $msg" -ForegroundColor Red }
function Write-Info   { param($msg) Write-Host "        $msg" -ForegroundColor Gray }
function Write-Div    { Write-Host "  " + ("=" * 62) -ForegroundColor DarkGray }

# ── HEADER ─────────────────────────────────────────────────
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor DarkCyan
Write-Host "  ║                                                          ║" -ForegroundColor DarkCyan
Write-Host "  ║   " -NoNewline -ForegroundColor DarkCyan
Write-Host "ORBIX " -NoNewline -ForegroundColor Cyan
Write-Host "NicheFinder X" -NoNewline -ForegroundColor White
Write-Host "   —   Windows Installer v1.05" -NoNewline -ForegroundColor Gray
Write-Host "   ║" -ForegroundColor DarkCyan
Write-Host "  ║   " -NoNewline -ForegroundColor DarkCyan
Write-Host "The perfect companion to Andy Hafell's Content Mate" -NoNewline -ForegroundColor DarkYellow
Write-Host "   ║" -ForegroundColor DarkCyan
Write-Host "  ║                                                          ║" -ForegroundColor DarkCyan
Write-Host "  ║   " -NoNewline -ForegroundColor DarkCyan
Write-Host "getorbix.com  |  (610) ORBIX AI  |  twitterapi.io" -NoNewline -ForegroundColor DarkGray
Write-Host "      ║" -ForegroundColor DarkCyan
Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor DarkCyan
Write-Host ""

# ── STEP 1 — CHOOSE INSTALL LOCATION ───────────────────────
Write-Step "STEP 1 — Installation Location"
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

# ── STEP 2 — CHECK NODE.JS ─────────────────────────────────
Write-Step "STEP 2 — Checking Node.js"
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

# ── Install Node.js if missing ──────────────────────────────
if (-not $nodeOK) {
    Write-Warn "Node.js 18+ is required. Attempting install..."
    Write-Host ""

    # Try winget first (Windows 10 1709+ / Windows 11)
    $wingetAvail = $null
    try { $wingetAvail = (winget --version 2>$null) } catch {}

    if ($wingetAvail) {
        Write-Info "Using winget to install Node.js LTS..."
        try {
            winget install --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements -e
            # Refresh PATH
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
        # Download Node.js installer from nodejs.org
        Write-Info "Downloading Node.js 20 LTS installer..."
        $nodeUrl = "https://nodejs.org/dist/v20.18.1/node-v20.18.1-x64.msi"
        $tmpMsi  = Join-Path $env:TEMP "node_setup.msi"
        try {
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($nodeUrl, $tmpMsi)
            Write-Info "Running Node.js installer (follow the prompts)..."
            Start-Process msiexec.exe -ArgumentList "/i `"$tmpMsi`" /qn ADDLOCAL=ALL" -Wait -NoNewWindow
            # Refresh PATH
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

# ── STEP 3 — CREATE APP DIRECTORY ──────────────────────────
Write-Step "STEP 3 — Creating Application Directory"
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

# ── STEP 4 — EXTRACT APP FILES ──────────────────────────────
Write-Step "STEP 4 — Writing Application Files"
Write-Div

# ── package.json ──
$packageJson = @'
{
  "name": "nichefinder-x",
  "private": true,
  "version": "1.05.0",
  "description": "Orbix NicheFinder X — Niche Influencer Finder for X/Twitter",
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

# ── vite.config.js ──
$viteConfig = @'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    open: true,
  }
})
'@
Set-Content -Path (Join-Path $appDir "vite.config.js") -Value $viteConfig -Encoding UTF8
Write-OK "vite.config.js written"

# ── index.html ──
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

# ── favicon ──
$faviconSvg = @'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="6" fill="#0D1117"/>
  <path d="M8 8h6l4 6 4-6h6l-7 10 7 10h-6l-4-6-4 6H8l7-10z" fill="#2B5BA8"/>
</svg>
'@
Set-Content -Path (Join-Path $appDir "public\favicon.svg") -Value $faviconSvg -Encoding UTF8

# ── src/main.jsx ──
$mainJsx = @'
import React from 'react'
import ReactDOM from 'react-dom/client'
import NicheFinderX from './orbix-nichefinder-x.jsx'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <NicheFinderX />
  </React.StrictMode>
)
'@
Set-Content -Path (Join-Path $appDir "src\main.jsx") -Value $mainJsx -Encoding UTF8
Write-OK "src/main.jsx written"

# ── EXTRACT EMBEDDED JSX (gzip+base64) ──
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
Write-OK "src/orbix-nichefinder-x.jsx extracted ($([math]::Round($jsxContent.Length/1024,1)) KB)"

# ── STEP 5 — NPM INSTALL ───────────────────────────────────
Write-Step "STEP 5 — Installing Dependencies"
Write-Div
Write-Info "Running npm install (this may take 30-60 seconds)..."
Write-Host ""

Push-Location $appDir
try {
    $proc = Start-Process npm -ArgumentList "install" -WorkingDirectory $appDir -Wait -PassThru -WindowStyle Normal
    if ($proc.ExitCode -ne 0) {
        Write-Fail "npm install failed (exit code $($proc.ExitCode))"
        Pop-Location
        Read-Host "  Press ENTER to exit"
        exit 1
    }
    Write-OK "npm packages installed successfully"
} catch {
    Write-Fail "npm install error: $_"
    Pop-Location
    Read-Host "  Press ENTER to exit"
    exit 1
}
Pop-Location

# ── STEP 6 — CREATE LAUNCHER BATCH FILE ────────────────────
Write-Step "STEP 6 — Creating Launcher"
Write-Div

$launcherContent = "@echo off`r`ntitle Orbix NicheFinder X`r`ncd /d `"$appDir`"`r`necho.`r`necho   Orbix NicheFinder X v1.05 - Starting...`r`necho   Open your browser at: http://localhost:5173`r`necho   Press Ctrl+C to stop the server`r`necho.`r`nnpm run dev`r`npause`r`n"
$launcherPath = Join-Path $appDir "NicheFinderX-Start.bat"
Set-Content -Path $launcherPath -Value $launcherContent -Encoding ASCII
Write-OK "Launcher created: NicheFinderX-Start.bat"

# ── STEP 7 — DESKTOP SHORTCUT ──────────────────────────────
Write-Step "STEP 7 — Creating Desktop Shortcut"
Write-Div

$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "NicheFinder X.lnk"

try {
    $WshShell = New-Object -ComObject WScript.Shell
    $shortcut = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath       = $launcherPath
    $shortcut.WorkingDirectory = $appDir
    $shortcut.WindowStyle      = 1
    $shortcut.Description      = "Orbix NicheFinder X v1.05 — Niche Influencer Finder"
    $iconPath = Join-Path $appDir "public\favicon.svg"
    # Use cmd.exe icon as fallback (Windows doesn't support SVG for shortcuts)
    $shortcut.IconLocation = "%SystemRoot%\System32\SHELL32.dll,14"
    $shortcut.Save()
    Write-OK "Desktop shortcut created: NicheFinder X"
} catch {
    Write-Warn "Could not create desktop shortcut: $_"
    Write-Info "You can still launch from: $launcherPath"
}

# ── STEP 8 — START MENU SHORTCUT ───────────────────────────
try {
    $startMenuDir = Join-Path ([Environment]::GetFolderPath("Programs")) "Orbix"
    if (-not (Test-Path $startMenuDir)) {
        New-Item -ItemType Directory -Force -Path $startMenuDir | Out-Null
    }
    $smShortcutPath = Join-Path $startMenuDir "NicheFinder X.lnk"
    $WshShell2 = New-Object -ComObject WScript.Shell
    $smShortcut = $WshShell2.CreateShortcut($smShortcutPath)
    $smShortcut.TargetPath       = $launcherPath
    $smShortcut.WorkingDirectory = $appDir
    $smShortcut.WindowStyle      = 1
    $smShortcut.Description      = "Orbix NicheFinder X v1.05"
    $smShortcut.IconLocation     = "%SystemRoot%\System32\SHELL32.dll,14"
    $smShortcut.Save()
    Write-OK "Start Menu shortcut created: Orbix > NicheFinder X"
} catch {
    Write-Warn "Could not create Start Menu shortcut (non-critical)"
}

# ── DONE ───────────────────────────────────────────────────
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                          ║" -ForegroundColor Green
Write-Host "  ║   " -NoNewline -ForegroundColor Green
Write-Host " INSTALLATION COMPLETE " -NoNewline -ForegroundColor Black -BackgroundColor Green
Write-Host "                              ║" -ForegroundColor Green
Write-Host "  ║                                                          ║" -ForegroundColor Green
Write-Host "  ║   Installed to: " -NoNewline -ForegroundColor Green
Write-Host $appDir.PadRight(42) -NoNewline -ForegroundColor White
Write-Host "║" -ForegroundColor Green
Write-Host "  ║                                                          ║" -ForegroundColor Green
Write-Host "  ║   TO LAUNCH:                                             ║" -ForegroundColor Green
Write-Host "  ║   " -NoNewline -ForegroundColor Green
Write-Host "• Double-click 'NicheFinder X' on your Desktop" -NoNewline -ForegroundColor Cyan
Write-Host "     ║" -ForegroundColor Green
Write-Host "  ║   " -NoNewline -ForegroundColor Green
Write-Host "• Or Start Menu > Orbix > NicheFinder X" -NoNewline -ForegroundColor Cyan
Write-Host "            ║" -ForegroundColor Green
Write-Host "  ║   " -NoNewline -ForegroundColor Green
Write-Host "• Browser opens at http://localhost:5173" -NoNewline -ForegroundColor Cyan
Write-Host "            ║" -ForegroundColor Green
Write-Host "  ║                                                          ║" -ForegroundColor Green
Write-Host "  ║   You need a TwitterAPI.io key to run searches.          ║" -ForegroundColor Green
Write-Host "  ║   Get one at: twitterapi.io?ref=roughboy666               ║" -ForegroundColor Green
Write-Host "  ║                                                          ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

$launch = Read-Host "  Launch NicheFinder X now? (Y/N)"
if ($launch.ToUpper() -eq "Y") {
    Write-Info "Starting server — browser will open at http://localhost:5173"
    Start-Process $launcherPath
}

Write-Host ""
Write-Host "  Thank you for using Orbix NicheFinder X!" -ForegroundColor DarkCyan
Write-Host "  getorbix.com  |  (610) ORBIX AI" -ForegroundColor DarkGray
Write-Host ""
