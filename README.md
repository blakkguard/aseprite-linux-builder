# Aseprite Linux Builder

Aseprite is a professional pixel art and animation tool. It costs $19.99 and is worth every penny — please consider buying it officially:

- [Aseprite on Steam](https://store.steampowered.com/app/431730/Aseprite/) — $19.99
- [Aseprite on itch.io](https://dacap.itch.io/aseprite)

These scripts let you build Aseprite from source on Linux for personal use, which is permitted under the Aseprite license. If you find it useful, buy it and support the developers who made it.

Aseprite is built inside a clean Ubuntu 24.04 Podman container, then moved to your system. Your host is never touched during the build — only the final install writes to `/usr/local`.

---

## Quick Start

You need `curl` and `unzip`. That's it.

```bash
curl -fsSL https://github.com/blakkguard/aseprite-linux-builder/archive/refs/heads/main.zip -o builder.zip
unzip builder.zip
cd aseprite-linux-builder-main
chmod +x *.sh
./install.sh
```

`install.sh` will detect your distro, install Podman, build Aseprite inside a clean Ubuntu 24.04 container, and install it to `/usr/local`. Your sudo password is required once. When it finishes, press the super key and launch Aseprite.

---

## What the Scripts Do

| Script | What it does |
|---|---|
| `install.sh` | Detects your distro, installs Podman, runs the full build and install in sequence |
| `podman_build.sh` | Builds Aseprite inside an Ubuntu 24.04 container and stages the output locally |
| `apt_deps.sh` | Runs inside the container — installs build tools and compiles libjpeg-turbo |
| `build.sh` | Runs inside the container — downloads Skia, clones and compiles Aseprite |
| `move.sh` | Runs on the host — copies Aseprite to `/usr/local`, creates the app menu entry, cleans up |

---

## Build in Place

If you want to build without installing system-wide, run `podman_build.sh` directly. Aseprite will be staged at `./aseprite-install` and you can run it from there. When you're ready to install, run `move.sh`:

```bash
./podman_build.sh
sudo ./move.sh
```

---

## File Locations After Install

| File | Location |
|---|---|
| Aseprite binary | `/usr/local/bin/aseprite` |
| Shared data (icons, palettes, etc.) | `/usr/local/share/aseprite/` |
| Icons | `/usr/local/share/aseprite/data/icons/` |
| Libraries | `/usr/local/lib/` |

---

## Versions

Edit the version variables at the top of `build.sh` to change what gets built.

| Component | Version |
|---|---|
| Aseprite | v1.3.17 |
| Skia | m124-08a5439a6b |
| libjpeg-turbo | 3.1.0 |

---

## Notes

- The build takes 15–30 minutes depending on your hardware. Let it run.
- A stable internet connection is required — Skia and Aseprite source are downloaded during the build. The scripts include retry logic for flaky connections.
- `move.sh` cleans up all build artifacts after installing.
- These scripts are hosted on GitHub. `curl` is used to download them — no `git` required.

---

## Why Building Aseprite From Source Is Hard

Aseprite uses Skia as its rendering backend — the same graphics library that powers Google Chrome. Skia is a massive codebase with backends for Apple Metal, Vulkan, Dawn, and more. On Linux, most of those backends either fail to build or pull in dependencies that conflict with what your distro ships. Finding the right CMake flags took significant time to work out.

The second problem is libjpeg-turbo. Distros ship different versions, and Aseprite is particular about which one it links against. The solution is to build libjpeg-turbo from a known-good version before the Aseprite build starts, so CMake always finds the right one.

The third problem is that every distro is different. The same build that works on Fedora fails on Arch because a package has a different name, or a library lives in a different path, or a version is too new or too old.

The Podman approach solves all three. The build happens inside a clean Ubuntu 24.04 container with a known, stable set of packages. Your host system is never touched during the build. When it finishes, the output is moved to your system by `move.sh` and the container is discarded.
