## Quick orientation — what this repo is

This repository packages the Claude Desktop Electron app for Arch Linux using a PKGBUILD-based workflow. The build flow downloads the Windows installer, extracts the contained NuGet package, pulls out the Electron `app.asar`, injects a small stub for native modules, and bundles everything into an Arch package (`claude-desktop-*.pkg.tar.zst`). See `PKGBUILD` for the canonical build steps.

## Important high-level components

- `PKGBUILD` — central build script. Downloads the Windows installer (`_download_url`), extracts `AnthropicClaude-*.nupkg`, processes `lib/net45/resources/app.asar` and `app.asar.unpacked`, creates a stub `claude-native` implementation, re-packs `app.asar`, and installs files into the package layout.
- `install.sh` — convenience wrapper that runs `makepkg -s` and installs the resulting package with `pacman -U` (do not run this script as root).
- `setup-chroot.sh` — isolated test environment for building/testing the package in a clean Arch chroot. Commands: `setup`, `copy`, `enter`, `test`, `cleanup`, `all` (recommended for validating PKGBUILD changes).
- `src/electron-app/app.asar.contents/package.json` — source Electron app metadata (electron version, devDependencies, node engine requirement). Useful when inspecting compatibility and dev tooling.
- `pkg/` — contains prepared packaging outputs for distribution; `pkg/claude-desktop/usr/lib/claude-desktop` mirrors runtime layout used by the launcher.

## Developer workflows (explicit commands)

- Build & install locally (recommended):

  - Clone repo and run: `./install.sh`  # script will call `makepkg -s` and then `sudo pacman -U ...`

- Manual build:

  - `makepkg -si`  # builds and installs dependencies+package (do NOT run as root)

- Chroot-based testing (safe):

  - `./setup-chroot.sh all` — creates chroot, copies PKGBUILD, builds and installs package in chroot.
  - For stepwise control: `./setup-chroot.sh setup`, `./setup-chroot.sh copy`, `./setup-chroot.sh enter` then inside chroot `su - builder; makepkg -s`.

- Run the app after install: `claude-desktop` (launcher is installed to `/usr/bin/claude-desktop`).

## Project-specific conventions & gotchas

- Never run `makepkg` or `setup-chroot.sh` as root. Scripts explicitly check and will exit if run as root.
- PKGBUILD creates a stub for the native module `claude-native` rather than building platform-native binaries. The stub is created in `prepare()` and again in `package()`; it exposes a fixed `KeyboardKey` enum and no-op functions (see the inline JS in `PKGBUILD`). If you need to change expected keys, update those constants in the PKGBUILD stubs.
- The packaging extracts the official Windows installer (7z is used). If updating `_download_url`, ensure the new installer contains the expected `AnthropicClaude-*.nupkg` layout.
- Electron is launched on-demand by the shipped `claude-desktop` wrapper script. That launcher will try to install a global `electron-claude-desktop` npm alias if a system Electron is absent. The launcher uses a lock file in `/tmp` to avoid concurrent npm installs — preserve that behavior if you change the launcher.

## Integration points and dependencies

- External downloads: `_download_url` in `PKGBUILD` -> Google Cloud Storage URL to Windows installer. Changing sources requires updating checksums if applicable.
- Tools used in build: `wget`, `7z`, `wrestool`, `icotool`, `npx @electron/asar` (pack/extract). These are listed in `makedepends` in `PKGBUILD`.
- Runtime dependencies declared: `nodejs` and `npm` are required by the package (`depends` in `PKGBUILD`). The launcher expects `npm` for on-demand electron installation if electron is not present.

## Where to look for examples in this repo

- PKGBUILD: exact packaging steps, icon processing, stub native module, repackaging of `app.asar`.
- `install.sh`: simple, canonical way to build & install locally.
- `setup-chroot.sh`: scripted chroot workflow; follow its `all` target for full automated testing.
- `pkg/claude-desktop/usr/bin/claude-desktop` and `pkg/claude-desktop/usr/lib/claude-desktop/` — runtime layout used after install; good examples when changing file locations.

## Short checklist for the AI agent when making edits

1. If you change packaging behavior, update `PKGBUILD` and run `./setup-chroot.sh test` (or `./setup-chroot.sh all`) to validate build.
2. Preserve the no-root policy for `makepkg` and `setup-chroot.sh` — do not suggest `sudo makepkg`.
3. If touching the `claude-native` stub, update both the `prepare()` repacked `app.asar` and the `package()` unpacked stub paths so runtime behavior remains consistent.
4. When updating `_download_url`, ensure the extraction logic still finds the `AnthropicClaude-*.nupkg` file and update README notes about version bumping.

## If something's unclear

Ask for the intended change scope (packaging vs app modification), and whether the user wants an updated packaged artifact added to `pkg/` or just PKGBUILD changes. I can regenerate and validate the chroot build when you confirm.
