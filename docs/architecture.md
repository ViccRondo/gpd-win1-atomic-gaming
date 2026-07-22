# Architecture

The first-generation GPD Win has a portrait-native 720x1280 DSI panel and an
Intel Cherryview GPU. Direct Gamescope DRM scanout was tested with multiple
orientation and modifier combinations and produced failed atomic commits,
black output, corrupt blocks, or an incorrectly rotated image.

The working design uses two compositors:

1. KWin owns DRM, rotates `DSI-1` to landscape, and applies 1.8x scaling.
2. Gamescope runs nested and fullscreen at 1280x720.
3. Steam Gamepad UI and games run inside Gamescope.

This preserves Steam's real Quick Access Menu layer over games while keeping
physical scanout on the compositor that works with the panel.

The SteamOS MangoApp process is intentionally disabled. Both the Fedora host
MangoApp and the Flatpak 0.8.4 binary crashed in the tested graphics stack.
The optional Decky plugin controls injected MangoHud instead.

## Suspend and lid handling

The internal USB keyboard/mouse and Xbox-compatible controller share the
Cherryview xHCI controller. Leaving xHCI wake enabled made its suspend callback
return `EBUSY`, which caused failed or duplicate Steam resume notifications.
The image disables USB wake for that controller while retaining the ACPI power
button and lid as wake sources.

The firmware wakes on both lid edges. A small root service records the lid
state before sleep and listens for the delayed evdev close event after resume.
If a device that slept while open is awakened by closing the lid, it waits for
the first resume transaction to finish, verifies that the lid is still closed,
and suspends again. Opening the lid during that wait cancels the re-suspend.
