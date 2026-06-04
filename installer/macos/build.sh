#!/usr/bin/env bash
#
# build.sh — build the macOS .dmg installer (runs on a macOS host / CI runner).
#
# Produces an unsigned WezTerm-DevEnv-<version>.dmg containing a component-based
# .pkg. Signing / notarization is out of scope (see installer/README.md for how
# to add it). Requires: pkgbuild, productbuild, hdiutil (all ship with macOS).
#
# Usage:
#   installer/macos/build.sh [--version X.Y.Z] [--out <dir>]
#
set -euo pipefail

VERSION="0.0.0"
OUT_DIR="dist"
while [ $# -gt 0 ]; do
  case "$1" in
    --version) VERSION="$2"; shift 2 ;;
    --out)     OUT_DIR="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MAC_DIR="$REPO_ROOT/installer/macos"
ID_PREFIX="com.sejuneoh.wezterm-devenv"
PAYLOAD_INSTALL_PATH="/usr/local/share/wezterm-devenv"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
PKGROOT="$WORK/pkgroot"
PKGS="$WORK/pkgs"
SCRIPTS="$WORK/scripts"
DMGROOT="$WORK/dmgroot"
mkdir -p "$PKGS" "$DMGROOT" "$OUT_DIR"

echo "==> Staging payload at $PAYLOAD_INSTALL_PATH"
DEST="$PKGROOT$PAYLOAD_INSTALL_PATH"
mkdir -p "$DEST"
# Bundle the configs + installer so postinstalls/bootstrap can run offline.
for d in nvim wezterm alacritty claude installer; do
  [ -e "$REPO_ROOT/$d" ] && cp -R "$REPO_ROOT/$d" "$DEST/"
done

echo "==> Generating per-component postinstall scripts"
for comp in core nerd-font wezterm alacritty claude; do
  mkdir -p "$SCRIPTS/$comp"
  sed "s/^COMPONENT=\"core\"/COMPONENT=\"$comp\"/" \
      "$MAC_DIR/scripts/core/postinstall" > "$SCRIPTS/$comp/postinstall"
  chmod +x "$SCRIPTS/$comp/postinstall"
done

echo "==> pkgbuild: core (with payload)"
pkgbuild --root "$PKGROOT" --install-location / \
         --scripts "$SCRIPTS/core" \
         --identifier "$ID_PREFIX.core" --version "$VERSION" \
         "$PKGS/core.pkg"

for comp in nerd-font wezterm alacritty claude; do
  echo "==> pkgbuild: $comp (scripts only)"
  pkgbuild --nopayload \
           --scripts "$SCRIPTS/$comp" \
           --identifier "$ID_PREFIX.$comp" --version "$VERSION" \
           "$PKGS/$comp.pkg"
done

echo "==> productbuild: combine into selectable installer"
FINAL_PKG="$DMGROOT/WezTerm-DevEnv.pkg"
productbuild --distribution "$MAC_DIR/Distribution.xml" \
             --package-path "$PKGS" \
             "$FINAL_PKG"

# Optional signing if a Developer ID is available in the environment.
if [ -n "${MACOS_PKG_SIGN_IDENTITY:-}" ]; then
  echo "==> productsign with $MACOS_PKG_SIGN_IDENTITY"
  productsign --sign "$MACOS_PKG_SIGN_IDENTITY" "$FINAL_PKG" "$FINAL_PKG.signed"
  mv "$FINAL_PKG.signed" "$FINAL_PKG"
fi

cp "$REPO_ROOT/installer/README.md" "$DMGROOT/README.md" 2>/dev/null || true

OUT_DMG="$OUT_DIR/WezTerm-DevEnv-$VERSION.dmg"
echo "==> hdiutil: create $OUT_DMG"
rm -f "$OUT_DMG"
hdiutil create -volname "WezTerm DevEnv" -srcfolder "$DMGROOT" \
               -ov -format UDZO "$OUT_DMG"

echo "==> Done: $OUT_DMG"
