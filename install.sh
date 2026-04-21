#!/bin/bash
set -e

git clone https://github.com/blakkguard/aseprite-linux-builder.git
cd aseprite-linux-builder
chmod +x *.sh
./podman_build.sh
cd ..
rm -rf aseprite-linux-builder

sudo mkdir -p /usr/local/share/applications

# 2. Write the file using a simple string (compatible with Fish and Bash)
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

# 3. Update the database
sudo update-desktop-database /usr/local/share/applications/
