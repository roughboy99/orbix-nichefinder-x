#!/usr/bin/env bash
cd "$(dirname "$0")"
if [[ ! -f "uninstall.sh" ]]; then
    echo "ERROR: uninstall.sh not found in $(pwd)"
    exit 1
fi
chmod +x uninstall.sh
exec ./uninstall.sh "$@"
