#!/usr/bin/bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
decky_home="${HOME}/homebrew"
plugin_target="$decky_home/plugins/win1-performance"

if [[ ! -d "$decky_home" ]]; then
    echo "Decky Loader is not installed for ${USER}. Install Decky first." >&2
    exit 1
fi

if [[ -e "$plugin_target" ]]; then
    backup="${plugin_target}.backup-$(date +%Y%m%d-%H%M%S)"
    sudo mv "$plugin_target" "$backup"
    echo "Existing plugin moved to $backup"
fi

sudo install -d "$plugin_target"
sudo cp -a "$repo_root/decky/win1-performance/." "$plugin_target/"
sudo chown -R "$USER:$(id -gn)" "$plugin_target"

if systemctl is-active --quiet plugin_loader.service; then
    echo "Decky is running; waiting for its hot-reload watcher."
    sleep 3
fi

echo "Win1 performance/brightness plugin installed."
echo "Do not repeatedly restart Decky on this 4 GB device; reopen Quick Access first."
