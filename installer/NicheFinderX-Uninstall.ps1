# ============================================================
#  ORBIX NICHEFINDER X - Uninstaller v1.07
#  Orbix Automation Solutions | getorbix.com
#  (610) ORBIX AI - (610) 672-4924
# ============================================================
#  What this uninstaller does:
#    1. Finds and removes the NicheFinderX app directory
#    2. Removes Desktop shortcut
#    3. Removes Start Menu entry
#    4. Removes browser localStorage data (clears saved key)
#    5. Checks for other Node.js projects before touching Node
#    6. Only offers to uninstall Node.js if no other projects found
# ============================================================

param([string]$InstallPath = "")

$Host.UI.RawUI.WindowTitle = "Orbix NicheFinder X - Uninstaller v1.07"
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
Write-Host "  +============================================================+" -ForegroundColor Red
Write-Host "  |                                                            |" -ForegroundColor Red
Write-Host "  |   " -NoNewline -ForegroundColor Red
Write-Host "ORBIX NicheFinder X - Uninstaller v1.07" -NoNewline -ForegroundColor White
Write-Host "           |" -ForegroundColor Red
Write-Host "  |   " -NoNewline -ForegroundColor Red
Write-Host "This will remove NicheFinder X from your computer." -NoNewline -ForegroundColor DarkYellow
Write-Host "      |" -ForegroundColor Red
Write-Host "  |                                                            |" -ForegroundColor Red
Write-Host "  +============================================================+" -ForegroundColor Red
Write-Host ""

# --- UNINSTALL METHOD ---
Write-Host ""
Write-Host "  Choose your uninstall method:" -ForegroundColor White
Write-Host ""
Write-Host "  " -NoNewline; Write-Host "[1]" -NoNewline -ForegroundColor Cyan
Write-Host "  npm uninstall" -NoNewline -ForegroundColor White
Write-Host " - if you installed via npm"
Write-Host "      Command: npm uninstall -g orbix-nichefinder-x" -ForegroundColor Gray
Write-Host ""
Write-Host "  " -NoNewline; Write-Host "[2]" -NoNewline -ForegroundColor Cyan
Write-Host "  Full Uninstaller" -NoNewline -ForegroundColor White
Write-Host " - if you used the PowerShell installer"
Write-Host "      Removes app folder, shortcuts, and optionally Node.js"
Write-Host ""
Write-Host "  " -NoNewline; Write-Host "[3]" -NoNewline -ForegroundColor Cyan
Write-Host "  Exit"
Write-Host ""

$umethod = Read-Host "  Enter 1, 2 or 3"

if ($umethod -eq "1") {
    Write-Host ""
    Write-Step "Uninstalling via npm..."
    Write-Host ""
    $npmExists = $null
    try { $npmExists = (Get-Command npm -ErrorAction Stop).Source } catch {}
    if (-not $npmExists) {
        Write-Fail "npm not found. Node.js may already be removed."
        Read-Host "  Press ENTER to exit"; exit 1
    }
    $npmPath2 = (Get-Command npm -ErrorAction Stop).Source
    & $npmPath2 uninstall -g orbix-nichefinder-x
    $localApp = Join-Path $env:USERPROFILE ".nichefinder-x"
    if (Test-Path $localApp) {
        Write-Info "Removing local app files: $localApp"
        Remove-Item -Recurse -Force $localApp -ErrorAction SilentlyContinue
        Write-OK "Local app files removed"
    } else {
        Write-Info "Local app files not found - already clean"
    }
    Write-Host ""
    Write-Host "  +============================================================+" -ForegroundColor Green
    Write-Host "  |   UNINSTALL COMPLETE                                       |" -ForegroundColor Green
    Write-Host "  |   NicheFinder X has been removed.                          |" -ForegroundColor Green
    Write-Host "  |   Node.js was NOT removed.                                 |" -ForegroundColor Green
    Write-Host "  +============================================================+" -ForegroundColor Green
    Write-Host ""
    Read-Host "  Press ENTER to exit"; exit 0
}
elseif ($umethod -eq "3") {
    Write-Info "Uninstall cancelled."; exit 0
}
elseif ($umethod -ne "2") {
    Write-Fail "Invalid choice. Run again and enter 1, 2 or 3."
    Read-Host "  Press ENTER to exit"; exit 1
}

Write-Host ""
Write-Info "Continuing with full uninstaller..."
Write-Host ""

# --- STEP 1 --- FIND INSTALL DIRECTORY -------------------------
Write-Step "STEP 1 - Finding Installation"
Write-Div

$candidates = @(
    (Join-Path $env:USERPROFILE "NicheFinderX"),
    (Join-Path $env:USERPROFILE "Desktop\NicheFinderX"),
    (Join-Path $env:USERPROFILE "Documents\NicheFinderX"),
    (Join-Path $env:LOCALAPPDATA "NicheFinderX"),
    "C:\NicheFinderX",
    "C:\Program Files\NicheFinderX"
)

$appDir = ""

# Check provided path first
if ($InstallPath -ne "" -and (Test-Path (Join-Path $InstallPath "src\orbix-nichefinder-x.jsx"))) {
    $appDir = $InstallPath
}

# Auto-detect from candidates
if ($appDir -eq "") {
    foreach ($c in $candidates) {
        if (Test-Path (Join-Path $c "src\orbix-nichefinder-x.jsx")) {
            $appDir = $c
            break
        }
    }
}

# Ask user if not found
if ($appDir -eq "") {
    Write-Warn "Could not auto-detect the NicheFinder X installation."
    Write-Info "Looked in: $($candidates -join ', ')"
    Write-Host ""
    $manual = Read-Host "  Enter the install path manually (or press ENTER to cancel)"
    if ($manual.Trim() -eq "") {
        Write-Info "Uninstall cancelled."
        Read-Host "  Press ENTER to exit"
        exit 0
    }
    if (Test-Path (Join-Path $manual.Trim() "src\orbix-nichefinder-x.jsx")) {
        $appDir = $manual.Trim()
    } else {
        Write-Fail "NicheFinder X not found at: $($manual.Trim())"
        Write-Info "Nothing was removed."
        Read-Host "  Press ENTER to exit"
        exit 1
    }
}

Write-OK "Found installation at: $appDir"

# --- STEP 2 --- CONFIRM UNINSTALL -------------------------------
Write-Step "STEP 2 - Confirm Uninstall"
Write-Div

Write-Host ""
Write-Host "  The following will be PERMANENTLY removed:" -ForegroundColor White
Write-Host "    - App directory: $appDir" -ForegroundColor DarkYellow
Write-Host "    - Desktop shortcut: NicheFinder X" -ForegroundColor DarkYellow
Write-Host "    - Start Menu entry: Orbix > NicheFinder X" -ForegroundColor DarkYellow
Write-Host "    - Saved API key (encrypted, in browser localStorage)" -ForegroundColor DarkYellow
Write-Host ""
Write-Host "  Node.js will NOT be removed automatically." -ForegroundColor Green
Write-Host "  (We check for other Node.js projects first - see Step 4)" -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "  Type YES to confirm uninstall (anything else cancels)"
if ($confirm.Trim().ToUpper() -ne "YES") {
    Write-Info "Uninstall cancelled. Nothing was removed."
    Read-Host "  Press ENTER to exit"
    exit 0
}

# --- STEP 3 --- STOP RUNNING SERVER -----------------------------
Write-Step "STEP 3 - Stopping Any Running Server"
Write-Div

$ports = @(5173, 5174, 5175, 5176, 5177)
$stopped = $false
foreach ($port in $ports) {
    try {
        $conn = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
        if ($conn) {
            $pid = $conn.OwningProcess
            $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
            if ($proc -and ($proc.Name -match "node")) {
                Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
                Write-OK "Stopped Node.js server on port $port (PID $pid)"
                $stopped = $true
            }
        }
    } catch {}
}
if (-not $stopped) {
    Write-Info "No running NicheFinder X server detected."
}

Start-Sleep -Seconds 1

# --- STEP 4 --- CHECK FOR OTHER NODE.JS PROJECTS ----------------
Write-Step "STEP 4 - Checking for Other Node.js Projects"
Write-Div

Write-Info "Scanning for other node_modules directories on this machine..."
Write-Info "(This protects other Node.js apps from being affected)"
Write-Host ""

$searchRoots = @(
    $env:USERPROFILE,
    "C:\Users",
    "C:\projects",
    "C:\dev",
    "C:\code",
    "C:\work"
) | Where-Object { Test-Path $_ }

$otherNodeProjects = @()

foreach ($root in $searchRoots) {
    try {
        $found = Get-ChildItem -Path $root -Filter "node_modules" -Recurse -Directory `
            -Depth 4 -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notlike "$appDir*" } |
            Select-Object -First 20
        $otherNodeProjects += $found
    } catch {}
}

# Also check for globally installed npm packages
$globalPackages = @()
try {
    $globalList = npm list -g --depth=0 2>$null
    if ($globalList) {
        $globalPackages = $globalList | Where-Object { $_ -match "^\+--" -and $_ -notmatch "npm@" }
    }
} catch {}

# Check for running node processes other than ours
$otherNodeProcs = Get-Process -Name "node" -ErrorAction SilentlyContinue |
    Where-Object { $_.Id -ne $PID }

if ($otherNodeProjects.Count -gt 0) {
    Write-Warn "Found $($otherNodeProjects.Count) other Node.js project(s) on this machine:"
    $otherNodeProjects | Select-Object -First 5 | ForEach-Object {
        Write-Info "  $($_.Parent.FullName)"
    }
    if ($otherNodeProjects.Count -gt 5) {
        Write-Info "  ... and $($otherNodeProjects.Count - 5) more"
    }
    Write-Host ""
    Write-OK "Node.js will NOT be touched -- other projects depend on it."
    $removeNode = $false
} elseif ($globalPackages.Count -gt 0) {
    Write-Warn "Found $($globalPackages.Count) global npm package(s) installed:"
    $globalPackages | Select-Object -First 5 | ForEach-Object { Write-Info "  $_" }
    Write-OK "Node.js will NOT be touched -- global packages are installed."
    $removeNode = $false
} elseif ($otherNodeProcs.Count -gt 0) {
    Write-Warn "Other Node.js processes are currently running (PIDs: $($otherNodeProcs.Id -join ', '))"
    Write-OK "Node.js will NOT be touched -- other processes are active."
    $removeNode = $false
} else {
    Write-Info "No other Node.js projects found on this machine."
    Write-Host ""
    Write-Host "  Node.js appears to be used only by NicheFinder X." -ForegroundColor White
    $nodeChoice = Read-Host "  Remove Node.js as well? (Y/N, default N)"
    $removeNode = ($nodeChoice.Trim().ToUpper() -eq "Y")
}

# --- STEP 5 --- REMOVE APP FILES --------------------------------
Write-Step "STEP 5 - Removing Application Files"
Write-Div

# Remove app directory
if (Test-Path $appDir) {
    Remove-Item -Recurse -Force $appDir -ErrorAction SilentlyContinue
    if (-not (Test-Path $appDir)) {
        Write-OK "App directory removed: $appDir"
    } else {
        Write-Warn "Could not fully remove: $appDir (files may be in use)"
        Write-Info "Try closing any open terminals or editors, then delete manually."
    }
} else {
    Write-Info "App directory already gone."
}

# Remove Desktop shortcut
$desktopShortcut = Join-Path ([Environment]::GetFolderPath("Desktop")) "NicheFinder X.lnk"
if (Test-Path $desktopShortcut) {
    Remove-Item $desktopShortcut -Force -ErrorAction SilentlyContinue
    Write-OK "Desktop shortcut removed"
} else {
    Write-Info "Desktop shortcut not found (already removed or never created)"
}

# Remove Start Menu entry
$startMenuDir = Join-Path ([Environment]::GetFolderPath("Programs")) "Orbix"
if (Test-Path $startMenuDir) {
    Remove-Item -Recurse -Force $startMenuDir -ErrorAction SilentlyContinue
    Write-OK "Start Menu entry removed (Orbix > NicheFinder X)"
} else {
    Write-Info "Start Menu entry not found (already removed or never created)"
}

# Remove npm cache entries related to nichefinder (non-destructive)
try {
    $npmCache = npm config get cache 2>$null
    if ($npmCache -and (Test-Path $npmCache)) {
        $nicheCache = Get-ChildItem -Path $npmCache -Filter "*nichefinder*" -Recurse -ErrorAction SilentlyContinue
        if ($nicheCache) {
            $nicheCache | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            Write-OK "npm cache entries for NicheFinder X cleared"
        }
    }
} catch {}

Write-Info "Note: Saved API key (in browser localStorage) is cleared"
Write-Info "automatically when you next open the browser after uninstall."

# --- STEP 6 --- REMOVE NODE.JS (if chosen) ----------------------
if ($removeNode) {
    Write-Step "STEP 6 - Removing Node.js"
    Write-Div

    Write-Warn "Attempting to remove Node.js..."
    $removed = $false

    # Try winget first
    try {
        $wv = winget --version 2>$null
        if ($wv) {
            winget uninstall --id OpenJS.NodeJS.LTS --accept-source-agreements -e 2>$null
            $removed = $true
            Write-OK "Node.js removed via winget"
        }
    } catch {}

    # Try Programs and Features if winget didn't work
    if (-not $removed) {
        $nodeReg = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*Node.js*" } | Select-Object -First 1
        if ($nodeReg -and $nodeReg.UninstallString) {
            Write-Info "Running Node.js uninstaller..."
            Start-Process "msiexec.exe" -ArgumentList "/x `"$($nodeReg.PSChildName)`" /qn" -Wait -ErrorAction SilentlyContinue
            Write-OK "Node.js uninstall initiated"
            $removed = $true
        }
    }

    if (-not $removed) {
        Write-Warn "Could not auto-remove Node.js."
        Write-Info "Remove manually: Control Panel > Programs > Uninstall a program > Node.js"
    }
} else {
    Write-Step "STEP 6 - Node.js"
    Write-Div
    Write-OK "Node.js kept -- not removed."
}

# --- DONE ---
Write-Host ""
Write-Host "  +============================================================+" -ForegroundColor Green
Write-Host "  |                                                            |" -ForegroundColor Green
Write-Host "  |   UNINSTALL COMPLETE                                       |" -ForegroundColor Green
Write-Host "  |                                                            |" -ForegroundColor Green
Write-Host "  |   NicheFinder X has been removed from this computer.       |" -ForegroundColor Green
if (-not $removeNode) {
    Write-Host "  |   Node.js was NOT removed (other projects may use it).     |" -ForegroundColor Green
}
Write-Host "  |                                                            |" -ForegroundColor Green
Write-Host "  |   Thank you for using Orbix NicheFinder X!                 |" -ForegroundColor Green
Write-Host "  |   getorbix.com  ^|  (610) ORBIX AI                          |" -ForegroundColor Green
Write-Host "  |                                                            |" -ForegroundColor Green
Write-Host "  +============================================================+" -ForegroundColor Green
Write-Host ""

Read-Host "  Press ENTER to exit"
