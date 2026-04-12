#!/bin/bash
set -e

export CC=gcc
export CXX=g++
BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ASEPRITE_VERSION="v1.3.17"
SKIA_RELEASE="m124-08a5439a6b"
SKIA_ZIP="Skia-Linux-Release-x64.zip"
LIBJPEG_TURBO_VERSION="3.0.1"
DEPS_DIR="$BUILD_DIR/deps"

echo "==> Build directory: $BUILD_DIR"
echo "==> Building libjpeg-turbo..."

wget https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/${LIBJPEG_TURBO_VERSION}.tar.gz
tar -xzf ${LIBJPEG_TURBO_VERSION}.tar.gz
cd libjpeg-turbo-${LIBJPEG_TURBO_VERSION}
mkdir build && cd build
cmake \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX="$DEPS_DIR" \
    ..
make -j$(nproc)
make install
cd "$BUILD_DIR"
rm -rf libjpeg-turbo-${LIBJPEG_TURBO_VERSION} ${LIBJPEG_TURBO_VERSION}.tar.gz

echo "==> Downloading icudtl.dat..."
mkdir -p skia/third_party/externals/icu/flutter/
curl -L https://raw.githubusercontent.com/thlorenz/chromium-deps-icu52/master/android/icudtl.dat \
    -o skia/third_party/externals/icu/flutter/icudtl.dat

echo "==> Downloading pre-built Skia..."
wget https://github.com/aseprite/skia/releases/download/${SKIA_RELEASE}/${SKIA_ZIP}
unzip -o ${SKIA_ZIP} -d skia
rm -f ${SKIA_ZIP}

echo "==> Cloning Aseprite ${ASEPRITE_VERSION}..."
git clone --recursive --depth 1 -b ${ASEPRITE_VERSION} https://github.com/aseprite/aseprite.git
cd aseprite

echo "==> Configuring Aseprite..."
mkdir build && cd build
cmake \
    -DCMAKE_CXX_FLAGS="-Wno-dangling" \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_PREFIX="$BUILD_DIR/aseprite-install" \
    -DCMAKE_PREFIX_PATH="$DEPS_DIR" \
    -DLAF_BACKEND=skia \
    -DSKIA_DIR="$BUILD_DIR/skia" \
    -DSKIA_LIBRARY_DIR="$BUILD_DIR/skia/out/Release-x64" \
    -DSKIA_LIBRARY="$BUILD_DIR/skia/out/Release-x64/libskia.a" \
    ..

echo "==> Compiling Aseprite (this will take a while)..."
make -j$(nproc)
make install
cd "$BUILD_DIR"

echo "==> build.sh completed successfully."
echo "    Aseprite is staged at: $BUILD_DIR/aseprite-install"
