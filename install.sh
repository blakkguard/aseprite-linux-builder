#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Cache sudo upfront and keep it alive throughout the build ─────────────────
echo "==> This build takes 15-30 minutes. Enter your password now so it"
echo "    isn't needed again at the end."
sudo -v
( while true; do sudo -v; sleep 60; done ) &
SUDO_KEEP_ALIVE=$!
trap "kill $SUDO_KEEP_ALIVE 2>/dev/null" EXIT

# ── Install Podman on the host ────────────────────────────────────────────────
if ! command -v podman &>/dev/null; then
    echo "==> Podman not found. Installing..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -y && sudo apt-get install -y podman
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y podman
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm podman
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y podman
    else
        echo "ERROR: Could not detect package manager. Install podman manually and re-run."
        exit 1
    fi
else
    echo "==> Podman already installed: $(podman --version)"
fi

# ── Build ─────────────────────────────────────────────────────────────────────
echo "==> Starting build..."
bash "$SCRIPT_DIR/podman_build.sh"

# ── Install ───────────────────────────────────────────────────────────────────
echo "==> Installing system-wide..."
sudo bash "$SCRIPT_DIR/move.sh"

echo "==> Done. Run: aseprite"
