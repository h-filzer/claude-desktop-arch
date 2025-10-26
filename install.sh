#!/bin/bash
set -e

echo "Claude Desktop for Arch Linux - Installation Script"
echo "=================================================="

# Check for Arch-based system
if [ ! -f "/etc/arch-release" ] && ! command -v pacman &>/dev/null; then
    echo "❌ This script requires an Arch-based Linux distribution"
    exit 1
fi

echo "Building package..."
# Build the package
makepkg -s

if [ $? -eq 0 ]; then
    echo "Package built successfully. Installing with sudo..."
    # Install the built package with sudo
    sudo pacman -U --noconfirm claude-desktop-arch-*.pkg.tar.zst

    if [ $? -eq 0 ]; then
        echo "✓ Claude Desktop has been successfully installed!"
        echo "You can now run it by typing 'claude-desktop' or from your application menu."
    else
        echo "❌ Installation failed. Please check the error messages above."
        exit 1
    fi
else
    echo "❌ Package build failed. Please check the error messages above."
    exit 1
fi
