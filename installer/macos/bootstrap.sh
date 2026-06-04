#!/usr/bin/env bash
#
# bootstrap.sh — macOS installer logic. Installs the selected components via
# Homebrew and delegates the Neovim environment to the shared common installer.
#
# Run as the LOGGED-IN USER (never root — Homebrew refuses to run as root).
# The .pkg postinstall scripts call this with `sudo -u <user>`; you can also run
# it directly for a no-package install:
#
#   installer/macos/bootstrap.sh --payload <repo-root> --components wezterm,core,nerd-font,claude
#
# Components: core, nerd-font, wezterm, alacritty, claude  (see installer/manifest.json)
#
set -euo pipefail

PAYLOAD=""
COMPONENTS="core,nerd-font,wezterm"
DRY_RUN=0

info()  { printf '\033[1;34m[info]\033[0m  %s\n' "$*"; }
warn()  { printf '\033[1;33m[warn]\033[0m  %s\n' "$*"; }
error() { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }
run()   { if [ "$DRY_RUN" -eq 1 ]; then printf '\033[1;36m[plan]\033[0m  %s\n' "$*"; else eval "$@"; fi; }
has()   { case ",$COMPONENTS," in *",$1,"*) return 0 ;; *) return 1 ;; esac; }

while [ $# -gt 0 ]; do
  case "$1" in
    --payload)    PAYLOAD="$2"; shift 2 ;;
    --components) COMPONENTS="$2"; shift 2 ;;
    --dry-run)    DRY_RUN=1; shift ;;
    -h|--help)    sed -n '2,17p' "$0" | sed 's/^#\{0,1\} \{0,1\}//'; exit 0 ;;
    *) error "unknown arg: $1"; exit 2 ;;
  esac
done
[ -n "$PAYLOAD" ] || { error "--payload <dir> required"; exit 2; }

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMON="$SELF_DIR/../common/install-nvim-env.sh"
[ -f "$COMMON" ] || COMMON="$PAYLOAD/installer/common/install-nvim-env.sh"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TS="$(date +%Y%m%d-%H%M%S)"

ensure_brew() {
  # Put brew on PATH if it is already installed but not yet exported
  # (common when running from a non-login shell or a pkg postinstall).
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$b" ] && eval "$("$b" shellenv)"
  done
  command -v brew >/dev/null 2>&1 && return
  info "Installing Homebrew..."
  run 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$b" ] && eval "$("$b" shellenv)"
  done
}

backup_existing() {
  local t="$1"
  if [ -L "$t" ]; then run "rm -f '$t'";
  elif [ -e "$t" ]; then warn "Backing up $t -> $t.backup-$TS"; run "mv '$t' '$t.backup-$TS'"; fi
}

install_terminal_wezterm() {
  ensure_brew
  info "Installing WezTerm (brew cask)..."
  run "brew install --cask wezterm || true"
  info "Placing WezTerm config -> ~/.wezterm.lua"
  backup_existing "$HOME/.wezterm.lua"
  run "cp '$PAYLOAD/wezterm/.wezterm.lua' '$HOME/.wezterm.lua'"
}

install_terminal_alacritty() {
  ensure_brew
  info "Installing Alacritty (brew cask)..."
  run "brew install --cask alacritty || true"
  info "Placing Alacritty config -> $CONFIG_HOME/alacritty/alacritty.toml"
  backup_existing "$CONFIG_HOME/alacritty/alacritty.toml"
  run "mkdir -p '$CONFIG_HOME/alacritty'"
  run "cp '$PAYLOAD/alacritty/macos/alacritty.toml' '$CONFIG_HOME/alacritty/alacritty.toml'"
}

install_font() {
  ensure_brew
  info "Installing D2CodingLigature Nerd Font (brew cask)..."
  run "brew install --cask font-d2coding-nerd-font || true"
}

main() {
  has wezterm   && install_terminal_wezterm
  has alacritty && install_terminal_alacritty
  has nerd-font && install_font

  # Neovim + CLI + (optionally) Claude config -> shared installer.
  # Only invoked when the selection actually includes one of those components.
  # Font is handled above via brew cask, so tell common to skip it.
  local common_components=""
  has core   && common_components="core"
  has claude && common_components="${common_components:+$common_components,}claude"
  if [ -n "$common_components" ]; then
    local flags="--payload '$PAYLOAD' --components '$common_components' --no-font"
    [ "$DRY_RUN" -eq 1 ] && flags="$flags --dry-run"
    info "Handing Neovim environment to common installer ($common_components)..."
    run "/bin/bash '$COMMON' $flags"
  fi

  info "macOS setup complete."
}
main "$@"
