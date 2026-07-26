# Architecture

## Display and session

The first-generation GPD Win has a portrait-native 720x1280 DSI panel and an
Intel Cherryview GPU. Direct Gamescope DRM scanout was tested with multiple
orientation and modifier combinations and produced black output, corrupt
blocks, failed atomic commits, or a wrongly rotated image.

An earlier revision nested Gamescope inside KWin. It provided Steam-style
layering but consumed too much CPU and memory on the Atom x7-Z8700 and made
input less responsive. The current real-device configuration therefore uses
one compositor:

```text
DSI-1 portrait-native panel
          |
       KWin DRM        rotate right, scale 1
          |
 Steam Gamepad UI     Flatpak, direct Wayland/XWayland clients
          |
       games
```

KWin owns DRM and rotates `DSI-1`; the session starts Steam with
`-gamepadui -steamos3`. A small F11 evdev service asks Steam to show Quick
Access and uses a transient KWin script to focus the appropriate Steam window
above the game. This is a compatibility implementation, not SteamOS native
Gamescope layering.

SteamOS MangoApp crashes on the tested Cherryview stack. The optional Decky
plugin controls MangoHud instead and bridges Steam's native brightness event
to a narrowly privileged sysfs writer.

## Power requests

The Flatpak Steam client writes its SteamOS reboot and shutdown sentinel files.
The session watches only those files and calls a root helper that accepts
exactly `reboot` or `poweroff`. Sudoers grants access only to that validating
helper and the validating backlight writer; no general passwordless sudo is
created.

## Suspend and lid handling

The internal USB keyboard/mouse and Xbox-compatible controller share the
Cherryview xHCI controller. Leaving xHCI wake enabled made its suspend callback
return `EBUSY`, which caused failed or duplicate resume transactions. A udev
rule disables USB wake for that controller while keeping ACPI power and lid
events.

The firmware can wake on both lid edges. A root service records lid state before
sleep and listens for the delayed evdev close event after resume. If a device
that slept while open is awakened by closing the lid, it waits for the first
resume transaction to finish, verifies that the lid is still closed, and
suspends again. Opening the lid during that wait cancels re-suspend.

This logic reduces false wakeups; it does not repair the remaining Cherryview
i915/DSI resume failure. The optional watchdog may reboot after a recognized
display-pipeline hang, at the cost of unsaved data.
