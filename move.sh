#!/bin/bash
set -e

BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGED="$BUILD_DIR/aseprite-install"
INSTALL_TARGET="/usr/local"

echo "==> Moving Aseprite to $INSTALL_TARGET ..."

if [ ! -d "$STAGED" ]; then
    echo "ERROR: Staged install not found at $STAGED"
    echo "       Run build.sh first."
    exit 1
fi

sudo cp -r "$STAGED"/bin/*     "$INSTALL_TARGET/bin/"     2>/dev/null || true
sudo cp -r "$STAGED"/share/*   "$INSTALL_TARGET/share/"   2>/dev/null || true
sudo cp -r "$STAGED"/lib/*     "$INSTALL_TARGET/lib/"     2>/dev/null || true

echo "==> Cleaning up build artifacts..."
rm -rf "$BUILD_DIR/aseprite"
rm -rf "$BUILD_DIR/aseprite-install"
rm -rf "$BUILD_DIR/deps"
rm -rf "$BUILD_DIR/skia"

echo "==> move.sh completed successfully."
echo "    Aseprite is installed at: $INSTALL_TARGET/bin/aseprite"
