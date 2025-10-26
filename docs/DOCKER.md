# Docker Build Guide

This guide explains how to build the claude-desktop package using Docker, which works on any OS (Linux, macOS, Windows).

## Why Use Docker?

✅ **No Arch Linux required** — Build on any OS  
✅ **Clean environment** — Isolated from your system  
✅ **Reproducible** — Same build every time  
✅ **Easy setup** — Just install Docker

---

## Quick Start

### Prerequisites

Install Docker:
- **Linux**: `sudo pacman -S docker` or see [docs](https://docs.docker.com/engine/install/)
- **macOS**: [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
- **Windows**: [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)

### Build the Package

```bash
# Clone the repository
git clone https://github.com/h-filzer/claude-desktop-arch.git
cd claude-desktop-arch

# Build using Docker script
./docker-build.sh
```

That's it! The `.pkg.tar.zst` file will be in the current directory.

---

## Alternative Methods

### Using Docker Compose

```bash
# Build with docker-compose
docker-compose up builder

# Build and test
docker-compose up tester
```

### Manual Docker Commands

```bash
# Build the image
docker build -t claude-desktop-builder .

# Run the build
docker run --rm \
    -v $(pwd):/build \
    -w /build \
    claude-desktop-builder:latest \
    makepkg -s --noconfirm

# Built package will be in current directory
ls -lh claude-desktop-*.pkg.tar.zst
```

---

## Advanced Usage

### Interactive Build Shell

```bash
# Enter container for debugging
docker run --rm -it \
    -v $(pwd):/build \
    -w /build \
    claude-desktop-builder:latest \
    /bin/bash

# Inside container:
makepkg -s --noconfirm
```

### Custom Build Options

```bash
# Build with custom flags
docker run --rm \
    -v $(pwd):/build \
    -w /build \
    claude-desktop-builder:latest \
    bash -c "makepkg -s --noconfirm --nocheck"
```

### Multi-core Builds

```bash
# Use all CPU cores
docker run --rm \
    -v $(pwd):/build \
    -w /build \
    -e MAKEFLAGS="-j$(nproc)" \
    claude-desktop-builder:latest
```

---

## Installing the Built Package

### On Arch Linux

```bash
sudo pacman -U claude-desktop-*.pkg.tar.zst
```

### On Other Systems

The `.pkg.tar.zst` file is Arch-specific. To use Claude Desktop on other systems:

1. **Transfer to Arch system**: Copy the `.pkg.tar.zst` file
2. **Install on Arch**: Use `pacman -U` as shown above
3. **Alternative**: Use the official Claude Desktop for your OS from https://claude.ai/

---

## Troubleshooting

### Docker daemon not running

```bash
# Linux
sudo systemctl start docker

# macOS/Windows
# Start Docker Desktop application
```

### Permission denied

```bash
# Linux: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Build fails

```bash
# Clean build (remove cache)
docker-compose down -v
docker-compose up builder

# Or rebuild image
docker-compose build --no-cache
```

### Out of disk space

```bash
# Clean up Docker
docker system prune -a --volumes
```

---

## CI/CD Integration

### GitHub Actions

Already configured in `.github/workflows/build.yml`

### GitLab CI

```yaml
build:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t builder .
    - docker run --rm -v $(pwd):/build builder
  artifacts:
    paths:
      - claude-desktop-*.pkg.tar.zst
```

### Jenkins

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh './docker-build.sh'
            }
        }
    }
}
```

---

## Performance Tips

1. **Use build cache**: Docker caches layers automatically
2. **Multi-core builds**: Set `MAKEFLAGS="-j$(nproc)"`
3. **Local registry**: Push image to local registry for faster rebuilds
4. **Volume mounts**: Use volumes instead of copying files

---

## Resources

- [Dockerfile](../Dockerfile)
- [docker-compose.yml](../docker-compose.yml)
- [docker-build.sh](../docker-build.sh)
- [Docker Documentation](https://docs.docker.com/)
