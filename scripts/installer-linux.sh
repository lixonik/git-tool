#!/bin/sh
# GitTool linux installer: self-extracting archive.
# Usage: sh GitTool-<ver>-linux-x64-installer.sh [install-prefix]
#   default prefix: ~/.local/share  (install dir becomes <prefix>/GitTool)
set -e

PREFIX="${1:-$HOME/.local/share}"
INSTALL_DIR="$PREFIX/GitTool"
CONFIG_DIR="$HOME/.config/GitTool2026.2"

echo "Installing GitTool to $INSTALL_DIR ..."
mkdir -p "$PREFIX"
rm -rf "$INSTALL_DIR"

ARCHIVE_LINE=$(awk '/^__ARCHIVE_BELOW__$/ {print NR + 1; exit 0}' "$0")
tail -n +"$ARCHIVE_LINE" "$0" | tar xz -C "$PREFIX"
mv "$PREFIX/gittool" "$INSTALL_DIR"

# Preseed per-user defaults (Classic UI plugin, trimmed menus) on first install only.
if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p "$CONFIG_DIR/options" "$CONFIG_DIR/plugins"
  cp -r "$INSTALL_DIR/config-template/plugins/." "$CONFIG_DIR/plugins/" 2>/dev/null || true
  cp "$INSTALL_DIR/config-template/options/"*.xml "$CONFIG_DIR/options/" 2>/dev/null || true
fi

mkdir -p "$HOME/.local/bin"
ln -sf "$INSTALL_DIR/bin/gittool.sh" "$HOME/.local/bin/gittool"

APPS_DIR="$HOME/.local/share/applications"
mkdir -p "$APPS_DIR"
cat > "$APPS_DIR/gittool.desktop" <<EOF
[Desktop Entry]
Name=GitTool
Comment=Standalone JetBrains git tool
Exec="$INSTALL_DIR/bin/gittool.sh" %f
Icon=$INSTALL_DIR/bin/gittool.svg
Terminal=false
Type=Application
Categories=Development;RevisionControl;
StartupWMClass=jetbrains-gittool
EOF

echo "Done."
echo "  launch:   gittool   (make sure ~/.local/bin is on PATH)"
echo "  or:       $INSTALL_DIR/bin/gittool.sh"
echo "  requires: git on PATH (apt/dnf install git)"
exit 0
__ARCHIVE_BELOW__
