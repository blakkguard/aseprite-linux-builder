#!/bin/bash
set -e

REPO="blakkguard/aseprite-linux-builder"
ZIP_URL="https://github.com/${REPO}/archive/refs/heads/main.zip"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If we're already inside the repo, use the current directory directly.
# Otherwise, download and extract it.
if [ -f "$SCRIPT_DIR/podman_build.sh" ]; then
    echo "==> Running from existing directory: $SCRIPT_DIR"
    BUILDER_DIR="$SCRIPT_DIR"
    WORK_DIR=""
else
    echo "==> Downloading aseprite-linux-builder..."
    WORK_DIR="$(mktemp -d)"
    curl -fsSL "$ZIP_URL" -o "$WORK_DIR/builder.zip"
    unzip -q "$WORK_DIR/builder.zip" -d "$WORK_DIR"
    rm -f "$WORK_DIR/builder.zip"
    BUILDER_DIR="$(find "$WORK_DIR" -maxdepth 1 -type d -name 'aseprite-linux-builder-*')"
    chmod +x "$BUILDER_DIR"/*.sh
fi

echo "==> Installing dependencies..."
bash "$BUILDER_DIR/apt_deps.sh"

echo "==> Building Aseprite..."
bash "$BUILDER_DIR/podman_build.sh" --auto-move

if [ -n "$WORK_DIR" ]; then
    rm -rf "$WORK_DIR"
fi

sudo mkdir -p /usr/local/share/applications
echo "[Desktop Entry]
Name=Aseprite
Comment=Animated Sprite Editor & Pixel Art Tool
Exec=aseprite
Icon=/usr/local/share/aseprite/data/icons/ase256.png
Terminal=false
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;
Keywords=pixel;art;sprite;animation;
StartupWMClass=aseprite" | sudo tee /usr/local/share/applications/aseprite.desktop > /dev/null

sudo update-desktop-database /usr/local/share/applications/
echo "==> Done. Run: aseprite"
