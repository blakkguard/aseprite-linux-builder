#!/bin/bash
# move.sh - Finalizes installation by moving binaries and creating menu entries.
set -e

# Ensure the script is running with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "ERROR: This script must be run with sudo."
   exit 1
fi

# Define paths relative to the script location
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGED="$BUILD_DIR/aseprite-install"
INSTALL_TARGET="/usr/local"

echo "==> Deploying Aseprite to $INSTALL_TARGET..."

# Safety check: Ensure the build actually finished and created the install folder
if [ ! -d "$STAGED" ]; then
    echo "ERROR: Staged install not found at $STAGED"
    echo "       Please run podman_build.sh successfully first."
    exit 1
fi

# Copy binaries, shared data (icons/translations), and libraries to system paths
# The '|| true' ensures the script continues even if a specific folder is empty
sudo cp -r "$STAGED"/bin/* "$INSTALL_TARGET/bin/"   2>/dev/null || true
sudo cp -r "$STAGED"/share/* "$INSTALL_TARGET/share/" 2>/dev/null || true
sudo cp -r "$STAGED"/lib/* "$INSTALL_TARGET/lib/"   2>/dev/null || true

echo "==> Cleaning up build artifacts (Skia and Aseprite source)..."
rm -rf "$BUILD_DIR/aseprite"*
rm -rf "$BUILD_DIR/skia"*
rm -rf "$BUILD_DIR/flatpak"*

echo "==> Setting up Desktop Menu Entry..."

# Create the applications directory if it doesn't exist (this is where mkdir goes)
sudo mkdir -p /usr/local/share/applications

# Generate the .desktop file for the application menu
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

# Refresh the system desktop database so the icon appears immediately
if command -v kbuildsycoca6 &> /dev/null; then
    kbuildsycoca6
else
    # Fallback for non-KDE or older systems
    update-desktop-database /usr/local/share/applications/ || true
fi

echo "==> Installation complete!"
echo "    Binary: $INSTALL_TARGET/bin/aseprite"
