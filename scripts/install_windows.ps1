# Install all Locus dependencies on Windows 11.
#
# Requires: an internet connection and an administrator PowerShell.
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts\install_windows.ps1
#
# This script installs (via winget, silently):
#   1. Git for Windows
#   2. Visual Studio 2022 Build Tools with the C++ (MSVC) workload
#   3. uv (Python package manager)
#   4. All Python dependencies from pyproject.toml and the C++ extension

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Step([string]$msg) {
    Write-Host ""
    Write-Host "==> $msg" -ForegroundColor Cyan
}

function Assert-Command([string]$name) {
    Get-Command $name -ErrorAction SilentlyContinue -OutVariable cmd | Out-Null
    return [bool]$cmd
}

$projectDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $projectDir

# ------------------------------------------------------------------ Step 1: winget
Step "Step 1/5: checking winget"
if (-not (Assert-Command "winget")) {
    throw "winget not found. Install the App Installer from the Microsoft Store first."
}

# ------------------------------------------------------------------ Step 2: Git
Step "Step 2/5: installing Git for Windows"
if (Assert-Command "git") {
    Write-Host "git already installed: $(git --version)"
} else {
    winget install --id Git.Git -e --silent `
        --accept-package-agreements --accept-source-agreements
    # Refresh PATH so git is available in this session.
    $env:Path = "$env:ProgramFiles\Git\cmd;$env:Path"
}

# ------------------------------------------------------------------ Step 3: C++ toolchain
Step "Step 3/5: installing Visual Studio 2022 Build Tools (C++ workload)"
$vsInstalled = $false
try {
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vswhere) {
        $vsPath = & $vswhere -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
            -property installationPath
        if ($vsPath) { $vsInstalled = $true }
    }
} catch { }

if ($vsInstalled) {
    Write-Host "C++ build tools already installed."
} else {
    Write-Host "Installing MSVC toolchain. This download is large and takes a while..."
    winget install --id Microsoft.VisualStudio.2022.BuildTools -e --silent `
        --accept-package-agreements --accept-source-agreements `
        --override "--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
}

# --------------------------------------------------------------- Step 4: uv + Python deps
Step "Step 4/5: installing uv"
if (Assert-Command "uv") {
    Write-Host "uv already installed: $(uv --version)"
} else {
    Invoke-RestMethod -Uri https://astral.sh/uv/install.ps1 | Invoke-Expression
    $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
    Get-Command uv -ErrorAction Stop | Out-Null
}

Step "Step 5/5: installing Python dependencies and building the C++ extension"
# The bundled MinGW cmake has no CA bundle, so the Eigen FetchContent download
# from gitlab.com fails TLS verification. CMake suggests CMAKE_TLS_VERIFY=0.
$env:CMAKE_TLS_VERIFY = "0"
uv sync --editable

Write-Host ""
Write-Host "==> Verifying installation..." -ForegroundColor Cyan
uv run python -c "import numpy, sympy, scipy, lark, PySide6, pyqtgraph; print('imports OK')"
uv run pytest -q

Write-Host ""
Write-Host "Done. Run the app with:  uv run python src\main.py" -ForegroundColor Green
