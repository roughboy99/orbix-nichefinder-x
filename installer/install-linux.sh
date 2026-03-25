#!/usr/bin/env bash
# ============================================================
#  ORBIX NICHEFINDER X — Linux Installer  
#  Alias for install.sh — both are identical
# ============================================================
cd "$(dirname "$0")"
if [[ ! -f "install.sh" ]]; then
  echo "ERROR: install.sh not found in $(pwd)"
  echo "Please place install.sh and install-linux.sh in the same folder."
  exit 1
fi
chmod +x install.sh
exec ./install.sh "$@"
