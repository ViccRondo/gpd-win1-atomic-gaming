# GPD Win 1 Atomic Gaming

Experimental community adaptation that gives the first-generation GPD Win a
controller-first Steam gaming session on Fedora Atomic/Bazzite-derived systems.

The project is based on a configuration validated on a real GPD Win 1 with an
Intel Atom x7-Z8700, 4 GB RAM, 64 GB storage, a portrait-native 720x1280 DSI
panel, and Vulkan 1.2 graphics.

> **Prerelease software:** this is not an official GPD, Valve, SteamOS, Fedora,
> Universal Blue, or Bazzite project. Keep a rollback deployment available.

## What works

- Landscape Steam Gamepad UI on the portrait-native internal display.
- Real Gamescope layering: Quick Access Menu and Decky appear over games.
- KWin outer compositor plus fullscreen nested Gamescope at 1280x720.
- Controller input, audio, hardware volume buttons, shutdown, and poweroff.
- Reliable s2idle after disabling broken xHCI wake; state-aware lid re-suspend
  keeps an already sleeping handheld asleep when the lid is later closed.
- Optional Decky plugin for MangoHud performance levels, battery percentage,
  and CPU temperature.
- Atomic OCI image builds, GHCR publishing, OIDC signing, and release metadata.

## Why two compositors?

Direct Gamescope DRM scanout does not rotate the Cherryview DSI panel reliably.
KWin handles physical rotation and scaling; nested Gamescope supplies Steam's
gaming-mode compositor model. See [architecture.md](docs/architecture.md).

```text
DSI-1 portrait panel
        |
     KWin DRM          rotation and scaling
        |
  nested Gamescope     1280x720 SteamOS-style layers
        |
 Steam Gamepad UI + games + Decky
```

## Install on an existing Fedora Kinoite system

Review the scripts first, ensure a rollback or backup exists, then run:

```bash
git clone https://github.com/ViccRondo/gpd-win1-atomic-gaming.git
cd gpd-win1-atomic-gaming
sudo ./scripts/install.sh --user "$USER"
sudo systemctl reboot
```

The installer does not add passwordless sudo and does not copy Steam, Wi-Fi, or
SSH credentials. After installing Decky Loader, install the optional plugin:

```bash
./scripts/install-decky-plugin.sh
```

## Bootable container image

Every main-branch build publishes an experimental image to:

```text
ghcr.io/viccrondo/gpd-win1-atomic-gaming:latest
```

Rebasing is intentionally documented as experimental until a clean install has
passed the full hardware checklist:

```bash
sudo bootc switch ghcr.io/viccrondo/gpd-win1-atomic-gaming:latest
sudo systemctl reboot
```

Use the immutable digest recorded in each GitHub Release for reproducible
deployment. Atomic rollback remains available with `sudo bootc rollback`.

## Releases and disk images

`Build and release image` builds the bootc OCI image, pushes versioned and
commit tags to GHCR, signs the digest with GitHub OIDC, and creates a prerelease
when a `v*` tag is pushed.

`Build installable disk image` is a manual workflow that converts a published
OCI tag into `raw`, `qcow2`, or `anaconda-iso` output with
bootc-image-builder. It can retain the result as a 14-day Actions artifact or
split it into sub-2 GB parts and attach them to an existing GitHub Release.
Verify `SHA256SUMS` after recombining the parts.

## Current limitations

- Native SteamOS MangoApp crashes on this graphics stack; the project ships an
  optional Decky-controlled MangoHud overlay instead.
- Suspend/resume is validated for power-button sleep, lid sleep, and the
  power-sleep-then-close-lid sequence, but still needs longer soak testing.
- Modern Proton versions may require Vulkan 1.3; Proton 7 or OpenGL is needed
  for some games.
- The image is a prerelease until clean-install and rollback testing completes.

Read [known issues](docs/known-issues.md), the
[hardware checklist](docs/testing.md), and [recovery steps](docs/recovery.md)
before installing.

## Contributing

Small upstreamable fixes are preferred over permanent binary patches. Useful
targets include MangoHud battery-name detection, MangoApp Cherryview crashes,
Gamescope portrait-panel handling, and suspend/resume stability.

Licensed under Apache-2.0. Components installed by the image retain their own
upstream licenses and trademarks.
