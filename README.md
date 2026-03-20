# DIG CLI

[![pub package](https://img.shields.io/pub/v/dig_cli.svg)](https://pub.dev/packages/dig_cli)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub](https://img.shields.io/badge/github-repo-181717?logo=github)](https://github.com/Digvijaysinh2204/dig_cli)

**DIG CLI** (`dg`) is a command-line helper for Flutter projects: release builds, cleans and resets, Android/iOS signing helpers, Firebase and assets, scaffolding (GetX modules, new projects), rename across platforms, and more. Use **`dg`** with no arguments for an interactive menu, or call subcommands from scripts and CI.

---

## Requirements

- **Dart SDK** 3.0+ (see `pubspec.yaml`).
- **Flutter** on your `PATH` for builds, clean, pub-cache repair, and most project workflows.

---

## Install

```bash
dart pub global activate dig_cli
```

Ensure the pub cache `bin` directory is on your `PATH` (Dart usually prints a hint after `global activate`). Then run:

```bash
dg --version
```

---

## Quick start

| Goal | Command |
|------|---------|
| Open the interactive UI | `dg` |
| Show version & update hints | `dg version` or `dg --version` |
| Command list / help | `dg --help` |

The interactive flow is **category → action** (single bordered panel per screen). Output respects **`NO_COLOR`** and non-TTY environments when possible.

---

## Features (overview)

| Area | What you get |
|------|----------------|
| **Build & release** | APK / App Bundle via `dg create …`; iOS IPA via `dg ios`. |
| **Clean & fix** | `dg clean` (optional `--global`); `dg pub-cache` runs `flutter pub cache repair`. |
| **Signing & keys** | JKS creation, SHA keys, hash key helpers for Android / login SDKs. |
| **Configuration** | `dg firebase` (login, configure, check); `dg asset build` / `dg asset watch`. |
| **Project management** | New Flutter project template, GetX module scaffold, rename app + bundle IDs. |
| **Utilities** | Zip sources (respecting ignores), stable / pre-release update checks. |

For asset folder layout and generated classes, see **[ASSET_GENERATION_GUIDE.md](ASSET_GENERATION_GUIDE.md)**.

---

## Command reference

Run `dg <command> --help` for flags and options.

| Command | Description |
|---------|-------------|
| `dg` | Interactive menu (no args). |
| `dg create apk` | Release APK; optional `-o` / `-n`. |
| `dg create bundle` | Release App Bundle (AAB). |
| `dg ios` | iOS IPA build flow. |
| `dg clean` | Project clean / full reset; `--global` for heavier cache wipe. |
| `dg pub-cache` | Repair pub cache (`flutter pub cache repair`). |
| `dg zip` | Zip project sources. |
| `dg rename` | Rename app + bundle id (multi-platform). |
| `dg create-jks` | Generate / configure JKS keystore workflow. |
| `dg sha-keys` | SHA1 / SHA256 fingerprints. |
| `dg hash-key` | Hash key helper (e.g. Facebook / Google login setup). |
| `dg create-project` | Scaffold a new Flutter project. |
| `dg create-module` | GetX module (view / controller / binding / route). |
| `dg firebase …` | `login`, `logout`, `configure`, `check`. |
| `dg asset build` | Generate typed asset classes + update `pubspec.yaml`. |
| `dg asset watch` | Watch asset folders and rebuild. |
| `dg version` | Version, path, pub.dev latest (same as `--version` entry where applicable). |

---

## Examples

```bash
# Interactive dashboard
dg

# Rename display name and bundle id
dg rename --name "Awesome App" --bundle-id com.example.awesome

# APK with custom prefix and output folder
dg create apk --name MyApp --output ~/Downloads

# Deep clean (optional global caches — prompts / flags as implemented)
dg clean --global

# Repair global Flutter pub cache
dg pub-cache

# Regenerate asset registry and Dart classes
dg asset build
```

Generated assets (illustrative):

```dart
// assets/bottom_bar/svg/home.svg
import 'package:your_app/generated/assets.dart';
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(BottomBarSvg.home);
```

---

## Optional: shell alias

If you want a shorter name, pick something that does not clash with common tools (avoid `df`, etc.):

```bash
# ~/.zshrc or ~/.bashrc
alias mydg='dg'
```

**Windows (PowerShell):** `Set-Alias mydg dg`

---

## Changelog

Release notes: **[CHANGELOG.md](CHANGELOG.md)**.

---

## License

[MIT](LICENSE).

**Author:** [Digvijaysinh Chauhan](https://github.com/Digvijaysinh2204) — [packages on pub.dev](https://pub.dev/packages?q=Digvijaysinh+Chauhan).
