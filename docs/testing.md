# Hardware acceptance checklist

## Confirmed on the development GPD Win 1

- [x] Direct KWin session reaches Steam Gamepad UI in landscape.
- [x] Controller, keyboard, mouse mode, audio, and hardware volume buttons work.
- [x] F11 can bring Steam/Decky Quick Access above a running game.
- [x] Decky brightness events change the physical backlight.
- [x] MangoHud can show battery percentage through the Win1 Decky plugin.
- [x] Steam shutdown and reboot requests reach the operating system.
- [x] A Proton 7 game can run through the Vulkan 1.2 stack.

These results describe one development machine and are not a guarantee for
every firmware revision or game.

## Required before calling an image stable

Run `scripts/hardware-check.sh`, then verify on a clean installation:

- [ ] Ten cold boots reach Steam Gamepad UI in landscape orientation.
- [ ] Quick Access and Decky remain usable across ten game launch/exit cycles.
- [ ] Wi-Fi reconnects after boot and resume.
- [ ] Audio remains clear during navigation and gameplay.
- [ ] Twenty short sleep cycles restore Steam and the running game.
- [ ] At least one overnight lid sleep resumes with working display and input.
- [ ] Power-button sleep followed by lid close returns to sleep and stays asleep.
- [ ] Power-menu shutdown and reboot complete without a dead black session.
- [ ] MangoHud levels 0-4 work and report plausible non-zero available sensors.
- [ ] One OpenGL game and one Vulkan 1.2 game launch successfully.
- [ ] Decky is stable for one hour with each recommended plugin enabled.
- [ ] Source-install uninstall restores a normal Plasma login.
- [ ] Atomic rollback returns to the previous deployment.

Do not promote an image from prerelease while any boot, display, input, audio,
suspend, or rollback gate is failing. Logs and running processes are not proof
that visible UI and hardware behavior passed.

Installer ISO tests are destructive. Disconnect unrelated drives, identify the
target by model and capacity immediately before installation, and keep a
recovery USB plus a complete backup.
