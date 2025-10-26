#!/bin/bash
# Docker-based Build Script
# Build claude-desktop package using Docker (works on any OS!)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="claude-desktop-builder"
CONTAINER_NAME="claude-desktop-build"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running"
    echo "Please start Docker and try again"
    exit 1
fi

print_status "Building Docker image: ${IMAGE_NAME}..."
docker build -t "${IMAGE_NAME}:latest" "${SCRIPT_DIR}"

print_status "Creating build container..."
docker run --rm \
    --name "${CONTAINER_NAME}" \
    -v "${SCRIPT_DIR}:/build" \
    -w /build \
    "${IMAGE_NAME}:latest" \
    bash -c "makepkg -s --noconfirm"

if [ $? -eq 0 ]; then
    print_status "✓ Package built successfully!"
    print_status "Package files:"
    ls -lh "${SCRIPT_DIR}"/claude-desktop-*.pkg.tar.zst 2>/dev/null || true
else
    print_error "Package build failed"
    exit 1
fi

print_status "Done! 🎉"
