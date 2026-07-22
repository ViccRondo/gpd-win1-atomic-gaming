#!/usr/bin/bash
set -euo pipefail

dnf5 install -y \
    flatpak \
    kscreen \
    mangohud \
    pipewire-utils \
    python3
dnf5 clean all

cp -a /ctx/system_files/. /
install -d -m 0755 /usr/share/win1-gaming/decky
cp -a /ctx/decky/win1-performance /usr/share/win1-gaming/decky/

chmod 0755 \
    /usr/libexec/win1-firstboot \
    /usr/libexec/win1-gaming-session \
    /usr/libexec/win1-gaming-session-child \
    /usr/libexec/win1-lid-event-guard \
    /usr/libexec/win1-lid-state \
    /usr/libexec/win1-volume-keys
chmod 0755 /etc/systemd/system-sleep/50-win1-lid-guard

systemctl enable win1-firstboot.service
systemctl enable win1-lid-event-guard.service
systemctl enable win1-volume-keys.service
