#!/bin/bash
set -e

BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Cleaning all build artifacts..."

# Remove build directories
rm -rf "$BUILD_DIR/aseprite"
rm -rf "$BUILD_DIR/aseprite-install"
rm -rf "$BUILD_DIR/skia"

# Remove Flatpak artifacts
rm -rf "$BUILD_DIR/flatpak-build"
rm -rf "$BUILD_DIR/flatpak-repo"
rm -f "$BUILD_DIR/aseprite.flatpak"

echo "==> Cleanup complete. Only scripts and manifest remain."
