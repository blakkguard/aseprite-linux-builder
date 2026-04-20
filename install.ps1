# install.ps1
# Builds Aseprite on Windows.
# Run this in PowerShell as Administrator.
#
# Usage: .\install.ps1

$ErrorActionPreference = "Stop"

$ASEPRITE_VERSION = "v1.3.17"
$SKIA_RELEASE     = "m124-08a5439a6b"
$SKIA_ZIP         = "Skia-Windows-Release-x64.zip"
$LIBJPEG_VERSION  = "3.1.0"
$BUILD_DIR        = $PSScriptRoot

# ── Winget check ──────────────────────────────────────────────────────────────
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "ERROR: winget is not available. Install App Installer from the Microsoft Store."
    exit 1
}

# ── Visual Studio Build Tools ─────────────────────────────────────────────────
Write-Host "==> Checking for Visual Studio Build Tools..."
$VS_PATH = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" `
    -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    -property installationPath 2>$null

if (-not $VS_PATH) {
    Write-Host "==> Installing Visual Studio Build Tools..."
    winget install --id Microsoft.VisualStudio.2022.BuildTools --silent --override `
        "--wait --quiet --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
} else {
    Write-Host "    Visual Studio Build Tools already installed at: $VS_PATH"
}

# ── CMake ─────────────────────────────────────────────────────────────────────
Write-Host "==> Checking for CMake..."
if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing CMake..."
    winget install --id Kitware.CMake --silent
} else {
    Write-Host "    CMake already installed: $(cmake --version | Select-Object -First 1)"
}

# ── Ninja ─────────────────────────────────────────────────────────────────────
Write-Host "==> Checking for Ninja..."
if (-not (Get-Command ninja -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing Ninja..."
    winget install --id Ninja-build.Ninja --silent
} else {
    Write-Host "    Ninja already installed: $(ninja --version)"
}

# ── Git ───────────────────────────────────────────────────────────────────────
Write-Host "==> Checking for Git..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing Git..."
    winget install --id Git.Git --silent
} else {
    Write-Host "    Git already installed: $(git --version)"
}

# ── Refresh PATH ──────────────────────────────────────────────────────────────
Write-Host "==> Refreshing PATH..."
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH", "User")

# ── Find MSVC Developer Environment ──────────────────────────────────────────
Write-Host "==> Setting up MSVC environment..."
$VS_PATH = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" `
    -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    -property installationPath

$VCVARS = "$VS_PATH\VC\Auxiliary\Build\vcvars64.bat"
if (-not (Test-Path $VCVARS)) {
    Write-Error "ERROR: Could not find vcvars64.bat at $VCVARS"
    exit 1
}

# Import MSVC environment variables into current session
$MSVC_ENV = cmd /c "`"$VCVARS`" && set"
foreach ($line in $MSVC_ENV) {
    if ($line -match "^([^=]+)=(.*)$") {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
    }
}

# ── libjpeg-turbo ─────────────────────────────────────────────────────────────
Write-Host "==> Building libjpeg-turbo $LIBJPEG_VERSION..."
$LIBJPEG_WORK = Join-Path $env:TEMP "libjpeg-turbo-work"
New-Item -ItemType Directory -Force -Path $LIBJPEG_WORK | Out-Null

$LIBJPEG_TAR = Join-Path $LIBJPEG_WORK "libjpeg-turbo-$LIBJPEG_VERSION.tar.gz"
Invoke-WebRequest `
    "https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/$LIBJPEG_VERSION/libjpeg-turbo-$LIBJPEG_VERSION.tar.gz" `
    -OutFile $LIBJPEG_TAR

tar -xzf $LIBJPEG_TAR -C $LIBJPEG_WORK

cmake `
    -S "$LIBJPEG_WORK\libjpeg-turbo-$LIBJPEG_VERSION" `
    -B "$LIBJPEG_WORK\build" `
    -G "Ninja" `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 `
    -DCMAKE_INSTALL_PREFIX="$BUILD_DIR\libjpeg-turbo-install"

cmake --build "$LIBJPEG_WORK\build" --config Release
cmake --install "$LIBJPEG_WORK\build" --prefix "$BUILD_DIR\libjpeg-turbo-install"
Remove-Item -Recurse -Force $LIBJPEG_WORK

# ── icudtl.dat ────────────────────────────────────────────────────────────────
Write-Host "==> Downloading icudtl.dat..."
$ICU_DIR = "$BUILD_DIR\skia\third_party\externals\icu\flutter"
New-Item -ItemType Directory -Force -Path $ICU_DIR | Out-Null
Invoke-WebRequest `
    "https://raw.githubusercontent.com/thlorenz/chromium-deps-icu52/master/android/icudtl.dat" `
    -OutFile "$ICU_DIR\icudtl.dat"

# ── Skia ──────────────────────────────────────────────────────────────────────
Write-Host "==> Downloading pre-built Skia..."
$SKIA_ZIP_PATH = Join-Path $BUILD_DIR $SKIA_ZIP
Invoke-WebRequest `
    "https://github.com/aseprite/skia/releases/download/$SKIA_RELEASE/$SKIA_ZIP" `
    -OutFile $SKIA_ZIP_PATH

Expand-Archive -Path $SKIA_ZIP_PATH -DestinationPath "$BUILD_DIR\skia" -Force
Remove-Item $SKIA_ZIP_PATH

# ── Clone Aseprite ────────────────────────────────────────────────────────────
Write-Host "==> Cloning Aseprite $ASEPRITE_VERSION..."
$CLONE_SUCCESS = $false
for ($attempt = 1; $attempt -le 5; $attempt++) {
    Write-Host "    Clone attempt $attempt of 5..."
    try {
        git clone --recursive --depth 1 -b $ASEPRITE_VERSION https://github.com/aseprite/aseprite.git
        $CLONE_SUCCESS = $true
        break
    } catch {
        Write-Host "    Clone failed, retrying submodules..."
        if (Test-Path "aseprite") {
            Push-Location "aseprite"
            git submodule update --init --recursive
            Pop-Location
            $CLONE_SUCCESS = $true
            break
        }
        Write-Host "    Waiting 15 seconds before retry..."
        Start-Sleep -Seconds 15
    }
}

if (-not $CLONE_SUCCESS) {
    Write-Error "ERROR: Failed to clone Aseprite after 5 attempts."
    exit 1
}

# ── Configure Aseprite ────────────────────────────────────────────────────────
Write-Host "==> Configuring Aseprite..."
cmake `
    -S "$BUILD_DIR\aseprite" `
    -B "$BUILD_DIR\aseprite\build" `
    -G "Ninja" `
    -DCMAKE_BUILD_TYPE=RelWithDebInfo `
    -DCMAKE_INSTALL_PREFIX="$BUILD_DIR\aseprite-install" `
    -DLAF_BACKEND=skia `
    -DSKIA_DIR="$BUILD_DIR\skia" `
    -DSKIA_LIBRARY_DIR="$BUILD_DIR\skia\out\Release-x64" `
    -DSKIA_LIBRARY="$BUILD_DIR\skia\out\Release-x64\skia.lib"

# ── Build Aseprite ────────────────────────────────────────────────────────────
Write-Host "==> Compiling Aseprite (this will take a while)..."
$JOBS = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
cmake --build "$BUILD_DIR\aseprite\build" --config RelWithDebInfo -- -j$JOBS
cmake --install "$BUILD_DIR\aseprite\build" --prefix "$BUILD_DIR\aseprite-install"

Write-Host "==> Done. Aseprite is staged at: $BUILD_DIR\aseprite-install"
