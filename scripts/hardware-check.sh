#!/usr/bin/bash
set -u

failures=0

check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        printf 'PASS  %s\n' "$description"
    else
        printf 'FAIL  %s\n' "$description"
        failures=$((failures + 1))
    fi
}

check "DSI-1 internal panel" test -e /sys/class/drm/card0-DSI-1 || \
    check "DSI-1 internal panel on card1" test -e /sys/class/drm/card1-DSI-1
check "Cherryview Intel GPU" sh -c "lspci -nn | grep -qi 'Intel.*Graphics'"
check "KWin Wayland installed" command -v kwin_wayland
check "PipeWire control installed" command -v wpctl
check "Steam Flatpak installed" flatpak info com.valvesoftware.Steam
check "Volume GPIO input" test -e /dev/input/by-path/platform-gpio-keys.1.auto-event
check "Battery device" test -e /sys/class/power_supply/max170xx_battery
check "Vulkan available" sh -c "vulkaninfo --summary 2>/dev/null | grep -q 'Vulkan Instance Version'"
check "Brightness backlight" sh -c \
    "compgen -G '/sys/class/backlight/*/brightness' >/dev/null"

if command -v rpm-ostree >/dev/null 2>&1; then
    check "reboot=pci kernel argument" sh -c "rpm-ostree kargs | grep -Fqw reboot=pci"
    check "i915 power-well workaround" sh -c \
        "rpm-ostree kargs | grep -Fqw i915.disable_power_well=0"
fi

exit "$failures"
