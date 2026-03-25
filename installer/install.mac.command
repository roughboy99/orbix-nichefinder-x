#!/usr/bin/env bash
# ============================================================
#  ORBIX NICHEFINDER X — macOS Installer
#  Double-click this file in Finder to install
# ============================================================

# Move to the directory containing this script
cd "$(dirname "$0")"

# Check install.sh is alongside this file
if [[ ! -f "install.sh" ]]; then
  osascript -e 'display alert "install.sh not found" message "Please make sure install.sh and install.mac.command are in the same folder, then try again." as critical'
  exit 1
fi

chmod +x install.sh
./install.sh
