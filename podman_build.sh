#!/bin/bash
set -e

LIBJPEG_TURBO_VERSION="3.1.0"
IMAGE="ubuntu:24.04"
WORKDIR="/build"
CACHE_DIR="$HOME/aseprite-cache"

# Ensure host cache directory exists
mkdir -p "$CACHE_DIR"

echo "==> Pulling base image: $IMAGE"
podman pull "$IMAGE"

echo "==> Running build inside container..."
podman run --rm \
    --network host \
    -v "$(pwd):$WORKDIR:Z" \
    -v "$CACHE_DIR:/cache:Z" \
    -w "$WORKDIR" \
    "$IMAGE" \
    bash -c '
        set -e

        # ── System deps ──────────────────────────────────────────────────────
        echo "==> Installing system dependencies..."
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y
        apt-get install -y \
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

        # ── libjpeg-turbo ────────────────────────────────────────────────────
        echo "==> Building libjpeg-turbo '"$LIBJPEG_TURBO_VERSION"' from cache..."
        WORK_DIR="$(mktemp -d)"
        cd "$WORK_DIR"
        
        # Check if archive exists in mounted /cache, download if missing
        if [ ! -f "/cache/libjpeg-turbo-'"$LIBJPEG_TURBO_VERSION"'.tar.gz" ]; then
            echo "--> Cache miss: downloading libjpeg-turbo..."
            wget -O "/cache/libjpeg-turbo-'"$LIBJPEG_TURBO_VERSION"'.tar.gz" \
                "https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/'"$LIBJPEG_TURBO_VERSION"'/libjpeg-turbo-'"$LIBJPEG_TURBO_VERSION"'.tar.gz"
        fi

        tar -xzf "/cache/libjpeg-turbo-'"$LIBJPEG_TURBO_VERSION"'.tar.gz" -C "$WORK_DIR"
        
        cmake \
            -S "$WORK_DIR/libjpeg-turbo-'"$LIBJPEG_TURBO_VERSION"'" \
            -B "$WORK_DIR/libjpeg-turbo-build" \
            -DCMAKE_BUILD_TYPE=RELEASE \
            -DCMAKE_POLICY_VERSION_MINIMUM=3.5
        cmake --build "$WORK_DIR/libjpeg-turbo-build" -- -j$(nproc)
        cmake --install "$WORK_DIR/libjpeg-turbo-build"
        rm -rf "$WORK_DIR"

        # ── Aseprite build ───────────────────────────────────────────────────
        echo "==> Running build.sh..."
        cd /build
        bash build.sh
    '

echo ""
echo "==> Build complete. Aseprite staged at: $(pwd)/aseprite-install"
echo "    Run directly:        ./aseprite-install/bin/aseprite"
echo "    Install system-wide: sudo ./move.sh"
echo ""
