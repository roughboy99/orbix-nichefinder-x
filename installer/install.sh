#!/usr/bin/env bash
# ============================================================
#  ORBIX NICHEFINDER X — Universal Installer
#  Version: 1.05  |  macOS + Linux
#  Orbix Automation Solutions | getorbix.com
#  (610) ORBIX AI — (610) 672-4924
# ============================================================
#  Usage:
#    chmod +x install.sh && ./install.sh
#  Or on macOS double-click install.mac.command
# ============================================================

set -e

# ── COLORS ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BLUE='\033[0;34m'; GRAY='\033[0;37m'
GOLD='\033[0;33m'; WHITE='\033[1;37m'; NC='\033[0m'
BOLD='\033[1m'

step()  { echo -e "\n  >>> $1"; }
ok()    { echo -e "  [OK]  $1"; }
warn()  { echo -e "  [!!]  $1"; }
fail()  { echo -e "  [XX]  $1"; }
info()  { echo -e "        $1"; }
div()   { echo -e "  ="; }

# ── DETECT OS ───────────────────────────────────────────────
detect_os() {
  if [[ "$(uname)" == "Darwin" ]]; then
    OS="macos"
    OS_LABEL="macOS"
  elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS="linux"
    OS_LABEL="${PRETTY_NAME:-Linux}"
    if command -v apt-get &>/dev/null; then
      PKG_MGR="apt"
    elif command -v dnf &>/dev/null; then
      PKG_MGR="dnf"
    elif command -v yum &>/dev/null; then
      PKG_MGR="yum"
    elif command -v pacman &>/dev/null; then
      PKG_MGR="pacman"
    elif command -v zypper &>/dev/null; then
      PKG_MGR="zypper"
    else
      PKG_MGR="unknown"
    fi
  else
    fail "Unsupported operating system."
    exit 1
  fi
}

# ── HEADER ──────────────────────────────────────────────────
clear
echo ""
echo -e "  ╔══════════════════════════════════════════════════════════╗"
echo -e "  ║                                                          ║"
echo -e "  ║   ORBIX NicheFinder X   —   Installer v1.05              ║"
echo -e "  ║   The perfect companion to Andy Hafell's Content Mate   ║"
echo -e "  ║                                                          ║"
echo -e "  ║   getorbix.com  |  (610) ORBIX AI  |  twitterapi.io      ║"
echo -e "  ╚══════════════════════════════════════════════════════════╝"
echo ""

detect_os
echo -e "  Detected OS: ${OS_LABEL}"
[[ "$OS" == "linux" ]] && echo -e "  Package manager: ${PKG_MGR}"
echo ""

# ── STEP 1 — INSTALL LOCATION ───────────────────────────────
step "STEP 1 — Installation Location"
div

DEFAULT_DIR="$HOME/NicheFinderX"
echo -e "  Default install location: ${DEFAULT_DIR}"
echo ""
read -r -p "  Press ENTER to accept or type a custom path: " CUSTOM_PATH
APP_DIR="${CUSTOM_PATH:-$DEFAULT_DIR}"
APP_DIR="${APP_DIR/#\~\/$HOME\/}"  # expand ~ manually
ok "Install location: $APP_DIR"

# ── STEP 2 — CHECK / INSTALL NODE.JS ────────────────────────
step "STEP 2 — Checking Node.js"
div

NODE_OK=false
NODE_VER=""

if command -v node &>/dev/null; then
  NODE_VER=$(node --version 2>/dev/null | tr -d 'v')
  NODE_MAJOR=$(echo "$NODE_VER" | cut -d. -f1)
  if [[ "$NODE_MAJOR" -ge 18 ]]; then
    ok "Node.js v${NODE_VER} found (>=18 required)"
    NODE_OK=true
  else
    warn "Node.js v${NODE_VER} found but version 18+ is required"
  fi
fi

if [[ "$NODE_OK" == false ]]; then
  warn "Node.js 18+ not found. Attempting automatic install..."
  echo ""

  if [[ "$OS" == "macos" ]]; then
    # macOS — try Homebrew first
    if command -v brew &>/dev/null; then
      info "Installing Node.js via Homebrew..."
      brew install node
    else
      info "Homebrew not found. Installing Homebrew first..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      # Add brew to PATH for Apple Silicon
      if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
      brew install node
    fi

  elif [[ "$OS" == "linux" ]]; then
    # Linux — use NodeSource
    info "Installing Node.js 20 LTS via NodeSource..."
    case "$PKG_MGR" in
      apt)
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - 2>/dev/null
        sudo apt-get install -y nodejs
        ;;
      dnf)
        curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash - 2>/dev/null
        sudo dnf install -y nodejs
        ;;
      yum)
        curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash - 2>/dev/null
        sudo yum install -y nodejs
        ;;
      pacman)
        sudo pacman -Sy --noconfirm nodejs npm
        ;;
      zypper)
        sudo zypper install -y nodejs20 npm20
        ;;
      *)
        fail "Unknown package manager. Please install Node.js 18+ manually from nodejs.org"
        fail "Then re-run this installer."
        exit 1
        ;;
    esac
  fi

  # Verify
  if command -v node &>/dev/null; then
    NODE_VER=$(node --version | tr -d 'v')
    ok "Node.js v${NODE_VER} installed"
    NODE_OK=true
  else
    fail "Node.js installation failed. Please install manually from nodejs.org"
    exit 1
  fi
fi

# Verify npm
if ! command -v npm &>/dev/null; then
  fail "npm not found. Please reinstall Node.js from nodejs.org"
  exit 1
fi
NPM_VER=$(npm --version 2>/dev/null)
ok "npm v${NPM_VER} ready"

# ── STEP 3 — CREATE DIRECTORY ────────────────────────────────
step "STEP 3 — Creating Application Directory"
div

if [[ -d "$APP_DIR" ]]; then
  warn "Directory already exists: $APP_DIR"
  read -r -p "  Overwrite existing installation? (y/N): " CONFIRM
  if [[ "${CONFIRM,,}" != "y" ]]; then
    info "Installation cancelled."
    exit 0
  fi
  rm -rf "$APP_DIR"
fi

mkdir -p "$APP_DIR/src"
mkdir -p "$APP_DIR/public"
ok "Directory created: $APP_DIR"

# ── STEP 4 — WRITE APP FILES ─────────────────────────────────
step "STEP 4 — Writing Application Files"
div

# package.json
cat > "$APP_DIR/package.json" << 'PKGJSON'
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
PKGJSON
ok "package.json written"

# vite.config.js
cat > "$APP_DIR/vite.config.js" << 'VITECONF'
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
VITECONF
ok "vite.config.js written"

# index.html
cat > "$APP_DIR/index.html" << 'INDEXHTML'
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
INDEXHTML
ok "index.html written"

# favicon
cat > "$APP_DIR/public/favicon.svg" << 'FAVICON'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <rect width="32" height="32" rx="6" fill="#0D1117"/>
  <path d="M8 8h6l4 6 4-6h6l-7 10 7 10h-6l-4-6-4 6H8l7-10z" fill="#2B5BA8"/>
</svg>
FAVICON

# src/main.jsx
cat > "$APP_DIR/src/main.jsx" << 'MAINJSX'
import React from 'react'
import ReactDOM from 'react-dom/client'
import NicheFinderX from './orbix-nichefinder-x.jsx'
ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode><NicheFinderX /></React.StrictMode>
)
MAINJSX
ok "src/main.jsx written"

# Extract embedded JSX (gzip+base64)
info "Extracting orbix-nichefinder-x.jsx..."
PAYLOAD="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"
echo "$PAYLOAD" | base64 -d | gunzip > "$APP_DIR/src/orbix-nichefinder-x.jsx"
JSX_SIZE=$(wc -c < "$APP_DIR/src/orbix-nichefinder-x.jsx")
ok "orbix-nichefinder-x.jsx extracted (${JSX_SIZE} bytes)"

# ── STEP 5 — NPM INSTALL ─────────────────────────────────────
step "STEP 5 — Installing Dependencies"
div
info "Running npm install (this may take 30-60 seconds)..."
echo ""

cd "$APP_DIR"
npm install 2>&1 | tail -5
ok "npm packages installed"

# ── STEP 6 — CREATE LAUNCHER ─────────────────────────────────
step "STEP 6 — Creating Launcher Script"
div

LAUNCHER="$APP_DIR/NicheFinderX-Start.sh"
cat > "$LAUNCHER" << LAUNCHSCRIPT
#!/usr/bin/env bash
echo ""
echo "  Orbix NicheFinder X v1.05 — Starting..."
echo "  Vite will open your browser automatically."
echo "  If port 5173 is busy, Vite picks the next free port."
echo "  Check the output below for the actual URL."
echo "  Press Ctrl+C to stop the server"
echo ""
cd "$APP_DIR"
npm run dev
LAUNCHSCRIPT

chmod +x "$LAUNCHER"
ok "Launcher created: NicheFinderX-Start.sh"

# ── STEP 7 — DESKTOP SHORTCUT ────────────────────────────────
step "STEP 7 — Creating Desktop Shortcut"
div

if [[ "$OS" == "macos" ]]; then
  # macOS: create a .command file (double-clickable in Finder)
  DESKTOP="$HOME/Desktop"
  SHORTCUT="$DESKTOP/NicheFinder X.command"
  cat > "$SHORTCUT" << MACSHORTCUT
#!/usr/bin/env bash
cd "$APP_DIR"
npm run dev
MACSHORTCUT
  chmod +x "$SHORTCUT"
  # Remove quarantine so Finder can open it
  xattr -d com.apple.quarantine "$SHORTCUT" 2>/dev/null || true
  ok "Desktop shortcut created: ~/Desktop/NicheFinder X.command"

elif [[ "$OS" == "linux" ]]; then
  # Linux: create a .desktop file
  DESKTOP_DIR="$HOME/.local/share/applications"
  mkdir -p "$DESKTOP_DIR"
  cat > "$DESKTOP_DIR/nichefinder-x.desktop" << DESKTOPFILE
[Desktop Entry]
Version=1.05
Type=Application
Name=NicheFinder X
Comment=Orbix NicheFinder X — Niche Influencer Finder
Exec=bash -c "cd '$APP_DIR' && npm run dev"
Icon=$APP_DIR/public/favicon.svg
Terminal=true
Categories=Network;WebBrowser;
Keywords=influencer;niche;twitter;x;
DESKTOPFILE
  chmod +x "$DESKTOP_DIR/nichefinder-x.desktop"
  ok "Application menu entry created"

  # Also put a launcher on Desktop if it exists
  if [[ -d "$HOME/Desktop" ]]; then
    cp "$DESKTOP_DIR/nichefinder-x.desktop" "$HOME/Desktop/NicheFinder X.desktop"
    chmod +x "$HOME/Desktop/NicheFinder X.desktop"
    ok "Desktop shortcut created: ~/Desktop/NicheFinder X.desktop"
  fi
fi

# ── DONE ─────────────────────────────────────────────────────
echo ""
echo -e "  ╔══════════════════════════════════════════════════════════╗"
echo -e "  ║                                                          ║"
echo -e "  ║    INSTALLATION COMPLETE                                ║"
echo -e "  ║                                                          ║"
echo -e "  ║   Installed to: ${APP_DIR}"
echo -e "  ║                                                          ║"
echo -e "  ║   TO LAUNCH:                                           ║"
if [[ "$OS" == "macos" ]]; then
echo -e "  ║   • Double-click 'NicheFinder X.command' on Desktop    ║"
else
echo -e "  ║   • Click NicheFinder X in your app menu / Desktop     ║"
fi
echo -e "  ║   • Or run: ${LAUNCHER}"
echo -e "  ${CYAN}║${NC}   ${CYAN}• Vite opens your browser automatically                    ${CYAN}║${NC}"
echo -e "  ║                                                          ║"
echo -e "  ║   Get your API key: twitterapi.io?ref=roughboy666       ║"
echo -e "  ║                                                          ║"
echo -e "  ╚══════════════════════════════════════════════════════════╝"
echo ""

read -r -p "  Launch NicheFinder X now? (y/N): " LAUNCH
if [[ "${LAUNCH,,}" == "y" ]]; then
  info "Starting server — Vite will open your browser automatically"
  open "$LAUNCHER" 2>/dev/null || bash "$LAUNCHER"
fi

echo ""
echo -e "  Thank you for using Orbix NicheFinder X!"
echo -e "  getorbix.com  |  (610) ORBIX AI"
echo ""
