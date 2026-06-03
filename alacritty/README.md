# Alacritty

Alacritty terminal configs, kept alongside the WezTerm setup as an alternative
terminal option.

## Layout

```
alacritty/
  windows/
    alacritty.toml   # Windows host, launches WSL Ubuntu zsh
  macos/
    alacritty.toml   # macOS host, native zsh (port of .wezterm.lua)
  README.md
```

A Linux config can be added under `alacritty/linux/` later.

## macOS

### Install location

Copy `macos/alacritty.toml` into:

```
~/.config/alacritty/alacritty.toml
```

Create the `~/.config/alacritty` folder first if it does not exist.

### Behavior

- Uses the native login shell (zsh) — no shell override needed on macOS.
- Ported from the repo's `.wezterm.lua`: opacity `0.92`, zero window padding,
  `option_as_alt = "Both"` so the Option key acts as Alt for nvim `<A-hjkl>`
  mappings.
- `live_config_reload` is enabled under `[general]`, so saving the file applies
  changes without restarting Alacritty.
- Tabs/splits/workspaces are not built into Alacritty — pair it with `zellij`
  (or tmux) for that.

### Theme

Github Dark (Gogh) — matches the `.wezterm.lua` `color_scheme`.

### Font

`D2CodingLigature Nerd Font Mono`, size 13 (Retina-tuned; the repo's WezTerm
default is 10). The `Mono` variant is used so Nerd Font icon glyphs render at a
single cell width. Alacritty does not render ligatures, but the font family
still matches the WezTerm setup and includes Hangul + Nerd Font icon glyphs.

## Windows

### Install location

Drop `windows/alacritty.toml` into:

```
%APPDATA%\alacritty\alacritty.toml
```

From WSL: `/mnt/c/Users/<USERNAME>/AppData/Roaming/alacritty/alacritty.toml`

Create the `alacritty` folder first if it does not exist.

### Behavior

- Launches `wsl.exe -d Ubuntu --cd ~` on startup, so the terminal drops
  straight into the WSL home directory using the default login shell (zsh).
- `live_config_reload` is enabled under `[general]`, so saving the file
  applies changes without restarting Alacritty.

### Theme

Carbonfox — charcoal background (`#161616`) with subtle pink/blue/purple
accents. Tuned for long coding sessions.

### Font

`D2CodingLigature Nerd Font`, size 11. Same family as the WezTerm config
recommends. Picked because it includes:

- Korean glyphs (Hangul rendering)
- Nerd Font icon glyphs (file/folder/Git icons used by `nvim-web-devicons`,
  Powerlevel10k prompt segments, etc.)
- Programming ligatures (`==>`, `!=`, `=>`, ...)

If you prefer a different Nerd Font (JetBrainsMono Nerd Font, FiraCode Nerd
Font, ...), download it from <https://www.nerdfonts.com/font-downloads>,
install it on Windows, and swap the three `family = "..."` lines under
`[font.normal|bold|italic]`.

### Key bindings

| Key                | Action              |
| ------------------ | ------------------- |
| `Ctrl+V`           | Paste               |
| `Ctrl+Shift+V`     | Paste               |
| `Ctrl+Shift+C`     | Copy                |
| `Shift+Insert`     | Paste selection     |
| `Ctrl` + `+/-/0`   | Font size +/-/reset |

`Ctrl+C` is intentionally left as SIGINT (interrupt the running process).
Mouse-drag selection is auto-copied to the clipboard via
`selection.save_to_clipboard = true`, so most copy/paste flows do not need a
hotkey on the copy side.

### Window

- Opacity `0.95` with blur enabled
- 140 columns x 40 lines on launch
- 10,000 lines of scrollback
