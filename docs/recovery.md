# Recovery

If the gaming session is black but SSH still works, select a normal Plasma
session at the login screen or disable autologin:

```bash
sudo rm /etc/plasmalogin.conf.d/20-win1-gaming.conf
sudo systemctl reboot
```

For an image regression, roll back the atomic deployment:

```bash
sudo bootc rollback
sudo systemctl reboot
```

For a source installation, run:

```bash
sudo scripts/uninstall.sh
```

The uninstaller preserves Steam games, account state, and user data.
