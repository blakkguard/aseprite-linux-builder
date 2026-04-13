#!/bin/bash
set -e
# Covers: Arch Linux, CachyOS, Manjaro, EndeavourOS, Garuda

LIBJPEG_TURBO_VERSION="3.0.1"
WORK_DIR="$(mktemp -d)"

echo "==> Installing system dependencies (pacman)..."

sudo pacman -Syu --noconfirm \
    gcc \
    cmake \
    ninja \
    libx11 \
    libxcursor \
    libxi \
    libxrandr \
    mesa \
    fontconfig \
    harfbuzz \
    freetype2 \
    libpng \
    zlib \
    libwebp \
    git-lfs \
    python \
    unzip \
    wget \
    curl \
    gn

git lfs install

echo "==> Building and installing libjpeg-turbo ${LIBJPEG_TURBO_VERSION}..."

cd "$WORK_DIR"
wget https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/${LIBJPEG_TURBO_VERSION}.tar.gz
tar -xzf ${LIBJPEG_TURBO_VERSION}.tar.gz

cmake \
    -S "$WORK_DIR/libjpeg-turbo-${LIBJPEG_TURBO_VERSION}" \
    -B "$WORK_DIR/libjpeg-turbo-build" \
    -DCMAKE_BUILD_TYPE=RELEASE

cmake --build "$WORK_DIR/libjpeg-turbo-build" -- -j$(nproc)
sudo cmake --install "$WORK_DIR/libjpeg-turbo-build"

echo "==> Cleaning up libjpeg-turbo build files..."
rm -rf "$WORK_DIR"

echo "==> pacman_deps.sh completed successfully."
