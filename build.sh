#!/bin/bash
set -e

export CC=gcc
export CXX=g++
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ASEPRITE_VERSION="v1.3.17"
SKIA_RELEASE="m124-08a5439a6b"
SKIA_ZIP="Skia-Linux-Release-x64.zip"

echo "==> Build directory: $BUILD_DIR"

echo "==> Downloading icudtl.dat..."
mkdir -p "$BUILD_DIR/skia/third_party/externals/icu/flutter/"
curl --retry 5 --retry-delay 10 --retry-connrefused -L \
    https://raw.githubusercontent.com/thlorenz/chromium-deps-icu52/master/android/icudtl.dat \
    -o "$BUILD_DIR/skia/third_party/externals/icu/flutter/icudtl.dat"

echo "==> Downloading pre-built Skia..."
wget --tries=5 --wait=10 --retry-connrefused \
    https://github.com/aseprite/skia/releases/download/${SKIA_RELEASE}/${SKIA_ZIP}
unzip -o ${SKIA_ZIP} -d "$BUILD_DIR/skia"
rm -f ${SKIA_ZIP}

echo "==> Cloning Aseprite ${ASEPRITE_VERSION}..."
CLONE_SUCCESS=false
for attempt in 1 2 3 4 5; do
    echo "    Clone attempt $attempt of 5..."
    if git clone --recursive --depth 1 -b ${ASEPRITE_VERSION} https://github.com/aseprite/aseprite.git; then
        CLONE_SUCCESS=true
        break
    else
        echo "    Clone failed, retrying submodules..."
        if [ -d "aseprite" ]; then
            cd aseprite
            git submodule update --init --recursive || true
            cd "$BUILD_DIR"
            CLONE_SUCCESS=true
            break
        fi
        echo "    Waiting 15 seconds before retry..."
        sleep 15
    fi
done

if [ "$CLONE_SUCCESS" = false ]; then
    echo "ERROR: Failed to clone Aseprite after 5 attempts."
    exit 1
fi

echo "==> Configuring Aseprite..."
cmake \
    -S "$BUILD_DIR/aseprite" \
    -B "$BUILD_DIR/aseprite/build" \
    -DCMAKE_CXX_FLAGS="-Wno-dangling" \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX="$BUILD_DIR/aseprite-install" \
    -DLAF_BACKEND=skia \
    -DSKIA_DIR="$BUILD_DIR/skia" \
    -DSKIA_LIBRARY_DIR="$BUILD_DIR/skia/out/Release-x64" \
    -DSKIA_LIBRARY="$BUILD_DIR/skia/out/Release-x64/libskia.a"

echo "==> Compiling Aseprite (this will take a while)..."
cmake --build "$BUILD_DIR/aseprite/build" -- -j$(nproc)
cmake --install "$BUILD_DIR/aseprite/build" --prefix "$BUILD_DIR/aseprite-install"

echo "==> build.sh completed successfully."
echo "    Aseprite is staged at: $BUILD_DIR/aseprite-install"
