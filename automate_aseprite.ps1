# 1. Install Chocolatey (Windows Package Manager) if missing
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# 2. Install Build Tools (CMake, Ninja, Git)
Write-Host "Installing Build Tools..." -ForegroundColor Cyan
choco install git cmake ninja -y

# 3. Install Visual Studio 2022 Build Tools + C++ Workload
# This replaces the manual VS UI installation
Write-Host "Installing Visual Studio Build Tools (this may take a while)..." -ForegroundColor Cyan
choco install visualstudio2022buildtools -y
choco install visualstudio2022-workload-vctools -y

# 4. Clone Aseprite Repository
if (!(Test-Path "aseprite")) {
    Write-Host "Cloning Aseprite..." -ForegroundColor Cyan
    git clone --recursive https://github.com/aseprite/aseprite.git
}
cd aseprite

# 5. Execute your original build logic
Write-Host "Starting Build..." -ForegroundColor Green
if (!(Test-Path "build")) { New-Item -ItemType Directory -Path "build" }
cd build

# Note: Ensure the path to your locally downloaded Skia prebuilt deps is correct here
cmake -G Ninja `
  -DCMAKE_BUILD_TYPE=RelWithDebInfo `
  -DLAF_BACKEND=skia `
  -DSKIA_DIR=$HOME\deps\skia `
  -DSKIA_LIBRARY_DIR=$HOME\deps\skia\out\Release-x64 `
  -DSKIA_LIBRARY=$HOME\deps\skia\out\Release-x64\skia.lib `
  ..

ninja aseprite

# 6. Move to System Files
$installDir = "C:\Program Files\Aseprite"
Write-Host "Deploying to $installDir..." -ForegroundColor Magentia
if (!(Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir -Force }
Copy-Item -Path "bin\*" -Destination $installDir -Recurse -Force

Write-Host "Automation Complete! Aseprite is now in Program Files." -ForegroundColor Green
