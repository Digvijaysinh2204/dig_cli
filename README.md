# 🛠️ DIG CLI

A powerful Flutter CLI tool to automate building, cleaning, packaging, and renaming your projects across all platforms.

[![pub package](https://img.shields.io/pub/v/dig_cli.svg)](https://pub.dev/packages/dig_cli)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## 🚀 Features

- **Interactive Menu**: Easy navigation; run the tool without commands for a guided experience.
- **🏷️ Rename App**: Smart renaming for **Android, iOS, macOS, Windows, Linux, and Web**.
    - Handles Android namespace updates and directory restructuring.
    - Updates bundle IDs and display names across all platform-specific files.
- **Build APK/AAB**: Release builds with automatic `ProjectName-YYYY-MM-DD-HH-MM` naming.
- **Deep Clean**: Removes Flutter, Gradle, Xcode, and Pods caches on macOS, Windows, and Linux.
- **Create Clean ZIP**: Packages your project into a ZIP file, excluding files from `.gitignore`.
- **Auto Update Check**: Checks for new versions on pub.dev and provides an update option.

---

## 📦 Installation

```bash
dart pub global activate dig_cli
```

After installation, use **`dg`** as the command.

---

## ⚙️ Usage

### Interactive Menu (Recommended)

```bash
dg
```

### Direct Commands

- **Rename App**: `dg rename --name "New Name" --bundle-id com.new.id`
- **Build APK**: `dg create apk`
- **Build AAB**: `dg create bundle`
- **Clean Project**: `dg clean`
- **Create ZIP**: `dg zip`
- **Show Version**: `dg --version`

---

## 🧪 Examples

```bash
# Rename app and bundle identifier (All Platforms)
dg rename --name "Awesome App" --bundle-id com.my.awesome.app

# Build an APK with a custom name
dg create apk --name MyApp --output ~/Downloads

# Deep clean the project's build artifacts
dg clean
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