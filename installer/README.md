# Native installers

Double-click installers that set up the WezTerm + Neovim dev environment without
cloning the repo or running scripts by hand:

- **Windows** → `WezTerm-DevEnv-Setup.exe` (Inno Setup)
- **macOS** → `WezTerm-DevEnv-<version>.dmg` (component `.pkg`)

Both are built automatically by GitHub Actions and published to the repo's
[Releases](../../releases) page. Grab the latest one for your OS and run it — no
`git clone`, no Claude, no terminal commands.

> The configs are **bundled into each release** at build time, so the artifact
> is a self-contained snapshot. Updating = download the newer release and run it
> again (it backs up any existing config as `*.backup-<timestamp>`).

---

## What gets installed

Components are **selectable** in both installers (checkboxes):

| Component  | Selectable | Default | What it does |
|------------|:----------:|:-------:|--------------|
| Neovim env | no (core)  | always  | Neovim ≥ 0.10, git, ripgrep, fzf, lazygit, node, the `nvim/` config, and `:Lazy sync` |
| Nerd Font  | yes        | on      | D2CodingLigature Nerd Font |
| WezTerm    | yes        | on      | WezTerm + `~/.wezterm.lua` |
| Alacritty  | yes        | off     | Alacritty + its config |
| Claude     | yes        | off     | Portable Claude Code config → `~/.claude` |

The canonical list of tool IDs (winget / brew / apt) lives in
[`manifest.json`](./manifest.json).

### Platform model

- **macOS** — everything installs on the Mac via Homebrew.
- **Windows** — the GUI terminals install on **Windows** (winget); the shell +
  Neovim + CLI tooling + Claude config install **inside WSL** (the `.exe` shells
  into your default WSL distro and runs the shared bash installer). This matches
  the real workflow: a Windows terminal app driving a WSL dev environment.
- **WSL / Linux** — for a shell already inside WSL (or plain Linux), there is no
  GUI installer; use the curl one-liner below.

### Already inside WSL? (one-liner)

If you're sitting in a WSL shell and don't want to run the Windows `.exe`:

```bash
curl -fsSL https://raw.githubusercontent.com/SejuneOh/WezTerm/main/installer/wsl/install.sh | bash
# pick components / a release tag:
curl -fsSL .../installer/wsl/install.sh | bash -s -- --components core,nerd-font,wezterm,claude --ref v1.0.0
```

It installs Neovim + CLI + Claude config **inside WSL**, and — because GUI
terminals run on the Windows host, not in WSL — it also places the WezTerm /
Alacritty config on the **Windows side** (`%USERPROFILE%` / `%APPDATA%`, reached
via `/mnt/c`) and best-effort installs the terminal with `winget.exe` over WSL
interop. If `winget.exe` isn't reachable from your distro it prints the manual
step instead. On plain Linux it skips the terminal (install it from your package
manager) and just sets up Neovim.

---

## Layout

```
installer/
├── manifest.json                 # single source of truth (tool IDs, paths, components)
├── common/
│   └── install-nvim-env.sh        # shared Neovim+CLI+config installer (Linux/WSL/macOS)
├── wsl/
│   └── install.sh                 # curl-able bootstrap for shells already inside WSL/Linux
├── windows/
│   ├── bootstrap.ps1              # winget terminals + font + WSL Neovim setup
│   └── installer.iss              # Inno Setup script → WezTerm-DevEnv-Setup.exe
└── macos/
    ├── bootstrap.sh               # Homebrew terminals + font + calls common
    ├── Distribution.xml           # .pkg selection screen
    ├── scripts/core/postinstall   # template; build.sh generates one per component
    └── build.sh                   # pkgbuild + productbuild + hdiutil → .dmg
.github/workflows/release-installers.yml   # builds both on tag push
```

---

## Releasing

```bash
git tag v1.0.0
git push origin v1.0.0
```

The workflow then, on `windows-latest` and `macos-latest`:

1. Lints (shellcheck, PSScriptAnalyzer, JSON validation).
2. Builds `WezTerm-DevEnv-Setup.exe` (Inno Setup) and `WezTerm-DevEnv-<ver>.dmg`.
3. Creates a GitHub Release for the tag and attaches both files.

Use **Actions → Build installers → Run workflow** to build artifacts for testing
without publishing a release.

---

## Updating

You don't reinstall from scratch to pick up config changes — how you update
depends on how the machine was set up:

| How it was installed | How to update |
|----------------------|---------------|
| **Native installer** (`.exe` / `.dmg`) | Download the newer release and run it again. It backs up existing configs as `*.backup-<timestamp>` and re-bundles the snapshot. |
| **WSL / Linux one-liner** | Re-run the exact same `curl … \| bash` — it is idempotent: it re-fetches the channel and re-copies the configs. |
| **Dotfiles symlink** (`scripts/install.sh`) | `git pull` in the checkout. Because the live configs are symlinked, the change is live immediately — nothing to reinstall. |

### Release channels (dev → main → tag)

The installers track a **channel**, which lines up with the branch flow:

- `dev` — integration / staging. Builds do **not** run here; nothing ships from it.
- `main` — the **stable channel**. The WSL one-liner defaults to it
  (`REF="main"` in `installer/wsl/install.sh`), so a fresh `curl … | bash`
  always gets the latest stable config.
- `vX.Y.Z` tag — a **pinned release**. Tagging `main` builds the `.exe`/`.dmg`
  and publishes them to a GitHub Release for reproducible installs.

Pin a machine to a specific version instead of "latest stable":

```bash
curl -fsSL .../installer/wsl/install.sh | bash -s -- --ref v1.2.0
```

So the rule of thumb: **edit configs on `dev`, merge up to `main` to release to the
stable channel, tag when you want a downloadable, pinned `.exe`/`.dmg`.**

---

## Building locally

**macOS** (needs a Mac — `pkgbuild`/`hdiutil` are macOS-only):

```bash
bash installer/macos/build.sh --version 1.0.0 --out dist
```

**Windows** (needs [Inno Setup](https://jrsoftware.org/isdl.php)):

```powershell
iscc /DAppVersion=1.0.0 installer\windows\installer.iss   # → dist\WezTerm-DevEnv-Setup.exe
```

**Linux / WSL** (no native package — run the bootstrap directly against a checkout):

```bash
bash installer/common/install-nvim-env.sh --payload . --components core,nerd-font,claude
```

All scripts accept `--dry-run` to preview actions.

---

## Code signing (not configured)

The artifacts are **unsigned**, so:

- **Windows** shows a SmartScreen "unknown publisher" prompt → *More info → Run anyway*.
- **macOS** shows a Gatekeeper warning → right-click the `.pkg` → *Open*, or
  *System Settings → Privacy & Security → Open Anyway*.

To sign:

- **macOS** — set `MACOS_PKG_SIGN_IDENTITY` (a "Developer ID Installer" identity)
  in the build environment; `build.sh` runs `productsign` automatically. Add
  notarization (`xcrun notarytool`) afterwards.
- **Windows** — add a `signtool sign` step in the workflow with a code-signing
  cert, after ISCC produces the `.exe` (or use Inno's `SignTool` directive).

---

## vs. the dotfiles `scripts/`

`scripts/install.sh` / `install-claude.sh` **symlink** a live checkout into place
— that's the workflow for *developing* these configs. The installers here
**copy** a bundled snapshot — that's the workflow for *standing up a new machine*
fast. Use whichever fits.
