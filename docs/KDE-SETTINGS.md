# KDE Settings

Tracked KDE configuration files in `packages/kde/.config/`:

| File | Purpose |
|------|---------|
| `kdeglobals` | Global KDE settings (theme, fonts, icons) |
| `plasmarc` | Plasma desktop shell settings |
| `kwinrc` | KWin window manager (compositor, effects, shortcuts) |
| `konsolerc` | Konsole terminal emulator |
| `dolphinrc` | Dolphin file manager |
| `kscreenlockerrc` | Screen locker / lock screen |
| `krunnerrc` | KRunner launcher |
| `klipperrc` | Clipboard manager |
| `spectaclerc` | Spectacle screenshot tool |
| `systemmonitorrc` | System monitor |
| `kcmfonts` | Font rendering settings |
| `kxkbrc` | Keyboard layout configuration |
| `.gtkrc-2.0` | GTK2 theme integration |

## Backup Settings

```bash
./scripts/kde-settings.sh backup
```

## Restore Settings

```bash
./scripts/kde-settings.sh restore
```
