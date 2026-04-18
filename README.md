# Aseprite Linux Builder

Aseprite is a professional pixel art and animation tool. It costs $19.99 and is worth every penny — please consider buying it officially:

- [Aseprite on Steam](https://store.steampowered.com/app/431730/Aseprite/) — $19.99
- [Aseprite on itch.io](https://dacap.itch.io/aseprite)

These scripts let you build Aseprite from source on Linux for personal use, which is permitted under the Aseprite license. If you find it useful, buy it and support the developers who made it.

---

## Quick Start

Install `git` and `podman`, then run `install.sh`:

```bash
# Fedora, RHEL, CentOS Stream
sudo dnf install git podman

# Arch, CachyOS, Manjaro
sudo pacman -S git podman

# Ubuntu, Debian, Mint, Pop!_OS
sudo apt install git podman

# openSUSE
sudo zypper install git podman
```

```bash
chmod +x install.sh
./install.sh
```

That's it. `install.sh` clones the repo, builds Aseprite inside a clean Ubuntu 24.04 Podman container, installs it to `/usr/local`, cleans up everything, and launches Aseprite. Your sudo password is required once when installing.

> **Already have the files?** If you downloaded the ZIP from GitHub, skip the clone — just `cd` into the folder, `chmod +x *.sh`, and run `./podman_build.sh` directly.

---

## Other Build Options

The Podman path above is recommended, but you can also build natively or as a personal Flatpak.

### Native Build

Install dependencies for your distro, then build:

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

Then build:
```bash
./build.sh
sudo ./move.sh
```

### Personal Flatpak

Builds a self-contained Flatpak for personal use. **Do not distribute the resulting Flatpak.**

Install `flatpak-builder` first:
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

Then build and install:
```bash
./build_flatpak.sh
flatpak install aseprite.flatpak
flatpak run org.aseprite.Aseprite
```

---

## Adding Aseprite to Your App Menu

After installing, create a `.desktop` entry so Aseprite appears in your application menu:

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

Refresh your menu:
```bash
update-desktop-database /usr/local/share/applications/
```

**KDE Plasma:** If it doesn't appear, press `Alt+F2` and run `kbuildsycoca6`.  
**GNOME:** Log out and back in.  
**XFCE / MATE / Cinnamon:** Right-click the menu and choose Reload, or log out and back in.

---

## What the Scripts Do

| Script | What it does |
|---|---|
| `install.sh` | Full install in one shot — clone, build, install, clean up |
| `podman_build.sh` | Builds inside Ubuntu 24.04 container, works on any host distro |
| `apt_deps.sh` | Dependencies for Ubuntu, Debian, Mint, Pop!_OS |
| `dnf_deps.sh` | Dependencies for Fedora, RHEL, CentOS Stream, AlmaLinux, Rocky |
| `pacman_deps.sh` | Dependencies for Arch, CachyOS, Manjaro, EndeavourOS, Garuda |
| `zypper_deps.sh` | Dependencies for openSUSE Leap, Tumbleweed |
| `build.sh` | Downloads Skia, clones and compiles Aseprite |
| `move.sh` | Copies Aseprite to `/usr/local`, cleans all build artifacts |
| `build_flatpak.sh` | Builds a self-contained personal Flatpak |
| `org.aseprite.Aseprite.json` | Flatpak manifest |

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
- `move.sh` cleans up `aseprite/`, `aseprite-install/`, `skia/`, and any Flatpak artifacts.
- GitHub does not preserve file permissions — always run `chmod +x *.sh` after cloning.

---

## Why Building Aseprite From Source Is Hard

Aseprite uses Skia as its rendering backend — the same graphics library that powers Google Chrome. Skia is a massive codebase with backends for Apple Metal, Vulkan, Dawn, and more. On Linux, most of those backends either fail to build or pull in dependencies that conflict with what your distro has installed. Finding the right cmake flags to strip out what you don't need and keep what you do took significant time to work out.

The second problem is libjpeg-turbo. Distros ship different versions, and Aseprite is particular about which one it links against. The solution is to build libjpeg-turbo from a known-good source version and install it system-wide before the Aseprite build starts, so cmake always finds the right one regardless of what your distro provides.

The third problem is that every distro is different. The same build that works on Fedora fails on Arch because a package has a different name, or a library lives in a different path, or a version is too new or too old.

The Podman approach solves all three. The build happens inside a clean Ubuntu 24.04 container with a known, stable set of packages. Your host system never gets touched. When the build finishes, the output lands on your system via `move.sh` and the container is discarded.

The result: install `git` and `podman`, run `install.sh`, enter your sudo password once. Everything else is handled.
