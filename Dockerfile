# syntax=docker/dockerfile:1
FROM archlinux:latest

# Metadata
LABEL org.opencontainers.image.title="Claude Desktop Arch Builder"
LABEL org.opencontainers.image.description="Build environment for claude-desktop Arch package"
LABEL org.opencontainers.image.source="https://github.com/h-filzer/claude-desktop-arch"

# Update system and install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        base-devel \
        git \
        wget \
        icoutils \
        imagemagick \
        p7zip \
        nodejs \
        npm \
        sudo \
        namcap && \
    pacman -Scc --noconfirm

# Create builder user (makepkg cannot run as root)
RUN useradd -m -G wheel builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set working directory
WORKDIR /build

# Copy package files
COPY --chown=builder:builder . .

# Switch to builder user
USER builder

# Set entrypoint
ENTRYPOINT ["/bin/bash"]

# Default command builds the package
CMD ["makepkg", "-s", "--noconfirm"]
