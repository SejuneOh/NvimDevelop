#!/usr/bin/env bash
#
# install.sh — curl-able bootstrap for WSL and plain Linux.
#
# For people who are already inside a WSL (or Linux) shell and want the dev
# environment without a GUI installer, a clone, or Claude. Mirrors what the
# .exe/.dmg do, for the terminal-first case.
#
#   curl -fsSL https://raw.githubusercontent.com/SejuneOh/WezTerm/main/installer/wsl/install.sh | bash
#   curl -fsSL .../install.sh | bash -s -- --components core,nerd-font,wezterm,claude --ref v1.0.0
#
# WSL specifics it handles that the cross-platform common installer can't:
#   - GUI terminals (WezTerm/Alacritty) run on WINDOWS, not in WSL, so it places
#     their configs on the Windows side (%USERPROFILE% / %APPDATA% via /mnt/c)
#     and best-effort installs the terminal with winget.exe over WSL interop.
#   - Neovim + CLI + Claude config install inside WSL via install-nvim-env.sh.
#
# Components: core, nerd-font, wezterm, alacritty, claude  (see installer/manifest.json)
#
set -euo pipefail

REPO="SejuneOh/WezTerm"
REF="main"
COMPONENTS="core,nerd-font,wezterm"
DRY_RUN=0

info()  { printf '\033[1;34m[info]\033[0m  %s\n' "$*"; }
warn()  { printf '\033[1;33m[warn]\033[0m  %s\n' "$*"; }
run()   { if [ "$DRY_RUN" -eq 1 ]; then printf '\033[1;36m[plan]\033[0m  %s\n' "$*"; else eval "$@"; fi; }
has()   { case ",$COMPONENTS," in *",$1,"*) return 0 ;; *) return 1 ;; esac; }

while [ $# -gt 0 ]; do
  case "$1" in
    --components) COMPONENTS="$2"; shift 2 ;;
    --ref)        REF="$2"; shift 2 ;;
    --repo)       REPO="$2"; shift 2 ;;
    --dry-run)    DRY_RUN=1; shift ;;
    -h|--help)    sed -n '2,21p' "$0" | sed 's/^#\{0,1\} \{0,1\}//'; exit 0 ;;
    *) warn "unknown arg: $1"; shift ;;
  esac
done

is_wsl() { grep -qi microsoft /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME:-}" ]; }

# ---------------------------------------------------------------------------
# 1. obtain the payload (use a sibling checkout if present, else download)
# ---------------------------------------------------------------------------
SELF="${BASH_SOURCE[0]:-}"
if [ -n "$SELF" ] && [ -f "$(dirname "$SELF")/../common/install-nvim-env.sh" ]; then
  SRC="$(cd "$(dirname "$SELF")/../.." && pwd)"
  info "Using local checkout: $SRC"
else
  TMP="$(mktemp -d)"
  info "Downloading $REPO@$REF ..."
  run "curl -fsSL 'https://codeload.github.com/$REPO/tar.gz/$REF' | tar xz -C '$TMP'"
  if [ "$DRY_RUN" -eq 1 ]; then
    SRC="$TMP/<extracted>"
  else
    SRC="$(find "$TMP" -maxdepth 1 -type d -name 'WezTerm-*' | head -1)"
    [ -n "$SRC" ] || { warn "could not locate extracted repo"; exit 1; }
  fi
fi

# ---------------------------------------------------------------------------
# 2. Neovim + CLI (+ Claude) inside WSL/Linux
# ---------------------------------------------------------------------------
common_components=""
has core      && common_components="core"
has nerd-font && common_components="${common_components:+$common_components,}nerd-font"
has claude    && common_components="${common_components:+$common_components,}claude"
if [ -n "$common_components" ]; then
  flags="--payload '$SRC' --components '$common_components'"
  [ "$DRY_RUN" -eq 1 ] && flags="$flags --dry-run"
  info "Installing Neovim environment ($common_components)..."
  run "bash '$SRC/installer/common/install-nvim-env.sh' $flags"
fi

# ---------------------------------------------------------------------------
# 3. WSL only: GUI terminals live on the Windows side
# ---------------------------------------------------------------------------
win_path_from_env() {
  # Echo a /mnt/c-style WSL path for a Windows env var (e.g. USERPROFILE, APPDATA).
  local var="$1" cmd win
  cmd="$(command -v cmd.exe || echo /mnt/c/Windows/System32/cmd.exe)"
  win="$( (cd /mnt/c 2>/dev/null && "$cmd" /c "echo %$var%") 2>/dev/null | tr -d '\r' )"
  [ -n "$win" ] && [ "$win" != "%$var%" ] && wslpath -u "$win" 2>/dev/null || return 1
}

winget_install() {
  local id="$1"
  if command -v winget.exe >/dev/null 2>&1; then
    info "winget.exe install $id (on Windows, via WSL interop)"
    run "winget.exe install --id '$id' --exact --silent --accept-package-agreements --accept-source-agreements || true"
  else
    warn "winget.exe not reachable from WSL. Install '$id' on Windows manually (or run the .exe installer)."
  fi
}

place_windows_config() {
  local src="$1" dest="$2"
  [ -n "$dest" ] || { warn "could not resolve Windows path for $(basename "$src"); skipping"; return; }
  if [ -e "$dest" ] && [ "$DRY_RUN" -eq 0 ]; then
    run "mv '$dest' '$dest.backup-$(date +%Y%m%d-%H%M%S)'"
  fi
  run "mkdir -p '$(dirname "$dest")'"
  run "cp '$src' '$dest'"
  info "Placed Windows config: $dest"
}

if is_wsl && { has wezterm || has alacritty; }; then
  info "WSL detected — configuring Windows-side terminal(s)."
  USERPROFILE_WSL="$(win_path_from_env USERPROFILE || true)"
  APPDATA_WSL="$(win_path_from_env APPDATA || true)"

  if has wezterm; then
    winget_install "wez.wezterm"
    place_windows_config "$SRC/wezterm/.wezterm.lua" "${USERPROFILE_WSL:+$USERPROFILE_WSL/.wezterm.lua}"
  fi
  if has alacritty; then
    winget_install "Alacritty.Alacritty"
    place_windows_config "$SRC/alacritty/windows/alacritty.toml" "${APPDATA_WSL:+$APPDATA_WSL/alacritty/alacritty.toml}"
  fi
elif ! is_wsl && { has wezterm || has alacritty; }; then
  warn "Not WSL: skipping GUI terminal install. On native Linux install WezTerm/Alacritty"
  warn "with your package manager; the configs go to ~/.wezterm.lua and ~/.config/alacritty/."
fi

info "Done."
