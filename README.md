# Aseprite Linux Builder
#
---
## This content was produced by Anrhropic Claude
## Why This Is Hard and Why These Scripts Work

Building Aseprite from source on Linux is not straightforward. Aseprite uses Skia as its rendering backend — the same graphics library that powers Google Chrome. Skia is a massive codebase with backends for Apple Metal, Vulkan, Dawn, and more. On Linux, most of those backends either fail to build or pull in dependencies that conflict with what your distro has installed. Finding the right combination of cmake flags to strip out what you don't need and keep what you do took significant trial and error.

The second problem is libjpeg-turbo. Distros ship different versions, and Aseprite is particular about which one it links against. The solution is to build libjpeg-turbo from a known-good source version and install it system-wide before the Aseprite build starts, so cmake always finds the right one regardless of what your distro provides.

The third problem is that every distro is different. The same build that works on Fedora fails on Arch because a package has a different name, or a library lives in a different path, or a version is too new or too old.

The Podman approach solves all of this. Instead of fighting your host distro, the build happens inside a clean Ubuntu 24.04 container with a known, stable set of packages. The container handles all dependency installation, builds libjpeg-turbo from source, downloads the correct pre-built Skia binary, and compiles Aseprite with the exact cmake flags that produce a working binary. Your host system never gets touched. When the build finishes, the output is copied out of the container and onto your system with `move.sh`.

The result is that building Aseprite from source on any Linux distro comes down to two things: install `git` and `podman`, then run `install.sh`. Everything else is handled.

Build Aseprite from source on Linux.

---

## Quick Start

Install git if you don't have it, clone the repo, and run the scripts for your distro.

**Install git:**
```bash
# apt (Ubuntu, Debian, Mint, Pop!_OS)
sudo apt install git

# dnf (Fedora, RHEL, CentOS Stream)
sudo dnf install git

# pacman (Arch, CachyOS, Manjaro)
sudo pacman -S git

# zypper (openSUSE)
sudo zypper install git
```

**Clone the repo:**
```bash
git clone https://github.com/blakkguard/aseprite-linux-builder.git
cd aseprite-linux-builder
chmod +x *.sh
```

**Run the deps script for your distro:**
```bash
# apt (Ubuntu, Debian, Mint, Pop!_OS)
./apt_deps.sh

# dnf (Fedora, RHEL, CentOS Stream, AlmaLinux, Rocky)
./dnf_deps.sh

# pacman (Arch, CachyOS, Manjaro, EndeavourOS, Garuda)
./pacman_deps.sh

# zypper (openSUSE Leap, Tumbleweed)
./zypper_deps.sh
```

**Build Aseprite:**
```bash
./build.sh
```

When the build finishes, Aseprite is staged in `aseprite-install/` next to your scripts. Run it directly from there:

```bash
./aseprite-install/bin/aseprite
```

---

## What to Do With the Build

You have three options once the build finishes:

### Option 1 — Run in place
Just run it directly from the build folder — no installation needed:
```bash
./aseprite-install/bin/aseprite
```

### Option 2 — Install system-wide with move.sh
Copies Aseprite to `/usr/local` so you can launch it from anywhere, then cleans up all build artifacts:
```bash
./move.sh
```

After this, launch Aseprite from anywhere:
```bash
aseprite
```

### Option 3 — Build a personal Flatpak
If you want a portable flatpak you can install on any distro, use the included flatpak scripts. The resulting flatpak is for **personal use only and must not be distributed**.

Install flatpak-builder first:
```bash
# apt
sudo apt install flatpak-builder

# dnf
sudo dnf install flatpak-builder

# pacman
sudo pacman -S flatpak-builder

# zypper
sudo zypper install flatpak-builder
```

Then build the flatpak:
```bash
./build_flatpak.sh
```

Once it finishes, install and run it:
```bash
flatpak install aseprite.flatpak
flatpak run org.aseprite.Aseprite
```

The flatpak is fully self-contained — Skia, libjpeg-turbo, and Aseprite are all bundled inside. Install it on any distro that has flatpak installed.

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
| `build_flatpak.sh` | Builds a self-contained personal flatpak |
| `org.aseprite.Aseprite.json` | Flatpak manifest |

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
- GitHub does not preserve file permissions — always run `chmod +x *.sh` after cloning.
