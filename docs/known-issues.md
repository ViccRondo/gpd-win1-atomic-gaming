# Known issues

- This is an experimental community adaptation, not an official GPD, Valve,
  Fedora, Universal Blue, Bazzite, or SteamOS image.
- Long or repeated suspend/resume cycles can still leave the Cherryview i915
  display black or freeze the whole machine. Lid guards reduce one firmware
  wake race but do not fix the kernel graphics defect. Save the game before
  sleep whenever possible.
- HLTB for Deck `v2.0.9` caused a reproducible delayed whole-machine freeze on
  the 4 GB test device, including when it was hot-loaded without restarting
  Decky. Do not install that version. Quarantine it using `docs/recovery.md`.
- Direct KWin is more responsive than the previously tested nested Gamescope
  setup. The tradeoff is that native SteamOS Gamescope layers and MangoApp are
  unavailable. F11 + KWin focus and Decky + MangoHud provide substitutes.
- SteamOS MangoApp crashes on the tested graphics stack. Use the optional Win1
  Decky performance plugin.
- The GPU exposes Vulkan 1.2 rather than the Vulkan 1.3 expected by many current
  Proton releases. Some games need Proton 7 or an OpenGL fallback; others
  cannot run on this GPU at all.
- Hardware volume keys change PipeWire volume, but a SteamOS-style volume OSD
  is not guaranteed in every game.
- Some thermal sensor files are absent or return zero on this platform. The
  plugin can only display data exported by the kernel.
- The internal 64 GB storage is restrictive. Keep Steam Linux runtimes; remove
  unused games and redundant Proton versions carefully.
- The public `v0.1.0` image uses the older nested-Gamescope design. Build and
  signature success are not clean-install or hardware-acceptance proof.
