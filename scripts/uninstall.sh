#!/usr/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run this uninstaller with sudo." >&2
    exit 1
fi

systemctl disable --now win1-volume-keys.service 2>/dev/null || true
systemctl disable --now win1-lid-event-guard.service 2>/dev/null || true
rm -f /etc/systemd/system/win1-volume-keys.service
rm -f /etc/systemd/system/win1-lid-event-guard.service
rm -f /etc/systemd/system-sleep/50-win1-lid-guard
rm -f /etc/udev/rules.d/80-win1-usb-wakeup.rules
rm -f /etc/systemd/logind.conf.d/20-win1-power.conf
rm -f /etc/systemd/coredump.conf.d/90-win1.conf
rm -f /etc/plasmalogin.conf.d/20-win1-gaming.conf
rm -f /usr/local/libexec/win1-gaming-session
rm -f /usr/local/libexec/win1-gaming-session-child
rm -f /usr/local/libexec/win1-lid-event-guard
rm -f /usr/local/libexec/win1-lid-state
rm -f /usr/local/libexec/win1-volume-keys
rm -f /usr/local/share/wayland-sessions/win1-gaming.desktop
systemctl daemon-reload
udevadm control --reload

echo "GPD Win 1 gaming-mode system files removed. User Steam data was preserved."
