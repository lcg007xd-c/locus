#!/usr/bin/env bash
#
# Install all Locus dependencies on Linux.
# Supports Debian/Ubuntu (apt), Fedora (dnf), Arch (pacman), openSUSE (zypper).
#
# Usage:  bash scripts/install_linux.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

info()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
fail()  { printf '\n\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# ---------------------------------------------------------------- system deps
# Base: git, C++20 compiler, make, CMake, Ninja, Python headers.
# Runtime: libraries required by the PySide6 (Qt 6) wheels.
install_debian() {
    sudo apt-get update
    sudo apt-get install -y \
        git build-essential cmake ninja-build python3-dev \
        libgl1 libegl1 libxkbcommon0 libxkbcommon-x11-0 libxcb-cursor0 \
        libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
        libxcb-render-util0 libxcb-shape0 libxcb-xinerama0 libxcb-xkb1 \
        libxcb-xv0 libxcomposite1 libxcursor1 libxdamage1 libxi6 libxrandr2 \
        libfontconfig1 libdbus-1-3 libdouble-conversion3 libpcre2-16-0 \
        libwayland-client0 libwayland-cursor0 libwayland-egl1
}

install_fedora() {
    sudo dnf install -y \
        git gcc-c++ make cmake ninja-build python3-devel \
        mesa-libGL mesa-libEGL libglvnd libxkbcommon libxkbcommon-x11 \
        xcb-util-wm xcb-util-image xcb-util-keysyms xcb-util-renderutil \
        xcb-util-cursor xcb-util libxcb libXcomposite libXcursor libXdamage \
        libXi libXrandr fontconfig dbus-libs double-conversion pcre2 \
        libwayland-client libwayland-cursor libwayland-egl
}

install_arch() {
    sudo pacman -S --needed --noconfirm \
        git base-devel cmake ninja python \
        libgl libegl libxkbcommon libxkbcommon-x11 xcb-util-cursor \
        xcb-util-wm xcb-util-image xcb-util-keysyms xcb-util-renderutil \
        libxcomposite libxcursor libxdamage libxi libxrandr fontconfig \
        dbus double-conversion pcre2 wayland
}

install_opensuse() {
    sudo zypper install -y \
        git gcc-c++ make cmake ninja python3-devel \
        mesa-libGL1 mesa-libEGL1 libglvnd libxkbcommon0 libxkbcommon-x11-0 \
        xcb-util-cursor xcb-util-wm xcb-util-image xcb-util-keysyms \
        xcb-util-renderutil libxcb1 libXcomposite1 libXcursor1 libXdamage1 \
        libXi6 libXrandr2 fontconfig libdbus-1-3 libdouble-conversion1 \
        libpcre2-16-0 libwayland-client0 libwayland-cursor0 libwayland-egl1
}

install_system_deps() {
    if command_exists apt-get; then
        install_debian
    elif command_exists dnf; then
        install_fedora
    elif command_exists pacman; then
        install_arch
    elif command_exists zypper; then
        install_opensuse
    else
        fail "Unsupported package manager. Install git, a C++20 compiler, \
CMake, Ninja, python dev headers and the Qt 6 runtime libraries manually."
    fi
}

# ------------------------------------------------------------------ uv install
install_uv() {
    if command_exists uv; then
        info "uv already installed: $(uv --version)"
        return
    fi
    info "Installing uv (official installer)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    command_exists uv || fail "uv installation failed. Add ~/.local/bin to PATH and rerun."
}

# ------------------------------------------------------------------------ main
main() {
    info "Step 1/3: installing system packages (compiler, CMake, Ninja, Qt runtime libs)..."
    install_system_deps

    info "Step 2/3: installing uv..."
    install_uv

    info "Step 3/3: installing Python dependencies and building the C++ extension..."
    uv sync --editable

    info "Verifying installation..."
    uv run python -c "import numpy, sympy, scipy, lark, PySide6, pyqtgraph; print('imports OK')"
    uv run pytest -q

    info "Done. Run the app with:  uv run python src/main.py"
}

main "$@"
