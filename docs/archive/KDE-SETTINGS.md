# KDE Settings

Tracked KDE configuration files in `packages/kde/.config/`:

## Appearance & Theme

| File | Purpose |
|------|---------|
| `kdeglobals` | Global KDE settings (theme, colors, icons, fonts, animations) |
| `kcmfonts` | Font rendering settings (DPI, hinting) |
| `gtkrc-2.0` | GTK2 theme integration |
| `gtkrc` | GTK+ settings |

## Window Manager (KWin)

| File | Purpose |
|------|---------|
| `kwinrc` | KWin window manager (compositor, effects, tiling layout, virtual desktops) |
| `kwinrulesrc` | KWin window rules |
| `kglobalshortcutsrc` | Global keyboard shortcuts (KWin, Krohnkite tiling, Media, Power, Launcher) |

## Plasma Desktop

| File | Purpose |
|------|---------|
| `plasmarc` | Plasma desktop shell settings |
| `plasmashellrc` | Plasma shell panel configuration (position, opacity, length) |
| `plasma-localerc` | Locale and format settings (language, paper size, telephone) |
| `plasmakeyboardrc` | On-screen keyboard and text input settings |

## Input Devices

| File | Purpose |
|------|---------|
| `kcminputrc` | Keyboard repeat, mouse/touchpad acceleration and gestures |
| `kxkbrc` | Keyboard layout configuration (US + Arabic AZERTY) |

## Applications

| File | Purpose |
|------|---------|
| `dolphinrc` | Dolphin file manager |
| `konsolerc` | Konsole terminal emulator |
| `katerc` | Kate text editor |
| `klipperrc` | Clipboard manager |
| `spectaclerc` | Spectacle screenshot tool |
| `systemmonitorrc` | System monitor |
| `krunnerrc` | KRunner launcher |
| `kscreenlockerrc` | Screen locker / lock screen |

## Security

| File | Purpose |
|------|---------|
| `kwalletrc` | KDE Wallet (auto-close, idle timeout, secrets API) |

## Backup Settings

```bash
./scripts/kde-settings.sh backup
```

## Restore Settings

```bash
./scripts/kde-settings.sh restore
```

## Machine-Specific Files (NOT Tracked)

The following KDE files are machine-specific and **not** included in the repo:

| File | Reason |
|------|--------|
| `kwinoutputconfig.json` | Hardware-specific display EDIDs, serial numbers, resolution configs |
| `kdeconnect/` | Certificates, private keys for KDE Connect pairing |
| `plasma-org.kde.plasma.desktop-appletsrc` | Panel layout, widget positions, screen-specific geometry |
| `KDE/UserFeedback.conf` | Per-machine usage data |
| `kactivitymanagerd-pluginsrc` | Activity manager session state |
| `kactivitymanagerd-statsrc` | Activity scoring (cache) |
