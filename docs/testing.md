# Hardware acceptance checklist

Run `scripts/hardware-check.sh`, then verify each item on real hardware.

- [ ] Ten cold boots reach Steam Gamepad UI in landscape orientation.
- [ ] Quick Access Menu and Decky render above a running game.
- [ ] Controller, keyboard, mouse mode, and hardware volume buttons work.
- [ ] Wi-Fi reconnects after boot and resume.
- [ ] Audio remains clear while navigating and while playing a game.
- [ ] Lid close suspends and resume restores Steam and the current game.
- [ ] Power-button sleep followed by lid close returns to sleep and remains
      asleep until the lid is opened again.
- [ ] Power menu shutdown and reboot complete without leaving a black session.
- [ ] MangoHud levels 0-4 switch from the Decky plugin.
- [ ] Battery percentage and CPU temperature are plausible and non-zero.
- [ ] At least one OpenGL game and one Vulkan 1.2 game launch successfully.
- [ ] `bootc rollback` returns to the previous deployment.

Do not promote the image from prerelease while any boot, display, input, audio,
or rollback check is failing.

Installer ISO tests are destructive. Disconnect unrelated drives, verify the
target device immediately before booting the installer, and keep a recovery
USB plus a backup of all user data.
