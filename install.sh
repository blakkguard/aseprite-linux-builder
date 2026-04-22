#!/bin/bash
set -e

REPO="blakkguard/aseprite-linux-builder"
ZIP_URL="https://github.com/${REPO}/archive/refs/heads/main.zip"
WORK_DIR="$(mktemp -d)"

echo "==> Downloading aseprite-linux-builder..."
curl -fsSL "$ZIP_URL" -o "$WORK_DIR/builder.zip"
unzip -q "$WORK_DIR/builder.zip" -d "$WORK_DIR"
rm -f "$WORK_DIR/builder.zip"

BUILDER_DIR="$(find "$WORK_DIR" -maxdepth 1 -type d -name 'aseprite-linux-builder-*')"
chmod +x "$BUILDER_DIR"/*.sh

echo "==> Installing dependencies..."
bash "$BUILDER_DIR/apt_deps.sh"

echo "==> Building Aseprite..."
bash "$BUILDER_DIR/podman_build.sh" --auto-move

cd /
rm -rf "$WORK_DIR"

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
