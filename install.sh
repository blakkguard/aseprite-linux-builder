#!/bin/bash
set -e

git clone https://github.com/blakkguard/aseprite-linux-builder.git
cd aseprite-linux-builder
chmod +x *.sh
./podman_build.sh
cd ..
rm -rf aseprite-linux-builder
aseprite
