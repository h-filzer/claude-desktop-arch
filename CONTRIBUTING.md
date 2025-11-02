# Contributing to claude-desktop-arch

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Ways to Contribute

- 🐛 Report bugs or issues
- 💡 Suggest new features or improvements
- 📝 Improve documentation
- 🔧 Submit bug fixes or enhancements
- 🧪 Test the package on different Arch-based distributions

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/claude-desktop-arch.git
   cd claude-desktop-arch
   ```
3. **Create a branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### Testing Your Changes

**Always test in a chroot environment** before submitting:

```bash
./setup-chroot.sh all
```

This ensures:
- Clean build environment
- No system contamination
- Reproducible builds

### Code Standards

- **PKGBUILD**: Follow [Arch packaging standards](https://wiki.archlinux.org/title/PKGBUILD)
- **Shell scripts**: Use `shellcheck` for linting
- **Bash style**: Use consistent indentation (4 spaces or tabs)
- **Comments**: Add comments for non-obvious logic

### Commit Messages

Use clear, descriptive commit messages:

```
✅ Good:
- "Update PKGBUILD to version 0.13.19"
- "Fix electron installation lock file handling"
- "Add GitHub Actions CI workflow"

❌ Bad:
- "update stuff"
- "fix"
- "wip"
```

## Submitting Changes

1. **Test thoroughly**:
   ```bash
   # Test build
   ./setup-chroot.sh all
   
   # Check PKGBUILD
   namcap PKGBUILD
   
   # Verify .SRCINFO sync
   makepkg --printsrcinfo > .SRCINFO.test
   diff .SRCINFO .SRCINFO.test
   ```

2. **Update .SRCINFO** if you modified PKGBUILD:
   ```bash
   makepkg --printsrcinfo > .SRCINFO
   ```

3. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Description of your changes"
   ```

4. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request** on GitHub

## Pull Request Guidelines

### PR Title Format

- Use descriptive titles
- Prefix with emoji if appropriate: 🐛 (bug), ✨ (feature), 📝 (docs), 🔧 (fix)

### PR Description Should Include

- What changes were made
- Why the changes were necessary
- How to test the changes
- Any breaking changes or migration notes

### Example PR Description

```markdown
## Changes
- Updated PKGBUILD to version 0.13.20
- Fixed icon extraction for 256x256 size
- Added error handling for missing dependencies

## Testing
Tested in clean chroot:
\`\`\`bash
./setup-chroot.sh all
\`\`\`

## Breaking Changes
None
```

## Reporting Issues

When reporting bugs, include:

- **Arch distribution**: Arch Linux, Manjaro, EndeavourOS, etc.
- **Version**: Package version (`pacman -Q claude-desktop`)
- **Error output**: Full error messages or logs
- **Steps to reproduce**: How to trigger the issue
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens

### Example Issue

```markdown
**Distribution**: Arch Linux (latest)
**Package Version**: 0.13.19-1

**Issue**: Launcher fails to start electron

**Error**:
\`\`\`
Error: Electron binary not found at /usr/lib/node_modules/electron-claude-desktop/dist/electron
\`\`\`

**Steps to reproduce**:
1. Install package with `pacman -U claude-desktop-*.pkg.tar.zst`
2. Run `claude-desktop`
3. Error occurs

**Expected**: Claude Desktop should launch
**Actual**: Error message and exit
```

## Version Updates

When updating to a new Claude Desktop version:

1. **Check for new version**:
   ```bash
   ./check-version.sh
   ```

2. **Update PKGBUILD**:
   - Change `pkgver`
   - Update `_download_url` if necessary
   - Test extraction and icon processing

3. **Regenerate .SRCINFO**:
   ```bash
   makepkg --printsrcinfo > .SRCINFO
   ```

4. **Test thoroughly**:
   ```bash
   ./setup-chroot.sh all
   ```

5. **Submit PR** with version bump

## Questions?

- 💬 Open a [GitHub Discussion](https://github.com/h-filzer/claude-desktop-arch/discussions)
- 🐛 File an [Issue](https://github.com/h-filzer/claude-desktop-arch/issues)
- 📧 Contact maintainer (check PKGBUILD for contact)

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other contributors

Thank you for contributing! 🎉
