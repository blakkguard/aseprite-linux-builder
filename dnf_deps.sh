#!/bin/bash
set -e
# Covers: Fedora, RHEL, CentOS Stream, AlmaLinux, Rocky Linux

LIBJPEG_TURBO_VERSION="3.0.1"
WORK_DIR="$(mktemp -d)"

echo "==> Installing system dependencies (dnf)..."

sudo dnf install -y \
    gcc-c++ \
    cmake \
    ninja-build \
    libX11-devel \
    libXcursor-devel \
    libXi-devel \
    libXrandr-devel \
    mesa-libGL-devel \
    fontconfig-devel \
    harfbuzz-devel \
    freetype-devel \
    libpng-devel \
    zlib-devel \
    libwebp-devel \
    git \
    python3 \
    unzip \
    wget \
    curl

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

echo "==> dnf_deps.sh completed successfully."
