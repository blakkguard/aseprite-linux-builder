#!/bin/bash
set -e
# Covers: openSUSE Leap, openSUSE Tumbleweed, SUSE Linux Enterprise

LIBJPEG_TURBO_VERSION="3.1.0"
WORK_DIR="$(mktemp -d)"

echo "==> Installing system dependencies (zypper)..."

sudo zypper install -y \
    gcc-c++ \
    cmake \
    ninja \
    libX11-devel \
    libXcursor-devel \
    libXi-devel \
    libXrandr-devel \
    Mesa-libGL-devel \
    fontconfig-devel \
    harfbuzz-devel \
    freetype2-devel \
    libpng16-devel \
    zlib-devel \
    libwebp-devel \
    git \
    python3 \
    unzip \
    wget \
    curl \
    gn

echo "==> Building and installing libjpeg-turbo ${LIBJPEG_TURBO_VERSION}..."

cd "$WORK_DIR"
wget https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/${LIBJPEG_TURBO_VERSION}/libjpeg-turbo-${LIBJPEG_TURBO_VERSION}.tar.gz
tar -xzf libjpeg-turbo-${LIBJPEG_TURBO_VERSION}.tar.gz

cmake \
    -S "$WORK_DIR/libjpeg-turbo-${LIBJPEG_TURBO_VERSION}" \
    -B "$WORK_DIR/libjpeg-turbo-build" \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5

cmake --build "$WORK_DIR/libjpeg-turbo-build" -- -j$(nproc)
sudo cmake --install "$WORK_DIR/libjpeg-turbo-build"

echo "==> Cleaning up libjpeg-turbo build files..."
rm -rf "$WORK_DIR"

echo "==> zypper_deps.sh completed successfully."
