#!/bin/bash
set -e

# Ensure script is run with elevated permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo"
   exit 1
fi

BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Removing Aseprite binaries and system files..."
# Remove installed binaries, shared resources, and libraries
rm -f  "/usr/local/bin/aseprite"
rm -rf "/usr/local/share/aseprite"
rm -f  "/usr/local/share/applications/aseprite.desktop"

# Verify and remove staged local installation folders if present
if [ -d "$BUILD_DIR/aseprite-install" ]; then
    echo "==> Removing local staged build..."
    rm -rf "$BUILD_DIR/aseprite-install"
fi

echo "==> Updating desktop entry database..."
if command -v kbuildsycoca6 &> /dev/null; then
    kbuildsycoca6
else
    update-desktop-database /usr/local/share/applications/ || true
fi

# Verification Step
if [ ! -f "/usr/local/bin/aseprite" ] && [ ! -d "/usr/local/share/aseprite" ]; then
    echo "==> Aseprite has been successfully removed from your system."
else
    echo "WARNING: Some files could not be automatically removed. Please check /usr/local/."
fi
