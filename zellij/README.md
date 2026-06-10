# Zellij

Zellij terminal multiplexer config, kept alongside the WezTerm setup. Pairs
well with **Alacritty** (which has no built-in tabs/splits) and works equally
under WezTerm as a portable, terminal-agnostic layout/session layer.

> Tested with **Zellij 0.43.x** on WSL2 (Ubuntu).

## Layout

```
zellij/
  config.kdl   # full keybind + plugin config (KDL format)
  README.md
```

## Install location

Copy `config.kdl` into:

```
~/.config/zellij/config.kdl
```

Create the `~/.config/zellij` folder first if it does not exist:

```bash
mkdir -p ~/.config/zellij
cp config.kdl ~/.config/zellij/config.kdl
```

Zellij does **not** hot-reload `config.kdl` into already-running sessions —
start a new session (or restart existing ones) to pick up changes.

## Behavior

- `keybinds clear-defaults=true` — the config defines the **full** keybind set
  from scratch rather than layering on top of Zellij's defaults, so what you
  see in `config.kdl` is exactly what is active.
- Modal keybindings (Zellij's default style): `Ctrl` + a letter switches into a
  mode (`pane`, `tab`, `resize`, `move`, `scroll`, `search`, `session`,
  `tmux`), then single keys act within that mode. `Esc` / `Enter` returns to
  normal mode.
- `Ctrl g` toggles **locked** mode (all keybinds disabled except the unlock),
  useful when an app inside a pane needs the modifier keys.

## Quit — two-step confirmation

There is **no global quit shortcut**. Zellij has no native "confirm before
quit" dialog, so quitting is made deliberate by requiring a two-key sequence
through session mode:

| Step | Key      | Result                          |
| ---- | -------- | ------------------------------- |
| 1    | `Ctrl o` | Enter **session** mode          |
| 2    | `q`      | Quit Zellij                     |

Pressing `Ctrl o` and then `Esc` (or `Ctrl o` again) backs out without
quitting — this is the "confirmation" step. The default global `Ctrl q { Quit }`
binding is intentionally **removed** from the `shared_except "locked"` block to
prevent accidental termination.

To detach (leave the session running) instead of quitting, use `Ctrl o` then
`d`.

## Key bindings (summary)

Mode switches (from normal mode):

| Key      | Mode      | Purpose                          |
| -------- | --------- | -------------------------------- |
| `Ctrl p` | pane      | Split / focus / rename panes     |
| `Ctrl t` | tab       | New / close / move tabs          |
| `Ctrl n` | resize    | Resize the focused pane          |
| `Ctrl h` | move      | Move panes around                |
| `Ctrl s` | scroll    | Scroll / search the scrollback   |
| `Ctrl o` | session   | Session actions, detach, **quit**|
| `Ctrl b` | tmux      | tmux-style compatibility prefix  |
| `Ctrl g` | locked    | Disable/enable all keybinds      |

Within a mode, `h/j/k/l` (and arrows) navigate; `Esc`/`Enter` exit to normal.
See `config.kdl` for the complete per-mode bindings.

## Plugins

Uses Zellij's built-in plugins only (`tab-bar`, `status-bar`, `compact-bar`,
`strider` file picker, `session-manager`, `plugin-manager`, `about`,
`configuration`). No external `.wasm` plugins are loaded, so the config is
portable with no extra downloads.

## Options

Most global options below the `keybinds`/`plugins` blocks are left at their
documented defaults (commented out in `config.kdl`). Notable defaults relied on:

- `on_force_close "detach"` — closing the terminal window detaches rather than
  killing the session.
- `scroll_buffer_size 10000` — 10k lines of scrollback per pane.
- `copy_on_select true` — mouse selection auto-copies.

Uncomment and edit the relevant line in `config.kdl` to override any of these
(some require a session restart, as noted inline).
