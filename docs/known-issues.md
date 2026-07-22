# Known issues

- This is an experimental community adaptation, not an official GPD, Valve,
  Fedora, Universal Blue, or Bazzite image.
- Native MangoApp currently crashes on the tested Cherryview stack. Use the
  optional Win1 Decky performance plugin.
- Repeated failed suspend attempts caused a game and Steam WebHelper to hang
  during bring-up. The validated xHCI wake policy prevents that failure, but
  long-running in-game suspend soak testing is still incomplete. Core dump
  storage is disabled to keep a crash loop from saturating the Atom CPU.
- The GPU exposes Vulkan 1.2 rather than the Vulkan 1.3 expected by current
  Proton releases. Some games need Proton 7 or an OpenGL fallback.
- Volume buttons change PipeWire volume, but the SteamOS-style volume OSD is
  not yet proven reliable.
- The internal 64 GB storage is restrictive. Do not remove Steam Linux
  runtimes; remove unused Proton versions and games instead.
- The Decky battery workaround patches MangoHud's battery-name matcher at
  runtime because the driver exports `max170xx_battery` instead of `BAT*`.
  This should eventually become an upstream MangoHud fix.
