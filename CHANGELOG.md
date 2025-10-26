# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - Trinity Upgrade Branch

### Added
- 🤖 `.github/copilot-instructions.md` - AI agent guidance for codebase
- 🔍 `check-version.sh` - Automated version checker for Claude Desktop updates
- 🚀 `.github/workflows/build.yml` - GitHub Actions CI for automated testing
- 📖 `AUR.md` - Guide for publishing to Arch User Repository
- 🤝 `CONTRIBUTING.md` - Contribution guidelines and workflow
- 📝 `CHANGELOG.md` - This changelog file
- ✨ Enhanced `.gitignore` with more comprehensive patterns
- 📊 CI badge and version info in README.md

### Changed
- 📦 Updated `.SRCINFO` to sync with PKGBUILD version 0.13.19
- 📚 Enhanced README.md with quick links and improved update instructions
- 🔧 Improved documentation structure across the project

### Fixed
- 🐛 `.SRCINFO` version mismatch (was 1.0.0, now 0.13.19)

## [0.13.19-1] - 2024-09-24

### Added
- ✨ Initial release with Claude Desktop 0.13.19
- 📦 PKGBUILD for Arch Linux packaging
- 🔧 `install.sh` - Convenience installation script
- 🧪 `setup-chroot.sh` - Chroot testing environment
- 📝 Comprehensive README.md with build and troubleshooting guides
- 🎨 Icon extraction and conversion from Windows installer
- 🔌 Stub implementation for `claude-native` module
- 🚀 On-demand Electron installation in launcher script
- 🔒 Lock file mechanism to prevent concurrent Electron installs

### Technical Details
- Downloads Windows installer from Google Cloud Storage
- Extracts resources using 7zip
- Creates stub for Windows-specific native modules
- Packages as Arch Linux package with proper dependencies
- Includes desktop integration (icons, launcher, .desktop file)

---

## Version Numbering

This project follows the Claude Desktop version numbers:
- **Major.Minor.Patch**: Follows upstream Claude Desktop version (e.g., 0.13.19)
- **-Release**: Arch package release number (e.g., -1, -2)

Example: `0.13.19-1`
- `0.13.19` = Claude Desktop version
- `-1` = First Arch package release for this version

---

## Links

- [GitHub Repository](https://github.com/h-filzer/claude-desktop-arch)
- [Upstream Source](https://www.anthropic.com/claude)
- [Original Debian Package](https://github.com/aaddrick/claude-desktop-debian)
