#!/usr/bin/bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
target_user="${SUDO_USER:-${USER}}"
enable_autologin=true
enable_i915_watchdog=false
force=false

usage() {
    cat <<EOF
Usage: sudo $0 [OPTIONS]

  --user USER                Gaming-mode user (default: invoking user)
  --no-autologin             Keep the normal login screen
  --enable-i915-watchdog     Force-reboot after a detected DSI pipeline hang
  --force                    Install even when DSI-1 is not currently detected
EOF
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
        --enable-i915-watchdog)
            enable_i915_watchdog=true
            shift
            ;;
        --force)
            force=true
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

if [[ ! "$target_user" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
    echo "Unsupported user name for sudoers generation: $target_user" >&2
    exit 1
fi

if [[ ! -e /sys/class/drm/card1-DSI-1 && ! -e /sys/class/drm/card0-DSI-1 ]]; then
    if ! $force; then
        echo "DSI-1 was not detected. This project only targets GPD Win 1." >&2
        echo "Re-run with --force only after verifying the exact hardware." >&2
        exit 1
    fi
    echo "Warning: installing without a detected DSI-1 panel." >&2
fi

install -d -m 0755 /usr/local/libexec /usr/local/share/wayland-sessions
install -m 0755 "$repo_root/system_files/usr/libexec/win1-gaming-session" /usr/local/libexec/
install -m 0755 "$repo_root/system_files/usr/libexec/win1-gaming-session-child" /usr/local/libexec/
install -m 0755 "$repo_root/system_files/usr/libexec/win1-power-action" /usr/local/libexec/
install -m 0755 "$repo_root/system_files/usr/libexec/win1-brightness-write" /usr/local/libexec/
install -m 0755 "$repo_root/system_files/usr/libexec/win1-decky-hotkey" /usr/local/libexec/
install -m 0644 "$repo_root/system_files/usr/libexec/win1-focus-running-game.js" /usr/local/libexec/
install -m 0644 "$repo_root/system_files/usr/libexec/win1-focus-steam-qam.js" /usr/local/libexec/
install -m 0644 "$repo_root/system_files/usr/libexec/win1-steam-background.js" /usr/local/libexec/
install -m 0755 "$repo_root/system_files/usr/libexec/win1-steam-background-freezer" /usr/local/libexec/
install -m 0755 "$repo_root/system_files/usr/libexec/win1-i915-watch" /usr/local/libexec/
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
sed \
    -e 's#/usr/libexec/win1-decky-hotkey#/usr/local/libexec/win1-decky-hotkey#g' \
    "$repo_root/system_files/etc/systemd/system/win1-decky-hotkey.service" \
    > /etc/systemd/system/win1-decky-hotkey.service
sed \
    -e 's#/usr/libexec/win1-i915-watch#/usr/local/libexec/win1-i915-watch#g' \
    "$repo_root/system_files/etc/systemd/system/win1-i915-watch.service" \
    > /etc/systemd/system/win1-i915-watch.service
install -d -m 0755 /etc/systemd/logind.conf.d /etc/systemd/coredump.conf.d /etc/modules-load.d
install -m 0644 "$repo_root/system_files/etc/systemd/logind.conf.d/20-win1-power.conf" /etc/systemd/logind.conf.d/
install -m 0644 "$repo_root/system_files/etc/systemd/coredump.conf.d/90-win1.conf" /etc/systemd/coredump.conf.d/
install -m 0644 "$repo_root/system_files/etc/modules-load.d/win1-steam-input.conf" /etc/modules-load.d/
install -d -m 0755 /etc/systemd/system-sleep /etc/udev/rules.d
sed \
    -e 's#/usr/libexec/win1-lid-state#/usr/local/libexec/win1-lid-state#g' \
    "$repo_root/system_files/etc/systemd/system-sleep/50-win1-lid-guard" \
    > /etc/systemd/system-sleep/50-win1-lid-guard
chmod 0755 /etc/systemd/system-sleep/50-win1-lid-guard
install -m 0644 "$repo_root/system_files/etc/udev/rules.d/80-win1-usb-wakeup.rules" /etc/udev/rules.d/
install -m 0644 "$repo_root/system_files/etc/udev/rules.d/70-win1-steam-input.rules" /etc/udev/rules.d/

sed \
    -e 's#/usr/libexec/win1-gaming-session#/usr/local/libexec/win1-gaming-session#g' \
    "$repo_root/system_files/usr/share/wayland-sessions/win1-gaming.desktop" \
    > /usr/local/share/wayland-sessions/win1-gaming.desktop

target_home="$(getent passwd "$target_user" | cut -d: -f6)"
target_uid="$(id -u "$target_user")"

install -d -m 0750 /etc/sudoers.d
cat > /etc/sudoers.d/win1-gaming <<EOF
# Narrow helpers used by the GPD Win 1 Steam/Decky session.
$target_user ALL=(root) NOPASSWD: /usr/local/libexec/win1-power-action *
$target_user ALL=(root) NOPASSWD: /usr/local/libexec/win1-brightness-write *
EOF
chmod 0440 /etc/sudoers.d/win1-gaming
visudo -cf /etc/sudoers.d/win1-gaming >/dev/null

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

if command -v rpm-ostree >/dev/null 2>&1; then
    current_kargs="$(rpm-ostree kargs)"
    additions=()
    grep -Fqw 'reboot=pci' <<<"$current_kargs" || additions+=(--append=reboot=pci)
    grep -Fqw 'i915.disable_power_well=0' <<<"$current_kargs" || \
        additions+=(--append=i915.disable_power_well=0)
    if ((${#additions[@]})); then
        rpm-ostree kargs "${additions[@]}"
    fi
fi

systemctl daemon-reload
udevadm control --reload
modprobe uinput
udevadm trigger --action=add --name-match=uinput
systemctl enable --now win1-lid-event-guard.service
systemctl enable --now win1-volume-keys.service
systemctl enable --now win1-decky-hotkey.service
if $enable_i915_watchdog; then
    systemctl enable --now win1-i915-watch.service
else
    systemctl disable --now win1-i915-watch.service 2>/dev/null || true
fi

echo "Core gaming session installed. Reboot to enter GPD Win 1 Gaming Mode."
echo "After installing Decky Loader, run scripts/install-decky-plugin.sh."
