# ghostty-theme-sync

Make Ghostty follow the KDE (Plasma) light/dark color scheme on Linux.

## Problem

Ghostty 1.3.1 takes a single `theme = <name>` and keeps it regardless of the
system appearance. Anything asking for both looks gets one fixed look.

Ghostty does support following the system, but only through one option form:

```
theme = light:<name>,dark:<name>
```

With a single theme name, or with explicit `background`/`foreground` values,
there is nothing to switch between.

## What this does

`install.sh` rewrites every active `theme` assignment in the user config to
the light/dark pair, keeping every other option and commented line untouched:

```
~/.config/ghostty/config.ghostty
  theme = light:Builtin Light,dark:Builtin Dark
```

Observed with Ghostty 1.3.1 on KDE Plasma with Breeze and the GTK/libadwaita
build, sampling the background of a running window:

| config | system appearance | rendered background |
| --- | --- | --- |
| `theme = Builtin Dark` | BreezeDark | `#000000` (forced) |
| `theme = light:Builtin Light,dark:Builtin Dark` | `color-scheme prefer-dark` | `(0, 0, 0)` |
| `theme = light:Builtin Light,dark:Builtin Dark` | `color-scheme prefer-light` | `(255, 255, 255)` |

The switch is live: the same window changed color with no restart, and the
`theme-scheduler` (KDE LookAndFeel at sunrise/sunset) drives it end to end.

Signal chain:

```
theme-scheduler / Plasma LookAndFeel
  → kde-gtk-config writes GTK dark preference
      ~/.config/gtk-3.0/settings.ini  gtk-application-prefer-dark-theme=true
      ~/.config/gtk-4.0/settings.ini  gtk-application-prefer-dark-theme=true
      gsettings org.gnome.desktop.interface color-scheme = 'prefer-dark'
  → Ghostty (GTK + libadwaita) picks the dark or light side of the pair
```

## Verify

```sh
ghostty +validate-config
ghostty +show-config | grep -E '^theme'

gsettings set org.gnome.desktop.interface color-scheme prefer-light   # window goes light
gsettings set org.gnome.desktop.interface color-scheme prefer-dark    # window goes dark
```

Note: the second command sets the GTK preference only, so on Plasma it does not
change the Plasma theme itself.

## Requirements

- Ghostty with support for `theme = light:...,dark:...` (tested with 1.3.1)
- Bash and Python 3
- On KDE Plasma, working GTK appearance integration for system theme changes

## Install

```sh
./install.sh
```

Rewrites `~/.config/ghostty/config.ghostty`, saves its original contents to
`config.ghostty.bak` on the first install, and runs `ghostty +validate-config`.
Repeated installs preserve that first backup.

Theme names come from `ghostty +list-themes` (builtin
ones include `Builtin Dark`, `Builtin Light`, `Builtin Pastel Dark`,
`Builtin Tango Dark`, `Builtin Tango Light`). Override the pair without
editing the script:

```sh
GHOSTTY_LIGHT_THEME='Builtin Tango Light' GHOSTTY_DARK_THEME='Builtin Tango Dark' ./install.sh
```

Config path honours `$XDG_CONFIG_HOME`; the default is
`~/.config/ghostty/config.ghostty`.

## Limits

- **Not auto-reloaded.** Ghostty 1.3.1 has no config file watcher. Existing
  windows keep the old value until `Ctrl+Shift+,` (reload_config), the menu
  entry, or a new window.
- `ghostty +show-config` is misleading for a pair: the CLI has no GTK app
  context, so it resolves the light side and prints `background = #ffffff`
  even while a dark desktop shows dark windows. Trust the window, not the CLI.
- `ghostty +show-config` also prints the pair itself, not the resolved choice;
  there is no CLI flag to ask which side is active.
- Both sides share `background-opacity` and `background-blur`; only colors and
  palette switch.

## Uninstall

```sh
cp ~/.config/ghostty/config.ghostty.bak ~/.config/ghostty/config.ghostty
```

Or set the `theme` line back to a single theme name by hand.

## License

MIT. See [LICENSE](LICENSE).
