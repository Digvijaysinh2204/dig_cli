# 🚀 DIG CLI

[![pub package](https://img.shields.io/pub/v/dig_cli.svg)](https://pub.dev/packages/dig_cli)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub](https://img.shields.io/badge/github-repo-181717?logo=github)](https://github.com/Digvijaysinh2204/dig_cli)

**DIG CLI** (`dg`) is a premium, enterprise-grade command-line tool designed for Flutter developers. It automates your daily workflows with an intuitive **Interactive Dashboard** and a powerful set of low-level commands. From rebuilding your entire architecture to generating robust boilerplate code, `dg` is the ultimate Flutter companion.

---

## ✨ Why DIG CLI?

- **Interactive Dashboard UI**: Forget complex terminal arguments. Just type `dg` and follow the beautiful, colorful prompts.
- **Flawless Modularity**: Generate GetX features (View, Controller, Binding, Exports) seamlessly integrated into standard routing architectures.
- **Smart Asset Generation**: Automatically watch and build asset classes, keeping string typos out of your codebase.
- **Frictionless Release**: Instantly build APKs, AABs, and IPAs, or automate secure keystore (JKS) and SHA keys generation.
- **Deep Clean**: Flush hidden caches and repair pub packages with strict zero-fail tools.

---

## ⚙️ Requirements
- **Dart SDK**: `>=3.0.0`
- **Flutter**: Ensure `flutter` is perfectly configured in your system `PATH`.

---

## 📦 Installation

**1. Stable Release (via pub.dev)**
To globally activate the stable version of the CLI using Dart:
```bash
dart pub global activate dig_cli
```

**2. Bleeding-Edge Release (via GitHub Source)**
If you want direct access to the latest, unreleased features, you can install directly from the GitHub repository:
```bash
dart pub global activate -sgit https://github.com/Digvijaysinh2204/dig_cli.git
```

**Executable Alias (`dg`)**
The `dig_cli` package registers a global alias named **`dg`**. Ensure your global pub cache is embedded in your system's `PATH`.

Once configured, verify the alias installation is active:
```bash
dg --version
```

---

## ⚡ Quick Start: The Interactive Dashboard

The easiest way to use Dig CLI is to just type `dg`. You will be instantly greeted by a clean, premium terminal UI covering all commands.

```bash
dg
```

**What you will see:**
- `Build & Release`: Generate APKs, AABs, IPAs with auto-naming.
- `Clean & Repair`: Powerful wipes to reset a stuck iOS/Android build space.
- `Keys & Security`: Pull SHA1/SHA256 data, setup auto-JKS for signings.
- `Configuration`: Automated Asset scaffolding.
- `Project Management`: Instantiate entire GetX Template Projects or drop-in robust GetX Modules into your existing app.

---

## 🛠️ Command Reference

For users who want to utilize the CLI within CI/CD pipelines, here is the full suite of headless terminal commands. (Run `dg <command> --help` for deeper flags).

| Command Area | Syntax | Description |
|---|---|---|
| **Build System** | `dg create apk` | Compile a Release APK. Optional `-o` (output) and `-n` (name). |
| | `dg create bundle` | Compile an Android App Bundle (AAB). |
| | `dg ios` | Complete iOS IPA build pipeline. |
| **Maintenance** | `dg clean` | Full framework reset (handles CocoaPods, Xcode, build caches). |
| | `dg pub-cache` | Runs `flutter pub cache repair`. |
| **Security** | `dg create-jks` | Generate & hook a secure Android keystore. |
| | `dg sha-keys` | Display formatted SHA1 and SHA256 fingerprints. |
| | `dg hash-key` | Extract hash keys (great for Facebook/Google Logins). |
| **Scaffolding** | `dg create-project` | Instantiates our premium template from the Digvijaysinh repo. |
| | `dg create-module` | Fully scaffolds a routed GetX feature (Binding, Controller, View). |
| **Asset Engine** | `dg asset build` | Injects strongly typed Asset classes into Dart. |
| | `dg asset watch` | Watches for real-time asset changes in your workspace. |
| **System** | `dg rename` | Renames Application Display Name & Global Bundle ID. |
| | `dg zip` | Compress project files (respecting `.gitignore`). |

---

## 💡 Examples

### 1. Rename Your App
A complete cross-platform rename (modifies iOS `Info.plist`, Android `build.gradle`, etc.):
```bash
dg rename --name "Stock Sarthi" --bundle-id com.dig.stocksarthi
```

### 2. Scaffold a Feature
Add a new robust page (creates routing, bindings, variables, layout):
```bash
dg create-module --name "Profile Page"
```

### 3. Generate Type-Safe Assets
```bash
dg asset build
```
Generates output you can use directly:
```dart
SvgPicture.asset(BottomBarSvg.home);
```

---

## 👨‍💻 Author & License

- **Author**: [Digvijaysinh Chauhan](https://github.com/Digvijaysinh2204)
- **License**: [MIT](LICENSE)

> *"Efficiency through Automation."*
