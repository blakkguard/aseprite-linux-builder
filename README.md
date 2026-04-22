# Aseprite Linux Builder

Aseprite is a professional pixel art and animation tool. It costs $19.99 and is worth every penny — please consider buying it officially:

- [Aseprite on Steam](https://store.steampowered.com/app/431730/Aseprite/) — $19.99
- [Aseprite on itch.io](https://dacap.itch.io/aseprite)

These scripts let you build Aseprite from source on Linux and Windows for personal use, which is permitted under the Aseprite license. If you find it useful, buy it and support the developers who made it.

On Linux, Aseprite is built inside a clean Ubuntu 24.04 Podman container, then moved to your system. On Windows, it builds natively using VS Build Tools. Either way, your system is only written to at the final install step.

---

## Linux

### Quick Start

You need `curl` and `unzip`. That's it.

```bash
curl -fsSL https://github.com/blakkguard/aseprite-linux-builder/archive/refs/heads/main.zip -o builder.zip
unzip builder.zip
cd aseprite-linux-builder-main
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

Aseprite stages at `./aseprite-install`. You can run it directly from there:

```bash
./aseprite-install/bin/aseprite
```

When you're ready to install system-wide:

```bash
sudo ./move.sh
```

### Linux Scripts

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

## Windows

### Requirements

- Windows 11
- PowerShell (built in)
- An elevated (Administrator) terminal

### Quick Start

Download the zip from GitHub, extract it, then run from an elevated PowerShell prompt:

```powershell
Expand-Archive builder.zip
cd aseprite-linux-builder-main
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```

`install.ps1` installs VS Build Tools 2022, CMake, Ninja, and Git via winget, builds Aseprite natively, and installs it to `C:\Program Files\Aseprite`. When it finishes, launch Aseprite from the Start Menu.

### How It Works

```
install.ps1       → installs deps via winget, builds, and installs in sequence
  winget_deps.ps1 → VS Build Tools 2022 (C++ workload), CMake, Ninja, Git
  build.ps1       → downloads Skia, clones and compiles Aseprite
  move.ps1        → copies to C:\Program Files\Aseprite, PATH, Start Menu, cleans up
```

### Build Without Installing

```powershell
.\winget_deps.ps1
.\build.ps1
```

Aseprite stages at `.\aseprite-install`. Run `move.ps1` when ready to install.

### Windows Scripts

| Script | What it does |
|---|---|
| `install.ps1` | Installs deps, builds, and installs — all in sequence |
| `winget_deps.ps1` | Installs VS Build Tools 2022, CMake, Ninja, Git via winget |
| `build.ps1` | Downloads Skia, clones and compiles Aseprite |
| `move.ps1` | Copies to `C:\Program Files\Aseprite`, adds to PATH, Start Menu shortcut, cleans up |

### File Locations After Install (Windows)

| File | Location |
|---|---|
| Aseprite binary | `C:\Program Files\Aseprite\bin\aseprite.exe` |
| Shared data | `C:\Program Files\Aseprite\share\aseprite\` |
| Start Menu | `%ProgramData%\Microsoft\Windows\Start Menu\Programs\Aseprite.lnk` |

---

## Versions

Edit the version variables at the top of `build.sh` / `build.ps1` to change what gets built.

| Component | Version |
|---|---|
| Aseprite | v1.3.17 |
| Skia | m124-08a5439a6b |
| libjpeg-turbo | 3.1.0 (Linux only) |

---

## Notes

- The build takes 15–30 minutes depending on your hardware. Let it run.
- A stable internet connection is required — Skia and Aseprite source are downloaded during the build. The scripts include retry logic for flaky connections.
- `move.sh` / `move.ps1` clean up all build artifacts after installing.
- No `git` required — use `curl` on Linux or the GitHub zip download on Windows.

---

## Why Building Aseprite From Source Is Hard

Aseprite uses Skia as its rendering backend — the same graphics library that powers Google Chrome. Skia is a massive codebase and on Linux most backends either fail to build or conflict with what your distro ships. Finding the right CMake flags took significant time to work out.

The second problem is libjpeg-turbo. Distros ship different versions, and Aseprite is particular about which one it links against. The solution is to build a known-good version inside the container before the Aseprite build starts.

The third problem is that every distro is different. The same build that works on Fedora fails on Arch because a package has a different name, or a library lives in a different path.

The Podman container solves all three on Linux — the build always happens inside a clean Ubuntu 24.04 environment regardless of what you're running on the host. On Windows, VS Build Tools 2022 provides the same known environment natively, so a container isn't needed.
