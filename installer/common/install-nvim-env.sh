#!/usr/bin/env bash
#
# install-nvim-env.sh — shared Neovim + CLI environment installer.
#
# Used by:
#   - macOS .pkg postinstall (installer/macos)        -> runs with brew backend
#   - Windows .exe, inside WSL (installer/windows)     -> runs with apt backend
#   - directly on a Linux/WSL box for a no-package install
#
# It installs CLI tooling + Neovim (>= 0.10), copies the bundled configs into
# place, optionally installs the portable Claude config, and bootstraps the
# Neovim plugins. It does NOT install GUI terminals (WezTerm / Alacritty) —
# those are platform-native and handled by the per-OS installers. The single
# source of truth for tool IDs is installer/manifest.json.
#
# Usage:
#   install-nvim-env.sh --payload <dir> [options]
#
#   --payload <dir>     Directory holding the bundled repo content
#                       (must contain nvim/, optionally claude/). Required.
#   --components <list> Comma list from: core,nerd-font,claude (default: core,nerd-font)
#   --no-font           Skip the Nerd Font (macOS installs it via brew cask instead)
#   --dry-run           Print actions without changing anything
#   -h | --help
#
set -euo pipefail

# ----------------------------------------------------------------------------
# args + helpers
# ----------------------------------------------------------------------------
PAYLOAD=""
COMPONENTS="core,nerd-font"
DO_FONT=1
DRY_RUN=0

info()  { printf '\033[1;34m[info]\033[0m  %s\n' "$*"; }
warn()  { printf '\033[1;33m[warn]\033[0m  %s\n' "$*"; }
error() { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }
plan()  { printf '\033[1;36m[plan]\033[0m  %s\n' "$*"; }

run() { if [ "$DRY_RUN" -eq 1 ]; then plan "$*"; else eval "$@"; fi; }

usage() { sed -n '2,33p' "$0" | sed 's/^#\{0,1\} \{0,1\}//'; exit 0; }

has_component() { case ",$COMPONENTS," in *",$1,"*) return 0 ;; *) return 1 ;; esac; }

while [ $# -gt 0 ]; do
  case "$1" in
    --payload)    PAYLOAD="$2"; shift 2 ;;
    --components) COMPONENTS="$2"; shift 2 ;;
    --no-font)    DO_FONT=0; shift ;;
    --dry-run)    DRY_RUN=1; shift ;;
    -h|--help)    usage ;;
    *) error "unknown arg: $1"; exit 2 ;;
  esac
done

[ -n "$PAYLOAD" ] || { error "--payload <dir> is required"; exit 2; }
[ -d "$PAYLOAD" ] || { error "payload dir not found: $PAYLOAD"; exit 2; }
has_component nerd-font || DO_FONT=0

TS="$(date +%Y%m%d-%H%M%S)"

# ----------------------------------------------------------------------------
# OS / package-manager detection
# ----------------------------------------------------------------------------
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *) error "unsupported OS: $OS"; exit 1 ;;
esac
ARCH="$(uname -m)"
info "Platform: $PLATFORM ($ARCH)"
[ "$DRY_RUN" -eq 1 ] && info "DRY-RUN: no changes will be made."

# ----------------------------------------------------------------------------
# config destinations
# ----------------------------------------------------------------------------
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
NVIM_DEST="$CONFIG_HOME/nvim"
CLAUDE_DEST="$HOME/.claude"

backup_existing() {
  # $1 = path; if a real (non-symlink) file/dir exists, move it aside.
  local target="$1"
  if [ -L "$target" ]; then run "rm -f '$target'";
  elif [ -e "$target" ]; then
    warn "Backing up existing $target -> $target.backup-$TS"
    run "mv '$target' '$target.backup-$TS'"
  fi
}

# ----------------------------------------------------------------------------
# CLI tooling  (manifest.json -> components.core.tools)
# ----------------------------------------------------------------------------
install_cli_macos() {
  command -v brew >/dev/null 2>&1 || {
    info "Installing Homebrew..."
    run '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  }
  info "Installing CLI tools via brew (git, node, ripgrep, fzf, lazygit, neovim)..."
  run "brew install git node ripgrep fzf lazygit neovim || true"
}

install_neovim_linux() {
  if command -v nvim >/dev/null 2>&1; then
    local v; v="$(nvim --version | head -1 | sed 's/[^0-9.]*\([0-9][0-9.]*\).*/\1/')"
    local maj min; IFS='.' read -r maj min _ <<EOF
$v
EOF
    if [ "${maj:-0}" -gt 0 ] || [ "${min:-0}" -ge 10 ]; then
      info "Neovim $v already present (>= 0.10), skipping."
      return
    fi
    warn "Neovim $v is too old; installing a current release into ~/.local."
  fi
  local asset
  case "$ARCH" in
    x86_64|amd64) asset="nvim-linux-x86_64.tar.gz" ;;
    aarch64|arm64) asset="nvim-linux-arm64.tar.gz" ;;
    *) error "unsupported arch for Neovim tarball: $ARCH"; return 1 ;;
  esac
  info "Downloading Neovim release ($asset)..."
  run "mkdir -p '$HOME/.local' '$HOME/.local/bin'"
  run "curl -fsSL -o '/tmp/$asset' 'https://github.com/neovim/neovim/releases/latest/download/$asset'"
  run "tar xzf '/tmp/$asset' -C '$HOME/.local/'"
  run "ln -sf '$HOME/.local/${asset%.tar.gz}/bin/nvim' '$HOME/.local/bin/nvim'"
  info "Neovim installed to ~/.local/bin/nvim — ensure ~/.local/bin is on PATH."
}

install_node_linux() {
  command -v node >/dev/null 2>&1 && { info "node already present, skipping nvm."; return; }
  info "Installing Node.js (LTS) via nvm..."
  run "curl -fsSL -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [ "$DRY_RUN" -eq 1 ] || { . "$NVM_DIR/nvm.sh" && nvm install --lts; }
}

install_lazygit_linux() {
  command -v lazygit >/dev/null 2>&1 && return
  info "Installing lazygit into ~/.local/bin..."
  local tag tgz
  tag="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
        | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/.*"v\{0,1\}\([^"]*\)"/\1/')"
  [ -n "$tag" ] || { warn "could not resolve lazygit version; skipping (install later: <leader>gg)"; return; }
  case "$ARCH" in
    x86_64|amd64) tgz="lazygit_${tag}_Linux_x86_64.tar.gz" ;;
    aarch64|arm64) tgz="lazygit_${tag}_Linux_arm64.tar.gz" ;;
    *) warn "unsupported arch for lazygit: $ARCH"; return ;;
  esac
  run "mkdir -p '$HOME/.local/bin'"
  run "curl -fsSL -o /tmp/lazygit.tar.gz 'https://github.com/jesseduffield/lazygit/releases/download/v${tag}/${tgz}'"
  run "tar xzf /tmp/lazygit.tar.gz -C /tmp lazygit"
  run "install /tmp/lazygit '$HOME/.local/bin/lazygit'"
}

install_cli_linux() {
  if command -v apt-get >/dev/null 2>&1; then
    info "Installing CLI tools via apt (git, ripgrep, fzf, curl)..."
    run "sudo apt-get update -y"
    run "sudo apt-get install -y git ripgrep fzf curl unzip build-essential"
  else
    warn "apt-get not found; install git, ripgrep, fzf, curl, unzip manually."
  fi
  install_neovim_linux
  install_node_linux
  install_lazygit_linux
}

# ----------------------------------------------------------------------------
# Nerd Font (Linux only — macOS uses the brew cask in bootstrap.sh)
# ----------------------------------------------------------------------------
install_font_linux() {
  [ "$DO_FONT" -eq 1 ] || return 0
  local dir="$HOME/.local/share/fonts"
  info "Installing D2CodingLigature Nerd Font into $dir..."
  run "mkdir -p '$dir'"
  run "curl -fsSL -o /tmp/d2coding-nerd.zip 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/D2Coding.zip'"
  run "unzip -o /tmp/d2coding-nerd.zip -d '$dir' >/dev/null"
  run "fc-cache -f '$dir' || true"
}

# ----------------------------------------------------------------------------
# config placement
# ----------------------------------------------------------------------------
install_nvim_config() {
  [ -d "$PAYLOAD/nvim" ] || { error "payload missing nvim/ — cannot continue"; exit 1; }
  info "Installing Neovim config -> $NVIM_DEST"
  backup_existing "$NVIM_DEST"
  run "mkdir -p '$(dirname "$NVIM_DEST")'"
  run "cp -R '$PAYLOAD/nvim' '$NVIM_DEST'"
}

install_claude_config() {
  has_component claude || return 0
  [ -d "$PAYLOAD/claude" ] || { warn "claude component requested but payload has no claude/ — skipping"; return 0; }
  info "Installing Claude Code config -> $CLAUDE_DEST"
  backup_existing "$CLAUDE_DEST"
  run "cp -R '$PAYLOAD/claude' '$CLAUDE_DEST'"
  # settings.json ships with a __HOME__ token; substitute the real home.
  if [ -f "$CLAUDE_DEST/settings.json" ]; then
    run "sed -i.bak 's#__HOME__#$HOME#g' '$CLAUDE_DEST/settings.json' && rm -f '$CLAUDE_DEST/settings.json.bak'"
  fi
  # seed project-launcher registry from the example if absent
  local pl="$CLAUDE_DEST/skills/project-launcher"
  if [ -f "$pl/projects.json.example" ] && [ ! -e "$pl/projects.json" ]; then
    run "cp '$pl/projects.json.example' '$pl/projects.json'"
  fi
}

bootstrap_plugins() {
  info "Bootstrapping Neovim plugins (lazy.nvim sync; may take a minute)..."
  local nvim_bin="nvim"
  command -v nvim >/dev/null 2>&1 || nvim_bin="$HOME/.local/bin/nvim"
  if [ "$DRY_RUN" -eq 1 ]; then
    plan "$nvim_bin --headless '+Lazy! sync' +qa"
  else
    "$nvim_bin" --headless "+Lazy! sync" +qa 2>&1 | tail -5 \
      || warn "lazy sync returned non-zero; open Neovim and run :Lazy to inspect."
  fi
}

# ----------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------
main() {
  if [ "$PLATFORM" = "macos" ]; then
    install_cli_macos
  else
    install_cli_linux
    install_font_linux
  fi
  install_nvim_config
  install_claude_config
  bootstrap_plugins
  info "Neovim environment ready. Launch: nvim"
}

main "$@"
