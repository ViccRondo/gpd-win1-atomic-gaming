# Recovery

## Black gaming session

If SSH works, disable gaming-mode autologin and reboot:

```bash
sudo rm -f /etc/plasmalogin.conf.d/20-win1-gaming.conf
sudo systemctl reboot
```

Without SSH, try `Ctrl+Alt+F3`, log in on the text console, and run the same
commands. At the login screen select a normal Plasma session.

If input sounds still play but the panel is black after suspend, collect logs
before rebooting when possible:

```bash
sudo journalctl -b -k > ~/win1-kernel-current-boot.log
sudo journalctl -b -u win1-lid-event-guard > ~/win1-lid-current-boot.log
```

A hard power cycle may be the only recovery from a complete i915 hang and will
lose unsaved data.

If the optional i915 watchdog detected the failure before rebooting, it stores
one directory per incident:

```bash
sudo ls -la /var/lib/win1-i915-diagnostics
sudo cp -a /var/lib/win1-i915-diagnostics "$HOME/"
sudo chown -R "$USER:$USER" "$HOME/win1-i915-diagnostics"
```

Each incident includes the triggering DRM error, boot ID, kernel command line,
full kernel journal, and any i915 display, engine, error-state, frequency, and
power-domain snapshots that remained readable.

## Decky 插件导致卡死

先停用 Decky Loader，将可疑插件移出活动目录，再启动 Decky。以下命令专门隔离
已确认不兼容的 HLTB for Deck `v2.0.9`：

```bash
sudo systemctl stop plugin_loader.service
sudo mkdir -p "$HOME/homebrew/disabled-plugins"
sudo mv "$HOME/homebrew/plugins/hltb-for-deck" \
  "$HOME/homebrew/disabled-plugins/hltb-for-deck-v2.0.9-incompatible"
sudo chown -R "$USER:$USER" "$HOME/homebrew/disabled-plugins"
sudo systemctl start plugin_loader.service
```

如果目录名不同，先执行 `ls "$HOME/homebrew/plugins"`，不要猜测或删除整个
`homebrew` 目录。隔离会保留插件文件以便排查。

## Remove the source installation

From the cloned repository:

```bash
sudo ./scripts/uninstall.sh
sudo systemctl reboot
```

The uninstaller preserves Steam games, account state, Decky data, and user
files. To also remove the kernel arguments added by the installer:

```bash
sudo rpm-ostree kargs \
  --delete-if-present=reboot=pci \
  --delete-if-present=i915.disable_power_well=0
sudo systemctl reboot
```

## Atomic image rollback

For a `bootc switch` image regression:

```bash
sudo bootc rollback
sudo systemctl reboot
```

If the default deployment cannot boot, select the previous deployment from the
boot loader instead.
