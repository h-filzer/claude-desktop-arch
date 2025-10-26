#!/bin/bash

# AUR Package Testing Chroot Environment Setup Script
# Simple chroot environment for testing claude-desktop package
# Dependencies are handled automatically by makepkg from PKGBUILD

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHROOT_DIR="${SCRIPT_DIR}/chroot-test"
PACKAGE_NAME="claude-desktop-arch"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "This script should not be run as root. makepkg should not be run as root."
        exit 1
    fi
}

# Check and install dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    local missing_deps=()
    
    # Check for arch-install-scripts
    if ! command -v pacstrap &> /dev/null; then
        missing_deps+=("arch-install-scripts")
    fi
    
    # Check for arch-chroot
    if ! command -v arch-chroot &> /dev/null; then
        missing_deps+=("arch-install-scripts")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"
        echo "Please install with: sudo pacman -S ${missing_deps[*]}"
        echo "Would you like me to install them now? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            sudo pacman -S --needed "${missing_deps[@]}"
        else
            print_error "Cannot proceed without required dependencies."
            exit 1
        fi
    fi
    
    print_status "All dependencies satisfied."
}

# Create chroot environment
create_chroot() {
    print_status "Creating chroot environment at $CHROOT_DIR"
    
    if [ -d "$CHROOT_DIR" ]; then
        print_warning "Chroot directory already exists. Remove it first? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            sudo rm -rf "$CHROOT_DIR"
        else
            print_error "Cannot proceed with existing chroot directory."
            exit 1
        fi
    fi
    
    print_status "Creating chroot directory..."
    sudo mkdir -p "$CHROOT_DIR"
    
    print_status "Bootstrapping base system..."
    sudo pacstrap -c "$CHROOT_DIR" base base-devel
    
    print_status "Setting up pacman keyring..."
    sudo arch-chroot "$CHROOT_DIR" pacman-key --init
    sudo arch-chroot "$CHROOT_DIR" pacman-key --populate archlinux
    
    # Disable CheckSpace to prevent mount point errors in chroot
    print_status "Disabling pacman CheckSpace for chroot compatibility..."
    sudo sed -i 's/^CheckSpace/#CheckSpace/' "$CHROOT_DIR/etc/pacman.conf"
    
    print_status "Chroot environment created successfully!"
}

# Copy PKGBUILD to chroot
copy_package() {
    print_status "Copying package files to chroot..."
    
    sudo mkdir -p "$CHROOT_DIR/home/builder"
    sudo cp "$SCRIPT_DIR/PKGBUILD" "$CHROOT_DIR/home/builder/"
    
    # Create a non-root user for building
    sudo arch-chroot "$CHROOT_DIR" useradd -m -G wheel builder 2>/dev/null || true
    sudo arch-chroot "$CHROOT_DIR" chown -R builder:builder /home/builder
    
    # Allow builder to use sudo without password for package installation
    echo "builder ALL=(ALL) NOPASSWD: ALL" | sudo tee "$CHROOT_DIR/etc/sudoers.d/builder" > /dev/null
    
    print_status "Package files copied and builder user created."
}

# Enter chroot environment
enter_chroot() {
    print_status "Entering chroot environment..."
    print_status "Switch to builder user with: su - builder"
    print_status "You can now test your package build with: makepkg -s"
    print_status "Type 'exit' to leave the chroot environment."
    
    sudo arch-chroot "$CHROOT_DIR" /bin/bash
}

# Test package build
test_package() {
    print_status "Testing package build..."
    
    # Switch to builder user and build
    sudo arch-chroot "$CHROOT_DIR" /bin/bash -c "
        cd /home/builder
        sudo -u builder makepkg -s --noconfirm
    "
    
    if [ $? -eq 0 ]; then
        print_status "Package built successfully!"
        print_status "Package files:"
        sudo ls -la "$CHROOT_DIR/home/builder/"*.pkg.tar.zst 2>/dev/null || true
    else
        print_error "Package build failed."
        return 1
    fi
}

# Install package in chroot
install_package() {
    print_status "Installing package in chroot..."
    
    # Install the built package
    sudo arch-chroot "$CHROOT_DIR" /bin/bash -c "
        cd /home/builder
        pacman -U claude-desktop-arch-*.pkg.tar.zst --noconfirm
    "
    
    if [ $? -eq 0 ]; then
        print_status "Package installed successfully!"
        print_status "Verifying installation:"
        sudo arch-chroot "$CHROOT_DIR" pacman -Qi claude-desktop-arch | grep "Version"
    else
        print_error "Package installation failed."
        return 1
    fi
}

# Clean up chroot
cleanup() {
    print_status "Cleaning up chroot environment..."
    
    if [ -d "$CHROOT_DIR" ]; then
        sudo rm -rf "$CHROOT_DIR"
        print_status "Chroot environment removed."
    else
        print_warning "Chroot directory not found."
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  setup     - Create chroot environment"
    echo "  copy      - Copy PKGBUILD to chroot"
    echo "  enter     - Enter chroot environment for manual testing"
    echo "  test      - Run automated package build test"
    echo "  install   - Install built package in chroot"
    echo "  cleanup   - Remove chroot environment"
    echo "  all       - Run complete setup, build, install and test workflow"
    echo
    echo "Example workflow:"
    echo "  $0 setup"
    echo "  $0 copy"
    echo "  $0 test"
    echo "  $0 cleanup"
}

# Main function
main() {
    check_not_root
    
    case "${1:-}" in
        "setup")
            check_dependencies
            create_chroot
            ;;
        "copy")
            copy_package
            ;;
        "enter")
            enter_chroot
            ;;
        "test")
            test_package
            ;;
        "install")
            install_package
            ;;
        "cleanup")
            cleanup
            ;;
        "all")
            check_dependencies
            create_chroot
            copy_package
            test_package
            install_package
            print_status "Complete! Package built and installed. Run '$0 cleanup' to remove the chroot environment."
            ;;
        *)
            show_usage
            ;;
    esac
}

main "$@"