#!/bin/bash
set -e
# Covers: Ubuntu, Kubuntu, Debian, Linux Mint, Pop!_OS, elementary OS

LIBJPEG_TURBO_VERSION="3.0.1"
WORK_DIR="$(mktemp -d)"

echo "==> Installing system dependencies (apt)..."

sudo apt-get update -y
sudo apt-get install -y \
    g++ \
    cmake \
    ninja-build \
    libx11-dev \
    libxcursor-dev \
    libxi-dev \
    libxrandr-dev \
    libgl1-mesa-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfreetype-dev \
    libpng-dev \
    zlib1g-dev \
    libwebp-dev \
    git \
    python3 \
    unzip \
    wget \
    curl \
    gn

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

echo "==> apt_deps.sh completed successfully."
