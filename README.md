# Aseprite Linux Builder

Aseprite is a professional pixel art and animation tool. You can purchase it directly from the website for $19.99. This allows the develpers to continue to support Aseprite and continue to add new features. It comes with a Steam key.

- [Aseprite Official](https://www.aseprite.org/buy/)
- [Aseprite on Steam](https://store.steampowered.com/app/431730/Aseprite/)
- [Aseprite on itch.io](https://dacap.itch.io/aseprite)

These scripts let you build Aseprite from source on Linux for personal use, which is permitted under the Aseprite license. If you find it useful, buy it and support the developers who made it.

On Linux,Aseprite can built inside of a clean Ubuntu 24.04 podman container, then moved to your system. Your system is only written to at the final install step. The clean up script adds a .desktop file and it is Aseprite is fully intregrated.

---

## Linux

### Quick Start

You need `git`. That's it.

```bash
git clone https://github.com/blakkguard/aseprite-linux-builder.git
cd aseprite-linux-builder
chmod +x *.sh
./install.sh
```

`install.sh` asks for your password once upfront, detects your distro, installs Podman if needed, builds Aseprite inside a clean Ubuntu 24.04 container, and installs it to `/usr/local`. When it finishes, press the super key and launch Aseprite.

### How It Works

```
install.sh        → caches sudo, installs Podman (detects dnf/pacman/apt/zypper)
  podman_build.sh → spins up a clean Ubuntu 24.04 container
    apt_deps.sh   → inside container: installs build tools, compiles libjpeg-turbo
    build.sh      → inside container: downloads Skia, clones and compiles Aseprite
  move.sh         → copies to /usr/local, creates app menu entry, cleans up
```

### Build in Place

To build and run without installing system-wide:

```bash
./podman_build.sh
```

Aseprite stages at `./aseprite-install`. Run it directly from there:

```bash
./aseprite-install/bin/aseprite
```

When you're ready to install system-wide:

```bash
sudo ./move.sh
```

### Scripts

| Script | What it does |
|---|---|
| `install.sh` | Caches sudo, installs Podman, builds, and installs — all in sequence |
| `podman_build.sh` | Spins up the Ubuntu 24.04 container, runs the build, stages output locally |
| `apt_deps.sh` | Runs **inside the container** — installs build tools and compiles libjpeg-turbo |
| `build.sh` | Runs **inside the container** — downloads Skia, clones and compiles Aseprite |
| `move.sh` | Copies to `/usr/local`, creates app menu entry, cleans up all build artifacts |

### File Locations After Install (Linux)

| File | Location |
|---|---|
| Aseprite binary | `/usr/local/bin/aseprite` |
| Shared data | `/usr/local/share/aseprite/` |
| Icons | `/usr/local/share/aseprite/data/icons/` |
| Libraries | `/usr/local/lib/` |

---

## Why Building Aseprite From Source Is Hard

Aseprite uses Skia as its rendering backend — the same graphics library that powers Google Chrome. Skia is a massive codebase and on Linux most backends either fail to build or conflict with what your distro ships. Finding the right CMake flags took significant time to work out.

The second problem is libjpeg-turbo. Distros ship different versions, and Aseprite is particular about which one it links against. The solution is to build a known-good version inside the container before the Aseprite build starts.

The third problem is that every distro is different. The same build that works on Fedora fails on Arch because a package has a different name, or a library lives in a different path.

The Podman container solves all three on Linux — the build always happens inside a clean Ubuntu 24.04 environment regardless of what you're running on the host. On Windows, VS Build Tools 2022 provides the same known environment natively, so a container isn't needed.
