# Cherryview DSI resume test kernel

This is an experimental, rollback-safe test for the reproduced GPD Win 1
suspend/resume black screen. It is not yet a proven fix.

## Failure being tested

The captured incident shows:

1. suspend disables DSI-1 and pipe B normally;
2. resume locks the DSI PLL and enables the transcoder;
3. the pipe B scanline does not start moving;
4. the atomic commit ends in `flip_done timed out`;
5. the GT engines remain idle and have no error state.

The patch waits for the Cherryview DSI scanline before vblank handling starts.
If it is stalled while planes are still disabled, the driver toggles the
transcoder once and checks again.

## Build

Run the `Build GPD Win 1 test kernel` workflow manually. Its default source RPM
matches Fedora `kernel-6.19.10-300.fc44`, the version on the diagnosed machine.
The workflow applies:

```text
kernel/patches/0001-drm-i915-chv-retry-stalled-dsi-transcoder-enable.patch
```

Download and extract the resulting workflow artifact on the GPD Win 1.

## Install

Confirm the currently booted kernel before replacing it:

```bash
uname -r
rpm-ostree status
```

Then stage the five-RPM replacement set:

```bash
sudo ./scripts/install-test-kernel.sh /path/to/extracted-artifact
sudo systemctl reboot
```

After reboot, verify that `uname -r` contains `win1`.

The installer does not remove the current deployment. Keep the i915 watchdog
enabled during testing so a failed resume still saves diagnostics and reboots.

## Test

Start without a running game:

1. perform one short suspend/resume;
2. perform five short suspend/resume cycles;
3. leave the device suspended for at least 30 minutes;
4. repeat with Steam running;
5. only then test while a game is running.

For every cycle, check:

```bash
sudo journalctl -b -k --no-pager |
  grep -E 'failed to start|retrying transcoder|flip_done|scanline'
```

The patch is successful only if the panel visibly returns and input remains
responsive. A clean log by itself is not proof.

## Roll back

If the new deployment does not boot, select the previous deployment in GRUB.
From a working boot, either switch immediately to the previous deployment:

```bash
sudo rpm-ostree rollback
sudo systemctl reboot
```

or remove the kernel override and return to Fedora's kernel on the next boot:

```bash
sudo ./scripts/reset-test-kernel.sh
sudo systemctl reboot
```

