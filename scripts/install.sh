#!/usr/bin/bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
target_user="${SUDO_USER:-${USER}}"
enable_autologin=true

usage() {
    echo "Usage: sudo $0 [--user USER] [--no-autologin]"
}

while (($#)); do
    case "$1" in
        --user)
            target_user="$2"
            shift 2
            ;;
        --no-autologin)
            enable_autologin=false
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 2
            ;;
    esac
done

if [[ $EUID -ne 0 ]]; then
    echo "Run this installer with sudo." >&2
    exit 1
fi

if ! getent passwd "$target_user" >/dev/null; then
    echo "Unknown user: $target_user" >&2
    exit 1
fi

if [[ ! -e /sys/class/drm/card1-DSI-1 && ! -e /sys/class/drm/card0-DSI-1 ]]; then
    echo "Warning: DSI-1 was not detected. This project only targets GPD Win 1." >&2
fi

install -d -m 0755 /usr/local/libexec /usr/local/share/wayland-sessions
install -m 0755 "$repo_root/system_files/usr/libexec/win1-gaming-session" /usr/local/libexec/
install -m 0755 "$repo_root/system_files/usr/libexec/win1-gaming-session-child" /usr/local/libexec/
install -m 0755 "$repo_root/system_files/usr/libexec/win1-lid-event-guard" /usr/local/libexec/
install -m 0755 "$repo_root/system_files/usr/libexec/win1-lid-state" /usr/local/libexec/
install -m 0755 "$repo_root/system_files/usr/libexec/win1-volume-keys" /usr/local/libexec/
sed \
    -e 's#/usr/libexec/win1-lid-event-guard#/usr/local/libexec/win1-lid-event-guard#g' \
    "$repo_root/system_files/etc/systemd/system/win1-lid-event-guard.service" \
    > /etc/systemd/system/win1-lid-event-guard.service
sed \
    -e 's#/usr/libexec/win1-volume-keys#/usr/local/libexec/win1-volume-keys#g' \
    "$repo_root/system_files/etc/systemd/system/win1-volume-keys.service" \
    > /etc/systemd/system/win1-volume-keys.service
install -d -m 0755 /etc/systemd/logind.conf.d /etc/systemd/coredump.conf.d
install -m 0644 "$repo_root/system_files/etc/systemd/logind.conf.d/20-win1-power.conf" /etc/systemd/logind.conf.d/
install -m 0644 "$repo_root/system_files/etc/systemd/coredump.conf.d/90-win1.conf" /etc/systemd/coredump.conf.d/
install -d -m 0755 /etc/systemd/system-sleep /etc/udev/rules.d
sed \
    -e 's#/usr/libexec/win1-lid-state#/usr/local/libexec/win1-lid-state#g' \
    "$repo_root/system_files/etc/systemd/system-sleep/50-win1-lid-guard" \
    > /etc/systemd/system-sleep/50-win1-lid-guard
chmod 0755 /etc/systemd/system-sleep/50-win1-lid-guard
install -m 0644 "$repo_root/system_files/etc/udev/rules.d/80-win1-usb-wakeup.rules" /etc/udev/rules.d/

sed \
    -e 's#/usr/libexec/win1-gaming-session#/usr/local/libexec/win1-gaming-session#g' \
    "$repo_root/system_files/usr/share/wayland-sessions/win1-gaming.desktop" \
    > /usr/local/share/wayland-sessions/win1-gaming.desktop

target_home="$(getent passwd "$target_user" | cut -d: -f6)"
target_uid="$(id -u "$target_user")"

if $enable_autologin; then
    install -d -m 0755 /etc/plasmalogin.conf.d
    printf '[Autologin]\nRelogin=false\nSession=win1-gaming.desktop\nUser=%s\n' "$target_user" \
        > /etc/plasmalogin.conf.d/20-win1-gaming.conf
fi

runuser -u "$target_user" -- env HOME="$target_home" XDG_RUNTIME_DIR="/run/user/$target_uid" \
    flatpak remote-add --user --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo
runuser -u "$target_user" -- env HOME="$target_home" XDG_RUNTIME_DIR="/run/user/$target_uid" \
    flatpak install --user --noninteractive --or-update flathub com.valvesoftware.Steam

steam_runtime="$(runuser -u "$target_user" -- env HOME="$target_home" \
    flatpak info --user --show-runtime com.valvesoftware.Steam)"
runtime_branch="${steam_runtime##*/}"
runuser -u "$target_user" -- env HOME="$target_home" \
    flatpak install --user --noninteractive --or-update flathub \
    "org.freedesktop.Platform.VulkanLayer.MangoHud//$runtime_branch"
runuser -u "$target_user" -- env HOME="$target_home" \
    flatpak override --user --env=MANGOHUD=1 com.valvesoftware.Steam

systemctl daemon-reload
udevadm control --reload
systemctl enable --now win1-lid-event-guard.service
systemctl enable --now win1-volume-keys.service

echo "Core gaming session installed. Reboot to enter GPD Win 1 Gaming Mode."
echo "After installing Decky Loader, run scripts/install-decky-plugin.sh."
