#!/bin/bash
set -e

BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLATPAK_ID="org.aseprite.Aseprite"
BUNDLE="aseprite.flatpak"

echo "==> Checking for flatpak-builder..."
if ! command -v flatpak-builder &> /dev/null; then
    echo "ERROR: flatpak-builder is not installed."
    echo "       Install it with your package manager:"
    echo "       apt:    sudo apt install flatpak-builder"
    echo "       dnf:    sudo dnf install flatpak-builder"
    echo "       pacman: sudo pacman -S flatpak-builder"
    echo "       zypper: sudo zypper install flatpak-builder"
    exit 1
fi

echo "==> Checking for freedesktop runtime..."
if ! flatpak info org.freedesktop.Platform//23.08 &> /dev/null; then
    echo "==> Installing freedesktop runtime and SDK..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub org.freedesktop.Platform//23.08 org.freedesktop.Sdk//23.08
fi

echo "==> Building Aseprite flatpak (this will take a while)..."
flatpak-builder \
    --force-clean \
    --repo="$BUILD_DIR/flatpak-repo" \
    "$BUILD_DIR/flatpak-build" \
    "$BUILD_DIR/org.aseprite.Aseprite.json"

echo "==> Bundling into $BUNDLE..."
flatpak build-bundle \
    "$BUILD_DIR/flatpak-repo" \
    "$BUILD_DIR/$BUNDLE" \
    "$FLATPAK_ID"

echo "==> build_flatpak.sh completed successfully."
echo "    Install with:"
echo "    flatpak install $BUILD_DIR/$BUNDLE"
echo "    Run with:"
echo "    flatpak run $FLATPAK_ID"
