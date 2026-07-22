#!/usr/bin/bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
decky_home="${HOME}/homebrew"
plugin_target="$decky_home/plugins/win1-performance"

if [[ ! -d "$decky_home" ]]; then
    echo "Decky Loader is not installed for ${USER}. Install Decky first." >&2
    exit 1
fi

rm -rf "$plugin_target"
install -d "$plugin_target"
cp -a "$repo_root/decky/win1-performance/." "$plugin_target/"

if systemctl is-active --quiet plugin_loader.service; then
    sudo systemctl restart plugin_loader.service
fi

echo "Win1 performance plugin installed."
