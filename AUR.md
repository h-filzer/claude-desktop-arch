# Publishing to AUR (Arch User Repository)

This guide explains how to publish and maintain this package on the AUR.

## Prerequisites

1. **AUR account**: Register at https://aur.archlinux.org/register/
2. **SSH key**: Add your SSH key to your AUR account
3. **Git configured**: Ensure your git is configured with your name and email

## Initial Setup

### 1. Clone the AUR repository

```bash
git clone ssh://aur@aur.archlinux.org/claude-desktop.git aur-claude-desktop
cd aur-claude-desktop
```

### 2. Copy package files

```bash
# From this repository, copy:
cp ../claude-desktop-arch/PKGBUILD .
cp ../claude-desktop-arch/.SRCINFO .
```

### 3. Create .gitignore

```bash
cat > .gitignore <<EOF
*
!.gitignore
!PKGBUILD
!.SRCINFO
EOF
```

## Publishing Updates

### 1. Update version

Edit `PKGBUILD` and update `pkgver`:

```bash
pkgver=0.13.19  # Update this to new version
```

### 2. Regenerate .SRCINFO

```bash
makepkg --printsrcinfo > .SRCINFO
```

### 3. Test the build

```bash
# Use chroot for clean testing
../claude-desktop-arch/setup-chroot.sh all
```

### 4. Commit and push to AUR

```bash
git add PKGBUILD .SRCINFO
git commit -m "Update to version 0.13.19"
git push
```

## Automated Version Checking

Use the included version checker:

```bash
cd ../claude-desktop-arch
./check-version.sh
```

This will:
- Check if a new Claude Desktop version is available
- Tell you if an update is needed
- Provide instructions for updating

## Maintenance Workflow

1. **Monitor for updates**: Run `./check-version.sh` regularly
2. **Test changes**: Always test in chroot before publishing
3. **Update AUR**: Push to AUR repository
4. **Update GitHub**: Keep this repository in sync

## AUR Package Standards

- **PKGBUILD**: Must follow Arch packaging standards
- **.SRCINFO**: Must be in sync with PKGBUILD
- **Comments**: Reply to AUR comments promptly
- **Orphaning**: If you can't maintain it, disown the package

## Useful Commands

```bash
# Check package for common issues
namcap PKGBUILD
namcap claude-desktop-*.pkg.tar.zst

# Build in clean chroot
./setup-chroot.sh all

# Check version
./check-version.sh

# Update .SRCINFO
makepkg --printsrcinfo > .SRCINFO
```

## Resources

- AUR Submission Guidelines: https://wiki.archlinux.org/title/AUR_submission_guidelines
- PKGBUILD Standard: https://wiki.archlinux.org/title/PKGBUILD
- AUR Helpers: https://wiki.archlinux.org/title/AUR_helpers
