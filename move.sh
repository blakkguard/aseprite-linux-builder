#!/bin/bash
set -e

#Check for privledges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo"
   exit 1
fi

BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGED="$BUILD_DIR/aseprite-install"
INSTALL_TARGET="/usr/local"

echo "==> Moving Aseprite to $INSTALL_TARGET ..."

if [ ! -d "$STAGED" ]; then
    echo "ERROR: Staged install not found at $STAGED"
    echo "       Run podman_build.sh first."
    exit 1
fi

sudo cp -r "$STAGED"/bin/*   "$INSTALL_TARGET/bin/"   2>/dev/null || true
sudo cp -r "$STAGED"/share/* "$INSTALL_TARGET/share/" 2>/dev/null || true
sudo cp -r "$STAGED"/lib/*   "$INSTALL_TARGET/lib/"   2>/dev/null || true

echo "==> Cleaning up all build artifacts..."
rm -rf "$BUILD_DIR/aseprite"*
rm -rf "$BUILD_DIR/skia"*
rm -rf "$BUILD_DIR/flatpak"*

echo "==> Creating menu entry..."
sudo tee /usr/local/share/applications/aseprite.desktop > /dev/null << 'DESKTOP'
[Desktop Entry]
Name=Aseprite
Comment=Animated Sprite Editor & Pixel Art Tool
Exec=aseprite
Icon=/usr/local/share/aseprite/data/icons/ase256.png
Terminal=false
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;
Keywords=pixel;art;sprite;animation;
StartupWMClass=aseprite
DESKTOP

# Refresh the database so it shows up immediately
if command -v kbuildsycoca6 &> /dev/null; then
    kbuildsycoca6
else
    update-desktop-database /usr/local/share/applications/ || true
fi

echo "==> move.sh completed successfully."
echo "    Aseprite installed at: $INSTALL_TARGET/bin/aseprite"
