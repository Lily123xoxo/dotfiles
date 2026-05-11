# dotfiles

Bare git repo dotfiles for CachyOS (Arch-based) with a tiling Wayland compositor setup.

## Usage

```bash
# Clone onto a new machine
git clone --bare git@github.com:Lily123xoxo/dotfiles.git ~/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles config status.showUntrackedFiles no
dotfiles checkout

# Day-to-day
dotfiles add ~/.config/niri/config.kdl
dotfiles commit -m "update niri config"
dotfiles push
```

Add this to `.zshrc` to make the alias persistent:

```bash
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

## System overview

### Window manager: Niri

[Niri](https://github.com/YaLTeR/niri) is a scrollable-tiling Wayland compositor. Config is modular — `config.kdl` includes separate files from `cfg/` for keybinds, display, layout, animations, etc.

Dual monitor setup:
- **DP-1**: 3440x1440 ultrawide (primary)
- **DP-2**: 2560x1440 vertical (portrait, rotated 90°)

### Shell: Noctalia

[Noctalia](https://github.com/niceddev/noctalia-shell) provides the desktop shell (panel, app launcher, notifications) on top of Niri. Uses the `niri-vertical-monitor` plugin for the portrait display. Colorschemes are Catppuccin Lavender and a custom Lilac AMOLED.

### XDG portals

Portal backends are mixed because Niri doesn't have its own portal implementation:

| Portal | Backend | Why |
|---|---|---|
| Default | GNOME (`xdg-desktop-portal-gnome`) | Best general Wayland compatibility |
| File chooser | KDE (`xdg-desktop-portal-kde`) | KDE's file picker is significantly better |
| Secrets | gnome-keyring | Session keyring, started via PAM + niri autostart |

Portal config lives in `.config/xdg-desktop-portal/niri-portals.conf`.

### Keyring: gnome-keyring

gnome-keyring is started at login via PAM (`pam_gnome_keyring.so`) and again in Niri's autostart for the secrets/pkcs11 components. This provides the `org.freedesktop.secrets` D-Bus interface that apps like Chrome and VS Code use for credential storage.

### Qt/KDE integration

Even though this isn't a KDE session, Qt apps are configured to use KDE theming via `environment.d`:

```
QT_QPA_PLATFORM=wayland
QT_QPA_PLATFORMTHEME=kde
XDG_MENU_PREFIX=plasma-
```

KDE Plasma is also installed for its login/splash screen (SDDM + KDE splash).

### Terminal: Kitty

Kitty with a custom "Lily Dark Pride" color theme and Starship prompt.

### App launcher: Rofi

Rofi in Wayland mode with a Tokyo Night-inspired theme and Iosevka Nerd Font.

### GTK theming

GTK 3 and 4 are themed via Noctalia-generated CSS. Cursor theme is Catppuccin Mocha Lavender, icon theme is char-white.

## What's tracked

```
~/.zshrc                          # Shell config (sources aliases, functions, starship)
~/.zsh_aliases                    # Shell aliases (win11 reboot, chrome, etc.)
~/.zsh_functions/                 # Autoloaded zsh functions (airpods, uv completions)
~/.npmrc                          # npm global prefix
~/.gtkrc-2.0                     # Legacy GTK2 theme

~/.config/niri/                   # Niri compositor config (modular kdl)
~/.config/noctalia/               # Noctalia shell config + colorschemes + plugins
~/.config/hypr/                   # Hyprland config (noctalia color integration)
~/.config/kitty/                  # Kitty terminal config + themes
~/.config/rofi/                   # Rofi launcher config + tokyo theme
~/.config/starship.toml           # Starship prompt config
~/.config/environment.d/          # Session environment variables (Qt/KDE theming)
~/.config/xdg-desktop-portal/     # Portal backend preferences
~/.config/fontconfig/             # Font rendering config
~/.config/gtk-3.0/                # GTK3 theme + settings
~/.config/gtk-4.0/                # GTK4 theme + settings
```

## What's NOT tracked

Secrets (`.ssh/`, `.gnupg/`, `.config/gh/`), caches (`.cache/`, `.local/`), browser profiles, app state (Discord, Spotify, Steam, Wine), and IDE config (`.vscode/`, `.claude/`).
