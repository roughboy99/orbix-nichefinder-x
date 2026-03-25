#!/usr/bin/env bash
# ============================================================
#  ORBIX NICHEFINDER X — Auto Updater (macOS + Linux)
#  Version: 1.05
#  Orbix Automation Solutions | getorbix.com
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; GRAY='\033[0;37m'; WHITE='\033[1;37m'; NC='\033[0m'

ok()   { echo -e "  ${GREEN}[OK]${NC}  $1"; }
warn() { echo -e "  ${YELLOW}[!!]${NC}  $1"; }
fail() { echo -e "  ${RED}[XX]${NC}  $1"; }
info() { echo -e "        ${GRAY}$1${NC}"; }

clear
echo ""
echo -e "  ${CYAN}============================================================${NC}"
echo -e "  ${WHITE}  ORBIX NicheFinder X — Auto Updater${NC}"
echo -e "  ${CYAN}============================================================${NC}"
echo ""

# Find downloaded JSX
DOWNLOADS="$HOME/Downloads"
NEW_JSX="$DOWNLOADS/orbix-nichefinder-x.jsx"

if [[ ! -f "$NEW_JSX" ]]; then
  fail "orbix-nichefinder-x.jsx not found in $DOWNLOADS"
  info "Please download the update from the app first."
  exit 1
fi

# Find install directory
INSTALL_DIR=""
for candidate in \
  "$HOME/NicheFinderX" \
  "$HOME/Desktop/NicheFinderX" \
  "$HOME/Documents/NicheFinderX" \
  "/opt/NicheFinderX"; do
  if [[ -f "$candidate/src/orbix-nichefinder-x.jsx" ]]; then
    INSTALL_DIR="$candidate"
    break
  fi
done

if [[ -z "$INSTALL_DIR" ]]; then
  warn "Could not auto-detect install directory."
  read -r -p "  Enter your NicheFinderX install path: " INSTALL_DIR
fi

if [[ ! -f "$INSTALL_DIR/src/orbix-nichefinder-x.jsx" ]]; then
  fail "Invalid install directory: $INSTALL_DIR"
  info "Run install.sh first to set up the app."
  exit 1
fi

echo -e "  ${GRAY}Install directory: ${WHITE}$INSTALL_DIR${NC}"
echo ""

# Stop running server on port 5173
info "Stopping any running server on port 5173..."
lsof -ti:5173 | xargs kill -9 2>/dev/null || true
sleep 1
ok "Server stopped"

# Backup old file
info "Backing up current version..."
cp "$INSTALL_DIR/src/orbix-nichefinder-x.jsx" \
   "$INSTALL_DIR/src/orbix-nichefinder-x.jsx.bak"
ok "Backup saved as orbix-nichefinder-x.jsx.bak"

# Copy new file
info "Installing new version..."
cp "$NEW_JSX" "$INSTALL_DIR/src/orbix-nichefinder-x.jsx"
rm -f "$NEW_JSX"
ok "New version installed"

echo ""
echo -e "  ${GREEN}============================================================${NC}"
echo -e "  ${GREEN}   UPDATE COMPLETE!${NC}"
echo -e "  ${GREEN}============================================================${NC}"
echo ""

read -r -p "  Launch NicheFinder X now? (y/N): " LAUNCH
if [[ "${LAUNCH,,}" == "y" ]]; then
  LAUNCHER="$INSTALL_DIR/NicheFinderX-Start.sh"
  if [[ -f "$LAUNCHER" ]]; then
    info "Starting server..."
    bash "$LAUNCHER"
  else
    info "Run manually: cd $INSTALL_DIR && npm run dev"
  fi
fi
