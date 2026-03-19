# 🛠️ DIG CLI

A powerful Flutter CLI tool to automate building, cleaning, packaging, and renaming your projects across all platforms. Designed with a premium Developer Dashboard to speed up your daily workflow.

[![pub package](https://img.shields.io/pub/v/dig_cli.svg)](https://pub.dev/packages/dig_cli)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## 🚀 Features

### 🌟 Categorized Developer Dashboard (v1.7.1)
Run `dg` to instantly access the 15-item categorized master dashboard:

1. **📦 BUILD & RELEASE**
   - 🏗️ Build APK
   - 📦 Build App Bundle (AAB)
   - 🍎 Build iOS (IPA)
2. **🧹 CLEAN & FIX**
   - 🧼 Fast Clean (flutter clean only)
   - ☢️ Clean & Full Reset (Pub get, Pods, optional Global Cache wipe)
3. **🔐 SIGNING & KEYS**
   - 🔐 Create JKS (Keystore with portable relative paths)
   - 🔑 Generate SHA Keys (SHA1/SHA256)
   - 🔑 Generate Hash Key (Base64 encoded for Facebook/Google Login)
4. **🔥 CONFIGURATION**
   - 🔥 Firebase Setup (Direct config reading, Login/Logout toggle)
   - ✨ Auto Setup Assets (`pubspec.yaml` auto-registration)
5. **🏗️ PROJECT MANAGEMENT**
   - 🧱 Create "Proper" Flutter Project (v1.5.0 Standard with secure defaults)
   - 📂 Create GetX Module (View, Controller, Binding, Route)
   - 🏷️ Rename App / Bundle (All 6 Platforms!)
6. **📦 UTILITIES**
   - 🗜️ Zip Source Code (Excludes ignored files)
   - 🚀 Check for Updates (One-click update from pub.dev)

### ✨ Auto Asset Generation (`dg asset build` / `dg asset watch`)
Subfolder-based asset organization that auto-registers into your `pubspec.yaml`:
- Folder structure determines class names: `assets/bottom_bar/svg` → `BottomBarSvg`
- Smart cross-platform watcher prevents redundancy.
- Single import: `import 'package:app/generated/assets.dart'`
- See [ASSET_GENERATION_GUIDE.md](ASSET_GENERATION_GUIDE.md) for detailed examples.

---

## 📦 Installation

```bash
dart pub global activate dig_cli
```

After installation, use **`dg`** as the command.

---

## ⚙️ Usage

### Interactive Menu (Highly Recommended)

```bash
dg
```

### Direct Commands

- **Create Project**: `dg create-project`
- **Create Module**: `dg create-module auth` (or `dg create-module -n auth`)
- **Rename App**: `dg rename --name "New Name" --bundle-id com.new.id`
- **Build APK**: `dg create apk`
- **Build AAB**: `dg create bundle`
- **Clean Project**: `dg clean` (use `--global` for Nuclear mode)
- **Create ZIP**: `dg zip`
- **Generate Assets**: `dg asset build`
- **Watch Assets**: `dg asset watch`
- **Show Version**: `dg --version`

---

## 🧪 Examples

```bash
# Rename app and bundle identifier (All Platforms)
dg rename --name "Awesome App" --bundle-id com.my.awesome.app

# Build an APK with a custom name
dg create apk --name MyApp --output ~/Downloads

# Deep clean the project's build artifacts
dg clean --global

# Generate assets with subfolder-based classes
dg asset build
# Creates: BottomBarSvg, IconsSvg, FontsInterTtf, etc.
```

### Asset Generation Example

```dart
// Folder: assets/bottom_bar/svg/home.svg
import 'package:your_app/generated/assets.dart';
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(BottomBarSvg.home);

// Folder: assets/fonts/inter/bold.ttf
Text('Hello', style: TextStyle(fontFamily: FontsInterTtf.bold));
```

---

## 🖥️ Platform-specific Setup (Alias)

By default, use `dg` in your terminal. If you prefer a custom command name (alias), you can set it up easily:

### macOS & Linux

```bash
# Add this to ~/.zshrc or ~/.bashrc
alias df="dg"
```

### Windows (PowerShell)

```powershell
Set-Alias df dg
```

---

## 📝 License

Licensed under the [MIT License](LICENSE).

Made with ❤️ by [Digvijaysinh Chauhan](https://github.com/Digvijaysinh2204)

- **Check out my Flutter packages on [pub.dev](https://pub.dev/packages?q=Digvijaysinh+Chauhan)**
