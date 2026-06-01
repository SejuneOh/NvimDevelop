# Alacritty

Alacritty terminal configs, kept alongside the WezTerm setup as an alternative
terminal option.

## Layout

```
alacritty/
  windows/
    alacritty.toml   # Windows host, launches WSL Ubuntu zsh
  README.md
```

Linux and macOS configs can be added under `alacritty/linux/` and
`alacritty/macos/` later.

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
