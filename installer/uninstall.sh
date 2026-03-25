#!/usr/bin/env bash
# ============================================================
#  ORBIX NICHEFINDER X - Uninstaller v1.07
#  macOS + Linux
#  Orbix Automation Solutions | getorbix.com
# ============================================================

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; GRAY='\033[0;37m'; WHITE='\033[1;37m'; NC='\033[0m'

ok()   { echo -e "  ${GREEN}[OK]${NC}  $1"; }
warn() { echo -e "  ${YELLOW}[!!]${NC}  $1"; }
fail() { echo -e "  ${RED}[XX]${NC}  $1"; }
info() { echo -e "        ${GRAY}$1${NC}"; }
step() { echo -e "\n${YELLOW}  >>> $1${NC}"; }
div()  { echo -e "  ${GRAY}================================================================${NC}"; }

# ── HEADER ───────────────────────────────────────────────────
clear
echo ""
echo -e "  ${RED}+============================================================+${NC}"
echo -e "  ${RED}|${NC}                                                            ${RED}|${NC}"
echo -e "  ${RED}|${NC}   ${WHITE}ORBIX NicheFinder X - Uninstaller v1.07${NC}               ${RED}|${NC}"
echo -e "  ${RED}|${NC}   ${YELLOW}This will remove NicheFinder X from your computer.${NC}    ${RED}|${NC}"
echo -e "  ${RED}|${NC}                                                            ${RED}|${NC}"
echo -e "  ${RED}+============================================================+${NC}"
echo ""

# ── STEP 1 - FIND INSTALLATION ───────────────────────────────
step "STEP 1 - Finding Installation"
div

CANDIDATES=(
    "$HOME/NicheFinderX"
    "$HOME/Desktop/NicheFinderX"
    "$HOME/Documents/NicheFinderX"
    "/opt/NicheFinderX"
)

APP_DIR=""
for c in "${CANDIDATES[@]}"; do
    if [[ -f "$c/src/orbix-nichefinder-x.jsx" ]]; then
        APP_DIR="$c"
        break
    fi
done

if [[ -z "$APP_DIR" ]]; then
    warn "Could not auto-detect NicheFinder X installation."
    echo ""
    read -r -p "  Enter install path manually (or press ENTER to cancel): " MANUAL
    if [[ -z "$MANUAL" ]]; then
        info "Uninstall cancelled."
        exit 0
    fi
    if [[ -f "$MANUAL/src/orbix-nichefinder-x.jsx" ]]; then
        APP_DIR="$MANUAL"
    else
        fail "NicheFinder X not found at: $MANUAL"
        info "Nothing was removed."
        exit 1
    fi
fi

ok "Found installation at: $APP_DIR"

# ── STEP 2 - CONFIRM ─────────────────────────────────────────
step "STEP 2 - Confirm Uninstall"
div

echo ""
echo -e "  ${WHITE}The following will be PERMANENTLY removed:${NC}"
echo -e "  ${YELLOW}  - App directory: $APP_DIR${NC}"
echo -e "  ${YELLOW}  - Desktop shortcut / application menu entry${NC}"
echo -e "  ${YELLOW}  - Launcher script (NicheFinderX-Start.sh)${NC}"
echo -e "  ${GREEN}  - Node.js: NOT removed unless you choose to below${NC}"
echo ""
read -r -p "  Type YES to confirm uninstall (anything else cancels): " CONFIRM
if [[ "$CONFIRM" != "YES" ]]; then
    info "Uninstall cancelled. Nothing was removed."
    exit 0
fi

# ── STEP 3 - STOP RUNNING SERVER ─────────────────────────────
step "STEP 3 - Stopping Any Running Server"
div

STOPPED=false
for PORT in 5173 5174 5175 5176 5177; do
    PID=$(lsof -ti:"$PORT" 2>/dev/null || true)
    if [[ -n "$PID" ]]; then
        PROC_NAME=$(ps -p "$PID" -o comm= 2>/dev/null || true)
        if [[ "$PROC_NAME" == "node" ]] || [[ "$PROC_NAME" == "node.js" ]]; then
            kill -9 "$PID" 2>/dev/null || true
            ok "Stopped Node.js server on port $PORT (PID $PID)"
            STOPPED=true
        fi
    fi
done
if [[ "$STOPPED" == false ]]; then
    info "No running NicheFinder X server detected."
fi
sleep 1

# ── STEP 4 - CHECK FOR OTHER NODE.JS PROJECTS ────────────────
step "STEP 4 - Checking for Other Node.js Projects"
div

info "Scanning for other node_modules directories..."
info "(This protects your other Node.js projects from being affected)"
echo ""

# Search common project roots
OTHER_NODE=()
SEARCH_ROOTS=("$HOME" "$HOME/projects" "$HOME/dev" "$HOME/code" "$HOME/work" "/usr/local/lib")
for ROOT in "${SEARCH_ROOTS[@]}"; do
    if [[ -d "$ROOT" ]]; then
        while IFS= read -r -d '' dir; do
            # Skip the NicheFinder installation itself
            if [[ "$dir" != "$APP_DIR"* ]]; then
                OTHER_NODE+=("$(dirname "$dir")")
            fi
        done < <(find "$ROOT" -maxdepth 5 -name "node_modules" -type d -print0 2>/dev/null | head -c 4096)
    fi
done

# Check global npm packages
GLOBAL_PKGS=""
if command -v npm &>/dev/null; then
    GLOBAL_PKGS=$(npm list -g --depth=0 2>/dev/null | grep -v "^[/\\]" | grep -v "^npm@" | grep "@@" | head -5 || true)
fi

# Check other running node processes
OTHER_PROCS=$(pgrep -x "node" 2>/dev/null | grep -v "^$$" || true)

REMOVE_NODE=false
if [[ "${#OTHER_NODE[@]}" -gt 0 ]]; then
    warn "Found ${#OTHER_NODE[@]} other Node.js project(s):"
    for proj in "${OTHER_NODE[@]:0:5}"; do
        info "  $proj"
    done
    [[ "${#OTHER_NODE[@]}" -gt 5 ]] && info "  ... and $((${#OTHER_NODE[@]} - 5)) more"
    echo ""
    ok "Node.js will NOT be removed -- other projects depend on it."
elif [[ -n "$GLOBAL_PKGS" ]]; then
    warn "Global npm packages are installed:"
    echo "$GLOBAL_PKGS" | while read -r pkg; do info "  $pkg"; done
    ok "Node.js will NOT be removed -- global packages present."
elif [[ -n "$OTHER_PROCS" ]]; then
    warn "Other Node.js processes are currently running (PIDs: $OTHER_PROCS)"
    ok "Node.js will NOT be removed -- other processes active."
else
    info "No other Node.js projects found on this machine."
    echo ""
    read -r -p "  Node.js appears to only be used by NicheFinder X. Remove it too? (y/N): " REMOVE_CHOICE
    [[ "${REMOVE_CHOICE,,}" == "y" ]] && REMOVE_NODE=true
fi

# ── STEP 5 - REMOVE APP FILES ────────────────────────────────
step "STEP 5 - Removing Application Files"
div

# App directory
if [[ -d "$APP_DIR" ]]; then
    rm -rf "$APP_DIR"
    ok "App directory removed: $APP_DIR"
else
    info "App directory already gone."
fi

# macOS Desktop .command shortcut
if [[ "$(uname)" == "Darwin" ]]; then
    DESKTOP_SC="$HOME/Desktop/NicheFinder X.command"
    if [[ -f "$DESKTOP_SC" ]]; then
        rm -f "$DESKTOP_SC"
        ok "Desktop shortcut removed"
    else
        info "Desktop shortcut not found."
    fi
fi

# Linux .desktop file
if [[ "$(uname)" == "Linux" ]]; then
    DESKTOP_FILE="$HOME/.local/share/applications/nichefinder-x.desktop"
    if [[ -f "$DESKTOP_FILE" ]]; then
        rm -f "$DESKTOP_FILE"
        ok "Application menu entry removed"
    fi
    DESKTOP_SC="$HOME/Desktop/NicheFinder X.desktop"
    if [[ -f "$DESKTOP_SC" ]]; then
        rm -f "$DESKTOP_SC"
        ok "Desktop shortcut removed"
    fi
fi

info "Note: Browser localStorage (saved API key) clears automatically"
info "      on next browser session since the app origin no longer exists."

# ── STEP 6 - REMOVE NODE.JS (if chosen) ──────────────────────
step "STEP 6 - Node.js"
div

if [[ "$REMOVE_NODE" == true ]]; then
    warn "Removing Node.js..."
    if [[ "$(uname)" == "Darwin" ]]; then
        if command -v brew &>/dev/null; then
            brew uninstall node 2>/dev/null || true
            ok "Node.js removed via Homebrew"
        else
            warn "Could not auto-remove. Uninstall manually from nodejs.org"
        fi
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if command -v apt-get &>/dev/null; then
            sudo apt-get remove -y nodejs 2>/dev/null && ok "Node.js removed via apt"
        elif command -v dnf &>/dev/null; then
            sudo dnf remove -y nodejs 2>/dev/null && ok "Node.js removed via dnf"
        elif command -v pacman &>/dev/null; then
            sudo pacman -R --noconfirm nodejs npm 2>/dev/null && ok "Node.js removed via pacman"
        else
            warn "Could not auto-remove Node.js. Remove manually."
        fi
    fi
else
    ok "Node.js kept -- not removed."
fi

# ── DONE ─────────────────────────────────────────────────────
echo ""
echo -e "  ${GREEN}+============================================================+${NC}"
echo -e "  ${GREEN}|                                                            |${NC}"
echo -e "  ${GREEN}|   UNINSTALL COMPLETE                                       |${NC}"
echo -e "  ${GREEN}|                                                            |${NC}"
echo -e "  ${GREEN}|   NicheFinder X has been removed from your computer.       |${NC}"
[[ "$REMOVE_NODE" == false ]] && \
echo -e "  ${GREEN}|   Node.js was NOT removed (other projects may use it).     |${NC}"
echo -e "  ${GREEN}|                                                            |${NC}"
echo -e "  ${GREEN}|   Thank you for using Orbix NicheFinder X!                 |${NC}"
echo -e "  ${GREEN}|   getorbix.com  |  (610) ORBIX AI                          |${NC}"
echo -e "  ${GREEN}|                                                            |${NC}"
echo -e "  ${GREEN}+============================================================+${NC}"
echo ""
