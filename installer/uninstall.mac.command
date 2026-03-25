#!/usr/bin/env bash
cd "$(dirname "$0")"
if [[ ! -f "uninstall.sh" ]]; then
    osascript -e 'display alert "uninstall.sh not found" message "Please make sure uninstall.sh and uninstall.mac.command are in the same folder." as critical'
    exit 1
fi
chmod +x uninstall.sh
./uninstall.sh
