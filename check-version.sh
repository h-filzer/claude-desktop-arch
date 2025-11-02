#!/bin/bash
# Claude Desktop Version Checker
# Checks for new Claude Desktop releases

set -e

CURRENT_VERSION="0.13.19"
DOWNLOAD_URL="https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe"

echo "🔍 Checking Claude Desktop version..."
echo "Current packaged version: ${CURRENT_VERSION}"

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf ${TEMP_DIR}" EXIT

cd "${TEMP_DIR}"

echo "📥 Downloading installer to check version..."
wget -q -O "Claude-Setup-x64.exe" "${DOWNLOAD_URL}" || {
    echo "❌ Failed to download installer"
    exit 1
}

echo "📦 Extracting to find version..."
7z x -y "Claude-Setup-x64.exe" >/dev/null 2>&1 || {
    echo "❌ Failed to extract installer"
    exit 1
}

# Find nupkg file and extract version
NUPKG_PATH=$(find . -name "AnthropicClaude-*.nupkg" | head -1)

if [ -z "${NUPKG_PATH}" ]; then
    echo "❌ Could not find AnthropicClaude nupkg file"
    exit 1
fi

LATEST_VERSION=$(echo "${NUPKG_PATH}" | grep -oP 'AnthropicClaude-\K[0-9]+\.[0-9]+\.[0-9]+(?=-full)')

if [ -z "${LATEST_VERSION}" ]; then
    echo "❌ Could not extract version from filename"
    exit 1
fi

echo "Latest available version: ${LATEST_VERSION}"

# Compare versions
if [ "${CURRENT_VERSION}" = "${LATEST_VERSION}" ]; then
    echo "✅ Package is up to date!"
    exit 0
else
    echo "⚠️  New version available: ${LATEST_VERSION}"
    echo ""
    echo "To update:"
    echo "1. Edit PKGBUILD and change pkgver to ${LATEST_VERSION}"
    echo "2. Run: makepkg --printsrcinfo > .SRCINFO"
    echo "3. Test: ./setup-chroot.sh all"
    echo "4. Commit and push changes"
    exit 1
fi
