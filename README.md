# WezTerm + Neovim Dev Environment

A complete terminal-driven development environment built around **WezTerm** (or
**Alacritty**) and **Neovim**, with optional **Claude Code** integration. One
repo, three install paths, the same end state on every machine.

> Tested on **WSL2 (Ubuntu)**, **macOS**, and plain Linux. Windows is supported
> as a Windows-terminal + WSL-shell hybrid (terminal on Windows, dev env in WSL).

---

## At a glance

- Two terminals to choose from: **WezTerm** (default, with tabs / panes /
  workspaces) or **Alacritty** (minimal, pair with zellij/tmux for splits).
- **Neovim 0.10+** with a curated ~40-plugin stack: LSP, Treesitter, Telescope,
  nvim-cmp, lazygit, DAP, dadbod, Roslyn (.NET), and more.
- Three ways to install: a **native `.exe` / `.dmg`** double-click installer, a
  **`curl … | bash`** one-liner for WSL/Linux, or the **dotfiles symlink** flow
  for hacking on the configs themselves.
- A portable **Claude Code** config under `claude/` that mirrors `~/.claude/`,
  so the same skills/hooks/agents follow you to every machine.

---

## Table of Contents

- [Choose an install path](#choose-an-install-path)
- [Path 1 — Native installer (`.exe` / `.dmg`)](#path-1--native-installer-exe--dmg)
- [Path 2 — WSL / Linux one-liner](#path-2--wsl--linux-one-liner)
- [Path 3 — Dotfiles symlink (for developing the configs)](#path-3--dotfiles-symlink-for-developing-the-configs)
- [Requirements](#requirements)
- [Terminals](#terminals)
- [Neovim](#neovim)
- [Claude Code integration](#claude-code-integration)
- [Keybindings reference](#keybindings-reference)
- [Directory structure](#directory-structure)
- [Updating](#updating)
- [For AI assistants](#for-ai-assistants)
- [License](#license)

---

## Choose an install path

| You want to… | Use this path |
|---|---|
| Set up a brand-new machine, no terminal, no git | **Path 1** — native installer |
| Already in a WSL or Linux shell, no GUI installer needed | **Path 2** — curl one-liner |
| Edit the configs in this repo and have changes go live instantly | **Path 3** — dotfiles symlink |

All three end up at the same place: WezTerm/Alacritty config in your home
directory, `nvim/` config in `~/.config/nvim`, plugins synced, and (optionally)
`~/.claude/` populated with the portable Claude Code setup.

---

## Path 1 — Native installer (`.exe` / `.dmg`)

Double-click installers built automatically by GitHub Actions and published to
the repo's [Releases](../../releases) page:

- **Windows** → `WezTerm-DevEnv-Setup.exe` (Inno Setup)
- **macOS** → `WezTerm-DevEnv-<version>.dmg` (component `.pkg`)

Each release bundles the configs as a snapshot, so the artifact is fully
self-contained — no `git clone`, no `curl`, no Claude needed. Both installers
have **selectable components**:

| Component  | Selectable | Default | What it does |
|------------|:----------:|:-------:|--------------|
| Neovim env | no (core)  | always  | Neovim ≥ 0.10, git, ripgrep, fzf, lazygit, node, the `nvim/` config, and `:Lazy sync` |
| Nerd Font  | yes        | on      | D2CodingLigature Nerd Font |
| WezTerm    | yes        | on      | WezTerm + `~/.wezterm.lua` |
| Alacritty  | yes        | off     | Alacritty + its OS-specific config |
| Claude     | yes        | off     | Portable Claude Code config → `~/.claude` |

**Platform model:**
- **macOS** — everything installs via Homebrew on the Mac.
- **Windows** — GUI terminals install on Windows (winget); the shell + Neovim
  + CLI tooling + Claude config install **inside WSL**. The `.exe` shells into
  your default WSL distro and runs the shared bash installer.

The artifacts are **unsigned**, so you'll see a SmartScreen prompt on Windows
(*More info → Run anyway*) and a Gatekeeper warning on macOS (*right-click →
Open*). See [`installer/README.md`](./installer/README.md#code-signing-not-configured)
for signing guidance.

---

## Path 2 — WSL / Linux one-liner

Already sitting in a WSL or Linux shell? Skip the GUI installer:

```bash
curl -fsSL https://raw.githubusercontent.com/SejuneOh/WezTerm/main/installer/wsl/install.sh | bash
```

Pick components or pin a version:

```bash
curl -fsSL .../installer/wsl/install.sh | bash -s -- \
  --components core,nerd-font,wezterm,claude \
  --ref v1.0.0
```

On **WSL** this installs Neovim + CLI + Claude config inside WSL, and — because
GUI terminals run on the Windows host — also drops the WezTerm/Alacritty config
on the Windows side (`%USERPROFILE%` / `%APPDATA%`, via `/mnt/c`), with a
best-effort `winget.exe` install through WSL interop. On **plain Linux** it
skips the GUI terminal step (install it via your package manager) and just sets
up Neovim.

The script is idempotent — re-running it is the supported update path. See
[`installer/README.md`](./installer/README.md) for the full set of flags and
how release channels (`dev` / `main` / tagged) work.

---

## Path 3 — Dotfiles symlink (for developing the configs)

Use this if you're editing the configs in this repo and want changes to go live
without reinstalling. Configs are **symlinked** from the checkout into place,
so `git pull` is your update mechanism.

### Prerequisites

**Ubuntu / WSL2:**

```bash
sudo apt update && sudo apt install -y ripgrep curl git fzf

# Node (LSP servers) via nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install --lts

# Neovim 0.10+ — Ubuntu's apt ships an older version, install from release tarball
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
mkdir -p ~/.local && tar xzf nvim-linux-x86_64.tar.gz -C ~/.local/
mkdir -p ~/.local/bin && ln -sf ~/.local/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim
# Make sure ~/.local/bin is in your PATH
```

**macOS:**

```bash
brew install neovim ripgrep node fzf lazygit wezterm
# or: brew install --cask alacritty
```

### Clone and install

```bash
git clone git@github.com:SejuneOh/WezTerm.git ~/dev/project/WezTerm
cd ~/dev/project/WezTerm
bash scripts/install.sh                  # normal install
bash scripts/install.sh --dry-run        # preview what would change
bash scripts/install.sh --uninstall      # remove symlinks (keeps backups)
```

`scripts/install.sh` will:
1. Verify prerequisites (Neovim ≥ 0.10, git, ripgrep, node, wezterm; warns about optional dotnet, lazygit).
2. Back up any existing configs as `*.backup-<timestamp>`.
3. Symlink `wezterm/.wezterm.lua` → `~/.config/wezterm/wezterm.lua` and `nvim/` → `~/.config/nvim/`.
4. Run `nvim --headless +Lazy! sync` to bootstrap plugins.

### (Optional) Symlink the Claude Code config too

```bash
bash scripts/install-claude.sh           # link claude/ → ~/.claude/
bash scripts/install-claude.sh --dry-run # preview
```

This script:
1. Symlinks `claude/CLAUDE.md`, `statusline-command.sh`, `usage-fetch.py`, `agents/`, `hooks/`, and each `skills/<name>/` folder into `~/.claude/`.
2. **Copies** `claude/settings.json` (not symlink) and substitutes `__HOME__` → your actual `$HOME`. Re-run after editing the settings to refresh.
3. Seeds `skills/project-launcher/projects.json` from `.example` on first run (the real registry is gitignored).

Existing real files in `~/.claude/` are backed up as `<name>.bak-YYYYmmdd-HHMMSS`.

#### Per-machine env vars (only if you use the corresponding skill)

```bash
export CLAUDE_OBSIDIAN_VAULT="/path/to/Obsidian/vault"    # obsidian skill + session-start hook
export CLAUDE_PR_TEMPLATE_PATH="/path/to/PR_template.md"   # pr-draft skill
export CLAUDE_PR_OUTPUT_DIR="/path/to/PR/output/dir"       # pr-draft skill
```

---

## Requirements

| Tool | Minimum | Purpose |
|------|---------|---------|
| WezTerm **or** Alacritty | latest | Terminal emulator |
| Neovim | 0.10+ | Editor |
| Git | any | Plugin installation |
| Node.js | 18+ | LSP servers |
| ripgrep | any | Telescope live grep |
| fzf | any | Workspace switcher / fuzzy find |
| lazygit | any (optional) | `<leader>gg` git UI |
| .NET 10 runtime | optional | Only if you write C# — Roslyn LSP requires it (see [Neovim § C#](#c-roslyn--net-10)) |
| A Nerd Font | any | Icons (recommended: D2CodingLigature Nerd Font) |

---

## Terminals

The repo ships two terminal configurations. Pick one (or install both — the
Neovim config doesn't care).

### WezTerm (default)

Config: [`wezterm/.wezterm.lua`](./wezterm/.wezterm.lua) → installed as
`~/.wezterm.lua` (or `~/.config/wezterm/wezterm.lua` via the dotfiles script).

- **Font:** D2CodingLigature Nerd Font
- **Theme:** Catppuccin Mocha (transparent background, opacity 0.92)
- **Tabline plugin** for a cleaner tab bar
- **Workspace switcher** (zoxide-backed fuzzy finder)
- **Smart splits** — one keybinding set navigates both WezTerm panes and Neovim splits

On Windows the config sets `default_domain = "WSL:Ubuntu"`, so WezTerm runs on
Windows but drops you into your WSL home directory.

| Plugin | Role |
|--------|------|
| [`tabline.wez`](https://github.com/michaelbrusegard/tabline.wez) | Custom tab bar with icons and themes |
| [`smart_workspace_switcher.wezterm`](https://github.com/MLFlexer/smart_workspace_switcher.wezterm) | zoxide-based workspace jumper |
| [`smart-splits.nvim`](https://github.com/mrjones2014/smart-splits.nvim) | Unified pane/split navigation (WezTerm + Neovim) |

### Alacritty (alternative)

Configs: [`alacritty/macos/alacritty.toml`](./alacritty/macos/alacritty.toml)
and [`alacritty/windows/alacritty.toml`](./alacritty/windows/alacritty.toml).
See [`alacritty/README.md`](./alacritty/README.md) for the full breakdown.

- **macOS** — native zsh, Github Dark theme, D2CodingLigature Nerd Font Mono.
  Ports the WezTerm config (opacity 0.92, `option_as_alt = "Both"`).
- **Windows** — launches `wsl.exe -d Ubuntu --cd ~` on startup (terminal on
  Windows, shell in WSL). Carbonfox theme, opacity 0.95 with blur, 140×40,
  10k scrollback.

Alacritty has no built-in tabs/splits — pair it with **zellij** or **tmux** if
you want those.

Install location:

- macOS / Linux: `~/.config/alacritty/alacritty.toml`
- Windows: `%APPDATA%\alacritty\alacritty.toml` (from WSL: `/mnt/c/Users/<USERNAME>/AppData/Roaming/alacritty/alacritty.toml`)

---

## Neovim

Plugin manager: **lazy.nvim** (bootstrapped in `nvim/init.lua`). Plugin specs
live in `nvim/lua/plugins/` — one file per plugin. Editor config (options,
keymaps) is in `nvim/lua/config/`. Native `vim.lsp.config` server definitions
live in `nvim/lsp/`.

### Plugins by category

**UI & navigation**
- `catppuccin/nvim`, `github-theme.nvim` — color schemes
- `nvim-tree.lua` — file explorer
- `telescope.nvim` + `telescope-fzf-native` — fuzzy finder
- `which-key.nvim` — keybinding discovery popup
- `alpha-nvim` — startup dashboard
- `bufferline.nvim` — top tab bar
- `lualine.nvim` — statusline
- `dressing.nvim`, `noice.nvim` — improved UI for input/select/messages
- `aerial.nvim` — symbol outline
- `flash.nvim` — fast in-buffer jumps
- `harpoon` — pinned-file quick-switch

**Sessions & windows**
- `auto-session` — per-directory session save/restore
- `vim-maximizer` — toggle split maximize
- `toggleterm.nvim` — floating/horizontal/vertical terminals

**Syntax & editing**
- `nvim-treesitter` (+ `treesitter-context`) — syntax highlighting, indent, sticky context
- `indent-blankline.nvim` — indent guides
- `nvim-autopairs` — auto-close brackets/quotes
- `Comment.nvim` — toggle comments (`gcc`)
- `todo-comments.nvim` — highlight TODO/FIXME/NOTE
- `nvim-surround` — surround text with brackets/quotes
- `substitute.nvim` — register-based substitution
- `nvim-spectre` — project-wide find & replace
- `nvim-ufo` — better folding
- `vim-illuminate` — highlight word under cursor
- `render-markdown.nvim` — inline markdown rendering

**Autocomplete & snippets**
- `nvim-cmp` — completion engine
- `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp_luasnip` — sources
- `LuaSnip`, `friendly-snippets` — snippet engine + collection
- `lspkind.nvim` — completion menu icons

**LSP**
- `mason.nvim`, `mason-lspconfig`, `mason-tool-installer` — installers
- `nvim-lspconfig` — LSP client config
- `SchemaStore.nvim` — JSON / YAML schemas
- Servers configured in `nvim/lsp/`: `lua_ls`, `ts_ls`, `pyright`, `bashls`,
  `dockerls`, `jsonls`, `marksman`, `taplo`, `yamlls`
- C# is handled by `seblyng/roslyn.nvim` — see [C# (Roslyn) below](#c-roslyn--net-10)

**Diagnostics / formatting / linting**
- `trouble.nvim` — unified diagnostic panel
- `conform.nvim` — stylua / prettier / black+isort / csharpier, with format-on-save
- `nvim-lint` — eslint_d / pylint

**Git**
- `gitsigns.nvim` — inline git signs and hunk actions
- `lazygit.nvim` — launch lazygit CLI in Neovim (`<leader>gg`)

**Debugging**
- `nvim-dap` + UI — debugger frontend
- `neotest` — test runner integration

**.NET**
- `easy-dotnet.nvim` — `dotnet` workflow helpers
- `roslyn.nvim` — C# language server (see warning below)

**Database**
- `vim-dadbod` + `vim-dadbod-ui` + `vim-dadbod-completion` — PostgreSQL & MSSQL client
- Setup: [`docs/DATABASE.md`](./docs/DATABASE.md)

#### C# (Roslyn + .NET 10)

> **C# requires the .NET 10 runtime.** The Mason-installed Roslyn language
> server (`Microsoft.CodeAnalysis.LanguageServer`, v5.8+) targets
> `Microsoft.NETCore.App` 10.0. With only .NET 8 present, the server crashes
> on startup (`exit code 150`, "You must install or update .NET to run this
> application") and **no C# completion / hover / go-to-definition will work**
> — even though `nvim-cmp` and the plugin itself load fine.
>
> **Fix:** install the .NET 10 runtime (the SDK also works). On macOS the
> official arm64 `dotnet-runtime-*-osx-arm64.pkg` installs to
> `/usr/local/share/dotnet`, which is where Roslyn's hostfxr looks; an
> existing .NET 8 SDK can stay alongside. Verify:
> ```bash
> dotnet --list-runtimes | grep 10.0
> ```
>
> **`easy-dotnet.nvim` must not run its own language server.** Its default
> `lsp.enabled = true` starts a second Roslyn server next to the one
> `roslyn.nvim` manages. The two compete for inotify instances (128 by default
> on WSL2), and once the budget runs out one server fails to load any project
> and its files fall back to a reference-less workspace, so correct `using`
> directives produce "type or namespace not found" diagnostics. This repo sets
> `lsp = { enabled = false }` and `projx_lsp = { enabled = false }` in
> `nvim/lua/plugins/easy-dotnet.lua`; the `Dotnet` commands and test runner
> still work. Full write-up and the inotify limit fix:
> [`docs/TROUBLESHOOTING.md`](./docs/TROUBLESHOOTING.md).

---

## Claude Code integration

The [`claude/`](./claude) directory is a portable [Claude Code](https://claude.com/claude-code)
config that mirrors `~/.claude/`. Install via [Path 1](#path-1--native-installer-exe--dmg)
(check the **Claude** component), [Path 2](#path-2--wsl--linux-one-liner)
(`--components …,claude`), or `bash scripts/install-claude.sh` from a checkout.

| Path | Role |
|------|------|
| `CLAUDE.md` | Global instructions (English-learning rephrase, session-start git detection) |
| `settings.json` | Hooks, statusline command, theme, generic permissions (paths use `__HOME__` token replaced at install) |
| `statusline-command.sh` + `usage-fetch.py` | Two-line statusline: dir, branch, git counts, model, 5h / 7d Anthropic usage |
| `agents/dotnet-api-developer.md` | Custom subagent for ASP.NET Core API work |
| `hooks/session-start.sh` | Prints git context at session start; optionally shows an Obsidian project note |
| `hooks/notify-windows.sh` | Windows balloon notification on Claude notifications (WSL only) |
| `skills/obsidian/` | Vault note manager (`/obsidian --project`, `--inbox`, `--decision`, etc.) |
| `skills/pr-draft/` | PR body draft generator from current branch |
| `skills/project-launcher/` | Dispatch background Claude sessions to registered projects |

> `notify-windows.sh` is WSL-specific (uses `powershell.exe`). On non-WSL
> macOS/Linux, either replace it with a platform-appropriate notifier or
> remove the `Notification` entry from `settings.json` after install.

---

## Keybindings reference

> Leader key is `\` (default Neovim leader).
>
> The tables below are a quick-start subset. For the full per-plugin reference
> (Roslyn / Flash / Harpoon / DAP / .NET / Neotest / Noice / Aerial / etc.) see
> [`docs/NVIM_KEYMAPS.md`](./docs/NVIM_KEYMAPS.md).

### WezTerm

| Keys | Action |
|------|--------|
| `Ctrl+Shift+d` | Split pane horizontally (left/right) |
| `Ctrl+Shift+D` | Split pane vertically (top/bottom) |
| `Ctrl+Shift+w` | Close current pane (with confirmation) |
| `Ctrl+Shift+z` | Toggle pane zoom |
| `Ctrl+c` | Copy (when text is selected; otherwise SIGINT) |
| `Ctrl+v` | Paste |
| `Alt+s` | Workspace switcher (fuzzy finder) |
| `Alt+n` | Switch to previous workspace |
| `Ctrl+h/j/k/l` | Move between panes (and into Neovim splits) |

### Alacritty (Windows config)

| Keys | Action |
|------|--------|
| `Ctrl+V` / `Ctrl+Shift+V` | Paste |
| `Ctrl+Shift+C` | Copy |
| `Shift+Insert` | Paste selection |
| `Ctrl + + / − / 0` | Font size up / down / reset |

`Ctrl+C` is intentionally left as SIGINT. Mouse-drag auto-copies to clipboard.

### Neovim — Navigation

| Keys | Action |
|------|--------|
| `\ee` | Toggle file explorer |
| `\ef` | Open explorer at current file |
| `\ff` | Find files (Telescope) |
| `\fr` | Recent files |
| `\fs` | Live grep (search project) |
| `\fb` | Open buffers |
| `\fh` | Neovim help search |
| `\ft` | List TODO/FIXME comments |
| `Ctrl+o` / `Ctrl+i` | Jump back / forward |

### Neovim — Buffers

| Keys | Action |
|------|--------|
| `Tab` / `Shift+Tab` | Next / previous buffer |
| `\1`..`\9` | Go to buffer by ordinal number |
| `\bp` | Pick buffer by letter |
| `\bd` | Close buffer |

### Neovim — Windows & sessions

| Keys | Action |
|------|--------|
| `Ctrl+h/j/k/l` | Move between splits |
| `Alt+h/j/k/l` | Resize split |
| `\sv` | Vertical split |
| `\sh` | Horizontal split |
| `\se` | Equalize split sizes |
| `\sx` | Close current split |
| `\sm` | Toggle split maximize |
| `\ws` | Save session |
| `\wr` | Restore session |

### Neovim — General

| Keys | Action |
|------|--------|
| `Esc` | Clear search highlight |
| `Ctrl+s` | Save file |
| `Ctrl+a` | Select all |
| `<` / `>` (visual) | Indent and stay in visual mode |
| `p` (visual) | Paste without losing register |

### Neovim — Editing

| Keys | Action |
|------|--------|
| `gcc` | Toggle line comment |
| `gc` (visual) | Toggle selection comment |
| `ysiw"` | Surround word with `"` |
| `cs"'` | Change surrounding `"` → `'` |
| `ds"` | Delete surrounding `"` |
| `gs` + motion | Substitute with register (e.g. `gsiw` to swap a word) |
| `]t` / `[t` | Next / previous TODO comment |

---

## Directory structure

```
.
├── README.md                  — this file
├── SETUP.json                 — machine-readable manifest (for AI assistants)
├── wezterm/
│   └── .wezterm.lua           — WezTerm config (default terminal)
├── alacritty/
│   ├── README.md              — Alacritty install + keybind notes
│   ├── macos/alacritty.toml   — macOS host, native zsh
│   └── windows/alacritty.toml — Windows host, launches WSL Ubuntu zsh
├── nvim/
│   ├── init.lua               — bootstraps lazy.nvim
│   ├── lazy-lock.json         — plugin lockfile
│   ├── colors/                — custom color schemes
│   ├── lsp/                   — per-server vim.lsp.config definitions
│   └── lua/
│       ├── config/            — options.lua, keymaps.lua
│       └── plugins/           — one file per plugin spec (~40)
├── zellij/                    — terminal multiplexer config (tabs/splits/sessions)
│   ├── config.kdl             — full keybind + plugin config
│   └── README.md
├── claude/                    — portable Claude Code config (mirrors ~/.claude/)
│   ├── CLAUDE.md
│   ├── settings.json
│   ├── statusline-command.sh
│   ├── usage-fetch.py
│   ├── agents/
│   ├── hooks/
│   └── skills/{obsidian,pr-draft,project-launcher}/
├── scripts/
│   ├── install.sh             — dotfiles-symlink installer (Path 3)
│   └── install-claude.sh      — symlink claude/ into ~/.claude/
├── installer/                 — native installers (.exe, .dmg, WSL one-liner)
│   ├── README.md              — how releases & components work
│   ├── manifest.json          — single source of truth for tool IDs
│   ├── common/install-nvim-env.sh — shared Neovim/CLI bootstrap
│   ├── wsl/install.sh         — curl-able WSL/Linux bootstrap
│   ├── windows/               — Inno Setup script + PowerShell bootstrap
│   └── macos/                 — pkgbuild + productbuild + .dmg
└── docs/
    ├── DATABASE.md            — vim-dadbod database integration guide
    ├── NVIM_KEYMAPS.md        — full per-plugin keymap reference
    ├── TROUBLESHOOTING.md     — known failure modes and how to confirm them
    └── ROADMAP.md             — remaining work & installation order
```

---

## Updating

| Installed via | Update method |
|---|---|
| Native installer (`.exe` / `.dmg`) | Download the newer release and run it again. Backs up existing configs as `*.backup-<timestamp>` and re-bundles the snapshot. |
| WSL / Linux one-liner | Re-run the same `curl … \| bash`. Idempotent — re-fetches the channel and re-copies the configs. |
| Dotfiles symlink (`scripts/install.sh`) | `git pull` in the checkout. Live configs are symlinked, so changes apply immediately. Re-run `scripts/install-claude.sh` only if `claude/settings.json` changed (it's copied, not symlinked). |

### Release channels

- `dev` — integration / staging. Nothing ships from here.
- `main` — stable channel. The WSL one-liner defaults to it.
- `vX.Y.Z` tag — pinned release; cuts the `.exe` / `.dmg` artifacts.

Pin a machine to a specific version:

```bash
curl -fsSL .../installer/wsl/install.sh | bash -s -- --ref v1.2.0
```

Releases are automated with [release-please](https://github.com/googleapis/release-please);
see [`installer/README.md`](./installer/README.md#releasing) for the flow.

---

## For AI assistants

A machine-readable manifest lives at [`SETUP.json`](./SETUP.json), describing:

- Workflow order (installation phases)
- Each installed component, its role, and verification steps
- Pending items and their dependencies

The installer's tool catalog (winget / brew / apt IDs, config paths per OS,
component selection rules) lives at [`installer/manifest.json`](./installer/manifest.json).

Use these files to:
- Reproduce the setup on another machine
- Resume installation from where it left off
- Understand the architectural decisions without reading every Lua file

---

## License

MIT
