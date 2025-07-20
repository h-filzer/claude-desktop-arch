# Claude Desktop for Arch Linux

This repository contains a PKGBUILD file to build and install Claude Desktop on Arch Linux and Arch-based distributions (like Manjaro, EndeavourOS, etc.).
Credits go to [claude-desktop-debian](https://github.com/aaddrick/claude-desktop-debian) which is the base for this repository.

## Building and Installing

### Option 1: Using the Installation Script

The easiest way to install is to use the provided installation script:

```bash
git clone https://github.com/h-filzer/claude-desktop-arch.git
cd claude-desktop-arch
./install.sh
```

This script will:
1. Check if you're running an Arch-based system
2. Install all required dependencies (will prompt for sudo password)
3. Build the package as a regular user (not as root)
4. Install the built package (will use sudo)

**Important**: Do not run the script with sudo, as `makepkg` should not be run as root. The script will use sudo only when necessary for installing dependencies and the final package.

### Option 2: Manual Build

If you prefer to build the package manually:

1. Clone this repository:

```bash
git clone https://github.com/h-filzer/claude-desktop-arch.git
cd claude-desktop-arch
```

2. Build and install the package:

```bash
makepkg -si
```

The `-si` flag will install any required dependencies and the package after building. There's no need to manually install dependencies beforehand.

**Important**: Do not run `makepkg` with sudo, as it should not be run as root. The `-si` flag will automatically use sudo when needed to install dependencies and the package.

## Manual Installation

If you prefer to install the package manually after building:

```bash
sudo pacman -U claude-desktop-*.pkg.tar.zst
```

## Running Claude Desktop

After installation, you can run Claude Desktop from your application menu or by typing:

```bash
claude-desktop
```

### Permission Issues

If you encounter permission issues, make sure the launcher script is executable:

```bash
sudo chmod +x /usr/sbin/claude-desktop
```

When the login does not work you can try to run the following command to update the registered `claude://` URL-sheme:

```bash
sudo update-desktop-database /usr/share/applications

```
When experiencing errors, have all claude pids killed by: `ps awx | grep claude | grep -v grep | awk '{print $1}' | xargs kill -9`

## Updating

When a new version of Claude Desktop is released, update the `_download_url` variable in the PKGBUILD file and rebuild the package.

## Development and Testing

This section describes how to set up a development environment and test the package build before distribution.

### Using the Chroot Testing Environment

The `setup-chroot.sh` script provides an isolated testing environment that prevents potential issues with your main system. This is the recommended approach for testing package builds.

**Important Notes**:
- The script automatically checks for and installs required dependencies (like `arch-install-scripts`) when you run it
- Do not run the script as root - it will refuse to run and display an error
- The chroot is created in a `chroot-test` directory relative to the script location
- The `test` command runs with `--noconfirm` flag for automated builds

#### Available Commands

The script provides several commands to manage the chroot environment:

- `setup` - Create the chroot environment (includes disabling pacman CheckSpace)
- `copy` - Copy PKGBUILD to the chroot
- `enter` - Enter the chroot environment for manual testing
- `test` - Run automated package build test
- `cleanup` - Remove the chroot environment
- `all` - Run complete setup and test workflow

**Note**: The `setup` command automatically disables pacman CheckSpace to prevent mount point errors when installing packages in the chroot.

#### Quick Start

For a complete automated test:

```bash
./setup-chroot.sh all
```

This will:
1. Check and install dependencies
2. Create a clean chroot environment with CheckSpace disabled
3. Copy the PKGBUILD and create builder user
4. Build and test the package automatically
5. Display built package files on success

#### Step-by-Step Manual Testing

If you prefer more control over the testing process:

```bash
# 1. Create the chroot environment
./setup-chroot.sh setup

# 2. Copy PKGBUILD to chroot
./setup-chroot.sh copy

# 3. Enter the chroot for manual testing
./setup-chroot.sh enter

# Inside the chroot:
su - builder
cd /home/builder
makepkg -s

# Exit the chroot
exit

# 4. Clean up when done
./setup-chroot.sh cleanup
```

#### Understanding the Chroot Environment

The chroot environment provides:
- A minimal Arch Linux installation
- Isolated filesystem to prevent system contamination
- A dedicated `builder` user for safe package building (with passwordless sudo)
- Automatic dependency resolution via `makepkg -s`
- Disabled pacman CheckSpace for smooth package operations

### Manual Testing Without Chroot

If you prefer to test directly on your system (not recommended for untested PKGBUILDs):

```bash
# Build the package without installing
makepkg

# Or build and install in one step
makepkg -C -f -si
```

### Development Workflow

When modifying the PKGBUILD:

1. **Make your changes** to the PKGBUILD file
2. **Test in chroot** using `./setup-chroot.sh all`
3. **Verify the package** builds successfully
4. **Check the built package** in `chroot-test/home/builder/`
5. **Test installation** (optional) within the chroot
6. **Clean up** with `./setup-chroot.sh cleanup`

### Troubleshooting

#### Common Issues

1. **"makepkg should not be run as root"**
   - Never run the setup script or makepkg with sudo
   - The script will request sudo only when needed

2. **"Chroot directory already exists"**
   - Run `./setup-chroot.sh cleanup` first
   - Or answer 'y' when prompted to remove it

3. **Mount point errors in chroot**
   - CheckSpace is automatically disabled during `setup`
   - This should not occur with the current version

4. **Build failures**
   - Check the PKGBUILD for syntax errors
   - Ensure all dependencies are listed correctly
   - Review the build output for specific errors

5. **Electron version issues/missing en-US.json version Workaround**
   - The client seems to want to use an existing electron installation which seems to be incompatible
   - uninstall electron via pacman
   - relaunch with sudo, this will install the correct version then fail
   - launch normally

### Tips for Developers

- Always test in a chroot environment before pushing changes
- The chroot environment mimics a clean Arch installation
- Built packages appear in `chroot-test/home/builder/`
- You can copy built packages out of the chroot for distribution
- Use `makepkg -g` to generate new checksums when updating sources

## How It Works

This package:

1. Downloads the Windows installer for Claude Desktop
2. Extracts the necessary files and resources
3. Creates a stub implementation for Windows-specific native modules
4. Packages everything into an Arch Linux package
5. Sets up desktop integration (icons, launcher, etc.)

## License

This PKGBUILD is provided under the same license as the original claude-desktop-debian application:

The build scripts in this repository, are dual-licensed under the terms of the MIT license and the Apache License (Version 2.0).

See [LICENSE-MIT](LICENSE-MIT) and [LICENSE-APACHE](LICENSE-APACHE) for details.

The Claude Desktop application, not included in this repository, is likely covered by [Anthropic's Consumer Terms](https://www.anthropic.com/legal/consumer-terms).

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any
additional terms or conditions.
