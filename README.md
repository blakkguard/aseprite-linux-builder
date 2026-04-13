# Aseprite Linux Builder

Build [Aseprite](https://www.aseprite.org/) from source on Linux. Just wget, chmod, and run.

---

## Quick Start

Open a terminal and run the block for your distro. Download the deps script for your distro and `build.sh`, make them executable, then run the deps script first, followed by the build script.

**apt (Ubuntu, Debian, Mint, Pop!_OS):**
```bash
mkdir aseprite-build && cd aseprite-build
wget https://raw.githubusercontent.com/blakkguard/aseprite-linux-builder/main/apt_deps.sh
wget https://raw.githubusercontent.com/blakkguard/aseprite-linux-builder/main/build.sh
chmod +x *.sh
./apt_deps.sh && ./build.sh
```

**dnf (Fedora, RHEL, CentOS Stream, AlmaLinux, Rocky):**
```bash
mkdir aseprite-build && cd aseprite-build
wget https://raw.githubusercontent.com/blakkguard/aseprite-linux-builder/main/dnf_deps.sh
wget https://raw.githubusercontent.com/blakkguard/aseprite-linux-builder/main/build.sh
chmod +x *.sh
./dnf_deps.sh && ./build.sh
```

**pacman (Arch, CachyOS, Manjaro, EndeavourOS, Garuda):**
```bash
mkdir aseprite-build && cd aseprite-build
wget https://raw.githubusercontent.com/blakkguard/aseprite-linux-builder/main/pacman_deps.sh
wget https://raw.githubusercontent.com/blakkguard/aseprite-linux-builder/main/build.sh
chmod +x *.sh
./pacman_deps.sh && ./build.sh
```

**zypper (openSUSE Leap, Tumbleweed):**
```bash
mkdir aseprite-build && cd aseprite-build
wget https://raw.githubusercontent.com/blakkguard/aseprite-linux-builder/main/zypper_deps.sh
wget https://raw.githubusercontent.com/blakkguard/aseprite-linux-builder/main/build.sh
chmod +x *.sh
./zypper_deps.sh && ./build.sh
```

When the build finishes, Aseprite is staged in `aseprite-install/` next to your scripts. Run it directly from there:

```bash
./aseprite-install/bin/aseprite
```

---

## Install System-Wide (optional)

If you want to run `aseprite` from anywhere on your system, download and run `move.sh`. This copies Aseprite to `/usr/local` and cleans up all build artifacts:

```bash
wget https://raw.githubusercontent.com/blakkguard/aseprite-linux-builder/main/move.sh
chmod +x move.sh
./move.sh
```

After this, launch Aseprite from anywhere:

```bash
aseprite
```

The binary will be at `/usr/local/bin/aseprite`.

---

## What the Scripts Do

| Script | What it does |
|---|---|
| `apt_deps.sh` | Dependencies for Ubuntu, Debian, Mint, Pop!_OS |
| `dnf_deps.sh` | Dependencies for Fedora, RHEL, CentOS Stream, AlmaLinux, Rocky |
| `pacman_deps.sh` | Dependencies for Arch, CachyOS, Manjaro, EndeavourOS, Garuda |
| `zypper_deps.sh` | Dependencies for openSUSE Leap, Tumbleweed, SUSE Enterprise |
| `build.sh` | Downloads Skia, clones and compiles Aseprite |
| `move.sh` | Copies Aseprite to `/usr/local` and cleans up all build artifacts |

The deps script installs all system libraries and builds libjpeg-turbo from source. It will ask for your sudo password once. `build.sh` runs without sudo and builds everything in place.

---

## Adding Aseprite to Your Application Menu

After running `move.sh`, create a `.desktop` entry so Aseprite appears in your app menu:

```bash
sudo tee /usr/local/share/applications/aseprite.desktop > /dev/null << 'DESKTOP'
[Desktop Entry]
Name=Aseprite
Comment=Animated Sprite Editor & Pixel Art Tool
Exec=aseprite
Icon=/usr/local/share/aseprite/data/icons/ase256.png
Terminal=false
Type=Application
Categories=Graphics;2DGraphics;RasterGraphics;
Keywords=pixel;art;sprite;animation;
StartupWMClass=aseprite
DESKTOP
```

Then refresh your menu:

```bash
update-desktop-database /usr/local/share/applications/
```

**KDE Plasma:** If it doesn't show up, press `Alt+F2` and run `kbuildsycoca6`.  
**GNOME:** Log out and back in if it doesn't appear immediately.  
**XFCE/MATE/Cinnamon:** Right-click the menu and choose Reload, or log out and back in.

---

## Where Things Live on Linux

| File | Location |
|---|---|
| Aseprite binary | `/usr/local/bin/aseprite` |
| Shared data (icons, palettes, etc.) | `/usr/local/share/aseprite` |
| Icons | `/usr/local/share/aseprite/data/icons/` |
| Libraries | `/usr/local/lib/` |

---

## Support

**Support the Aseprite developers** — if you find Aseprite useful, please consider buying it officially:

- [Aseprite on Steam](https://store.steampowered.com/app/431730/Aseprite/) — $19.99
- [Aseprite on itch.io](https://dacap.itch.io/aseprite)

Building from source is permitted under the license for personal use, but purchasing supports the team that makes it.

**Support this project** — if these scripts saved you time, a coffee is appreciated:

☕ [Buy Me a Coffee](https://buymeacoffee.com/blakkguard)

---

## Requirements

- A 64-bit Linux system
- Internet connection (Skia and Aseprite source are downloaded during the build)
- ~3 GB of free disk space during the build (drops significantly after `move.sh` cleans up)

---

## Versions (edit at the top of `build.sh` to change)

| Component | Version |
|---|---|
| Aseprite | v1.3.17 |
| Skia | m124-08a5439a6b |
| libjpeg-turbo | 3.0.1 |

---

## Notes

- The build takes a while — Aseprite is a large codebase. Let it run.
- Each deps script builds libjpeg-turbo from source and installs it system-wide. This avoids version conflicts with distro packages.
- The `skia/`, `aseprite/`, and `aseprite-install/` folders are all cleaned up by `move.sh`. If you skipped `move.sh`, you can safely delete them manually once Aseprite is confirmed working.
- GitHub does not preserve file permissions — always run `chmod +x *.sh` after downloading.
