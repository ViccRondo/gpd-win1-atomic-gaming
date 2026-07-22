#!/usr/bin/bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

bash -n build_files/build.sh
bash -n scripts/install.sh
bash -n scripts/install-decky-plugin.sh
bash -n scripts/uninstall.sh
bash -n scripts/hardware-check.sh
bash -n scripts/validate.sh
bash -n system_files/usr/libexec/win1-gaming-session
bash -n system_files/usr/libexec/win1-gaming-session-child
bash -n system_files/usr/libexec/win1-firstboot
bash -n system_files/etc/systemd/system-sleep/50-win1-lid-guard
python3 -m py_compile \
    system_files/usr/libexec/win1-lid-event-guard \
    system_files/usr/libexec/win1-lid-state \
    system_files/usr/libexec/win1-volume-keys \
    decky/win1-performance/main.py

python3 - <<'PY'
import json
from pathlib import Path

for path in (
    Path("decky/win1-performance/package.json"),
    Path("decky/win1-performance/package-lock.json"),
    Path("decky/win1-performance/plugin.json"),
    Path("decky/win1-performance/tsconfig.json"),
):
    json.loads(path.read_text())
PY

if command -v podman >/dev/null 2>&1; then
    podman build --help >/dev/null
fi

echo "Static validation passed."
