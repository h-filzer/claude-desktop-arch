# Maintainer: Claude Desktop Linux Maintainers

pkgname=claude-desktop-arch
pkgver=0.13.37 # Will be replaced with actual claude desktop version during build
pkgrel=1
pkgdesc="Claude Desktop for Linux"
arch=('x86_64')
url="https://www.anthropic.com/claude"
license=('custom')
depends=('nodejs' 'npm')
makedepends=('wget' 'icoutils' 'imagemagick' '7zip')
provides=("${pkgname}")
conflicts=("${pkgname}")
epoch=1


# Update this URL when a new version of Claude Desktop is released
_download_url="https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe"

pkgver() {
    cd "${srcdir}"
    
    # Download Claude Windows installer if not already present
    if [ ! -f "Claude-Setup-x64.exe" ]; then
        wget -q -O "Claude-Setup-x64.exe" "${_download_url}"
    fi
    
    # Extract to find nupkg file
    if [ ! -f "AnthropicClaude-*.nupkg" ]; then
        7z x -y "Claude-Setup-x64.exe" >/dev/null 2>&1
    fi
    
    # Extract version from the nupkg filename
    _nupkg_path=$(find . -name "AnthropicClaude-*.nupkg" | head -1)
    if [ -z "${_nupkg_path}" ]; then
        return 1
    fi
    
    _version=$(echo "${_nupkg_path}" | grep -oP 'AnthropicClaude-\K[0-9]+\.[0-9]+\.[0-9]+(?=-full)')
    if [ -z "${_version}" ]; then
        return 1
    fi
    
    echo "${_version}"
}

prepare() {
    cd "${srcdir}"

    # Download Claude Windows installer
    echo "📥 Downloading Claude Desktop installer..."
    wget -O "Claude-Setup-x64.exe" "${_download_url}"
    echo "✓ Download complete"

    # Extract resources
    echo "📦 Extracting resources..."
    7z x -y "Claude-Setup-x64.exe"

    # Find nupkg file for processing
    _nupkg_path=$(find . -name "AnthropicClaude-*.nupkg" | head -1)
    if [ -z "${_nupkg_path}" ]; then
        echo "❌ Could not find AnthropicClaude nupkg file"
        exit 1
    fi

    # Extract nupkg
    7z x -y "${_nupkg_path}"
    echo "✓ Resources extracted"

    # Extract and convert icons
    echo "🎨 Processing icons..."
    wrestool -x -t 14 "lib/net45/claude.exe" -o claude.ico
    icotool -x claude.ico
    echo "✓ Icons processed"

    # Process app.asar
    mkdir -p electron-app
    cp "lib/net45/resources/app.asar" electron-app/
    cp -r "lib/net45/resources/app.asar.unpacked" electron-app/

    cd "${srcdir}/electron-app"

    # Use npx to run @electron/asar (downloads temporarily if needed)
    npx --yes @electron/asar extract app.asar app.asar.contents

    # Replace native module with stub implementation
    echo "Creating stub native module..."
    cat >app.asar.contents/node_modules/claude-native/index.js <<EOF
// Stub implementation of claude-native using KeyboardKey enum values
const KeyboardKey = {
  Backspace: 43,
  Tab: 280,
  Enter: 261,
  Shift: 272,
  Control: 61,
  Alt: 40,
  CapsLock: 56,
  Escape: 85,
  Space: 276,
  PageUp: 251,
  PageDown: 250,
  End: 83,
  Home: 154,
  LeftArrow: 175,
  UpArrow: 282,
  RightArrow: 262,
  DownArrow: 81,
  Delete: 79,
  Meta: 187
};

Object.freeze(KeyboardKey);

module.exports = {
  getWindowsVersion: () => "10.0.0",
  setWindowEffect: () => {},
  removeWindowEffect: () => {},
  getIsMaximized: () => false,
  flashFrame: () => {},
  clearFlashFrame: () => {},
  showNotification: () => {},
  setProgressBar: () => {},
  clearProgressBar: () => {},
  setOverlayIcon: () => {},
  clearOverlayIcon: () => {},
  KeyboardKey
};
EOF

    # Copy Tray icons
    mkdir -p app.asar.contents/resources
    mkdir -p app.asar.contents/resources/i18n

    cp ../lib/net45/resources/Tray* app.asar.contents/resources/
    cp ../lib/net45/resources/*-*.json app.asar.contents/resources/i18n/

    # Repackage app.asar (using @electron/asar instead of deprecated asar)
    npx @electron/asar pack app.asar.contents app.asar
}

package() {
    cd "${srcdir}"

    # Create directories
    install -dm755 "${pkgdir}/usr/lib/${pkgname}"
    install -dm755 "${pkgdir}/usr/share/applications"
    install -dm755 "${pkgdir}/usr/share/icons/hicolor"
    install -dm755 "${pkgdir}/usr/bin"

    # Install app.asar
    install -Dm644 "electron-app/app.asar" "${pkgdir}/usr/lib/${pkgname}/"

    # Create native module with keyboard constants
    install -dm755 "${pkgdir}/usr/lib/${pkgname}/app.asar.unpacked/node_modules/claude-native"
    cat >"${pkgdir}/usr/lib/${pkgname}/app.asar.unpacked/node_modules/claude-native/index.js" <<EOF
// Stub implementation of claude-native using KeyboardKey enum values
const KeyboardKey = {
  Backspace: 43,
  Tab: 280,
  Enter: 261,
  Shift: 272,
  Control: 61,
  Alt: 40,
  CapsLock: 56,
  Escape: 85,
  Space: 276,
  PageUp: 251,
  PageDown: 250,
  End: 83,
  Home: 154,
  LeftArrow: 175,
  UpArrow: 282,
  RightArrow: 262,
  DownArrow: 81,
  Delete: 79,
  Meta: 187
};

Object.freeze(KeyboardKey);

module.exports = {
  getWindowsVersion: () => "10.0.0",
  setWindowEffect: () => {},
  removeWindowEffect: () => {},
  getIsMaximized: () => false,
  flashFrame: () => {},
  clearFlashFrame: () => {},
  showNotification: () => {},
  setProgressBar: () => {},
  clearProgressBar: () => {},
  setOverlayIcon: () => {},
  clearOverlayIcon: () => {},
  KeyboardKey
};
EOF

    # Copy app.asar.unpacked directory
    if [ -d "electron-app/app.asar.unpacked" ]; then
        cp -r "electron-app/app.asar.unpacked" "${pkgdir}/usr/lib/${pkgname}/"
    fi

    # Install icons
    declare -A icon_files=(
        ["16"]="claude_13_16x16x32.png"
        ["24"]="claude_11_24x24x32.png"
        ["32"]="claude_10_32x32x32.png"
        ["48"]="claude_8_48x48x32.png"
        ["64"]="claude_7_64x64x32.png"
        ["256"]="claude_6_256x256x32.png"
    )

    for size in 16 24 32 48 64 256; do
        icon_dir="${pkgdir}/usr/share/icons/hicolor/${size}x${size}/apps"
        install -dm755 "${icon_dir}"
        if [ -f "${icon_files[$size]}" ]; then
            echo "Installing ${size}x${size} icon..."
            install -Dm644 "${icon_files[$size]}" "${icon_dir}/claude-desktop.png"
        else
            echo "Warning: Missing ${size}x${size} icon"
        fi
    done

    # Create desktop entry
    cat >"${pkgdir}/usr/share/applications/claude-desktop.desktop" <<EOF
[Desktop Entry]
Name=Claude
Exec=claude-desktop %u
Icon=claude-desktop
Type=Application
Terminal=false
Categories=Office;Utility;
MimeType=x-scheme-handler/claude;
StartupWMClass=Claude
EOF
    # Create launcher script
    cat >"${pkgdir}/usr/bin/claude-desktop" <<'EOF'
#!/bin/bash
# Claude Desktop Launcher with on-demand electron installation

ELECTRON_ALIAS="electron-claude-desktop"

ensure_electron() {
    # Check if our aliased electron is already available
    if command -v "$ELECTRON_ALIAS" &> /dev/null; then
        return 0
    fi
    
    # Check if regular electron is available and use it
    if command -v electron &> /dev/null; then
        echo "Using existing electron installation..."
        ELECTRON_ALIAS="electron"
        return 0
    fi
    
    echo "Setting up electron for Claude Desktop (one-time setup)..."
    
    # Check npm availability
    if ! command -v npm &> /dev/null; then
        echo "Error: npm not found. Please install Node.js and npm." >&2
        exit 1
    fi
    
    # Install with lock file to prevent concurrent installs
    local lock_file="/tmp/claude-desktop-electron-install.lock"
    
    # Clean up function for proper lock file removal
    cleanup_lock() {
        rm -f "$lock_file"
    }
    
    # Check for stale lock files (older than 10 minutes)
    if [ -f "$lock_file" ]; then
        local lock_age=$(($(date +%s) - $(stat -c %Y "$lock_file" 2>/dev/null || echo 0)))
        if [ $lock_age -gt 600 ]; then
            echo "Removing stale lock file (${lock_age}s old)..."
            rm -f "$lock_file"
        else
            echo "Another electron installation in progress. Please wait..."
            local wait_count=0
            while [ -f "$lock_file" ] && [ $wait_count -lt 300 ]; do 
                sleep 1
                wait_count=$((wait_count + 1))
            done
            if [ -f "$lock_file" ]; then
                echo "Installation timeout. Removing stale lock..."
                rm -f "$lock_file"
            else
                return 0
            fi
        fi
    fi
    
    touch "$lock_file"
    trap cleanup_lock EXIT INT TERM
    
    # Try to install with alias first, fallback to regular electron
    if ! npm install -g "$ELECTRON_ALIAS@npm:electron" --no-fund --no-audit 2>/dev/null; then
        echo "Alias installation failed, installing regular electron..."
        npm install -g electron --no-fund --no-audit || {
            echo "Error: Failed to install electron. Please check your npm configuration." >&2
            exit 1
        }
        ELECTRON_ALIAS="electron"
    fi
    
    echo "Electron setup complete."
}

ensure_electron

# Find the electron binary path
ELECTRON_PATH=""
if command -v "$ELECTRON_ALIAS" &> /dev/null; then
    # Get the actual executable path
    ELECTRON_PATH=$(command -v "$ELECTRON_ALIAS")
else
    # Try common npm global locations
    NPM_PREFIX=$(npm config get prefix 2>/dev/null || echo "/usr")
    if [ "$ELECTRON_ALIAS" = "electron" ]; then
        ELECTRON_PATH="$NPM_PREFIX/lib/node_modules/electron/dist/electron"
    else
        ELECTRON_PATH="$NPM_PREFIX/lib/node_modules/$ELECTRON_ALIAS/dist/electron"
    fi
fi

if [ ! -x "$ELECTRON_PATH" ]; then
    echo "Error: Electron binary not found at $ELECTRON_PATH" >&2
    exit 1
fi

# Clean up lock file before launching
rm -f /tmp/claude-desktop-electron-install.lock

exec "$ELECTRON_PATH" /usr/lib/claude-desktop-arch/app.asar "$@"
EOF
    chmod +x "${pkgdir}/usr/bin/claude-desktop"
}

post_install() {
    sudo update-desktop-database /usr/share/applications
}
