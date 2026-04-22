#!/bin/bash
set -e

REPO="https://github.com/blakkguard/aseprite-linux-builder.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Cache sudo upfront and keep it alive throughout the build ─────────────────
echo "==> This build takes 15-30 minutes. Enter your password now so it"
echo "    isn't needed again at the end."
sudo -v
( while true; do sudo -v; sleep 60; done ) &
SUDO_KEEP_ALIVE=$!
trap "kill $SUDO_KEEP_ALIVE 2>/dev/null" EXIT

# ── Detect if already running from inside the repo ───────────────────────────
if [ -f "$SCRIPT_DIR/podman_build.sh" ]; then
    echo "==> Running from existing directory: $SCRIPT_DIR"
    BUILDER_DIR="$SCRIPT_DIR"
    WORK_DIR=""
else
    # ── Install git if missing ────────────────────────────────────────────────
    if ! command -v git &>/dev/null; then
        echo "==> git not found. Installing..."
        if command -v apt-get &>/dev/null; then
            sudo apt-get update -y && sudo apt-get install -y git
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y git
        elif command -v pacman &>/dev/null; then
            sudo pacman -Sy --noconfirm git
        elif command -v zypper &>/dev/null; then
            sudo zypper install -y git
        else
            echo "ERROR: Could not detect package manager. Install git manually and re-run."
            exit 1
        fi
    fi
    echo "==> Cloning aseprite-linux-builder..."
    WORK_DIR="$(mktemp -d)"
    git clone --depth 1 "$REPO" "$WORK_DIR/aseprite-linux-builder"
    BUILDER_DIR="$WORK_DIR/aseprite-linux-builder"
    chmod +x "$BUILDER_DIR"/*.sh
fi

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
bash "$BUILDER_DIR/podman_build.sh"

# ── Install ───────────────────────────────────────────────────────────────────
echo "==> Installing system-wide..."
sudo bash "$BUILDER_DIR/move.sh"

if [ -n "$WORK_DIR" ]; then
    rm -rf "$WORK_DIR"
fi

echo "==> Done. Run: aseprite"
