# 🛠️ dig_cli

A powerful Flutter CLI tool to automate building, cleaning, and packaging your projects.

[![pub package](https://img.shields.io/pub/v/dig_cli.svg)](https://pub.dev/packages/dig_cli)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## Overview

**dig_cli** is a robust command-line interface designed to streamline your Flutter workflow. It automates common tasks such as creating timestamped APKs/AABs, performing deep system-specific cleaning, and packaging your project for sharing or deployment.

It features:
- Beautiful interactive menu
- Dynamic version checking from `pubspec.yaml`
- Update notifications

---

## 🚀 Features

- **Interactive Menu**: Easy navigation; run the tool without commands for a guided experience.
- **Build APK/AAB**: Release builds with automatic `ProjectName-YYYY-MM-DD-HH-MM` naming.
- **Deep Clean**: Removes Flutter, Gradle, Xcode, and Pods caches on macOS, Windows, and Linux.
- **Create Clean ZIP**: Packages your project into a ZIP file, excluding files from `.gitignore`.
- **Smart Menu Logic**: Hides build options if not in a buildable Flutter project.
- **Dynamic Versioning**: Reads version from `pubspec.yaml`.
- **Auto Update Check**: Checks for new versions on pub.dev and provides update option.

---

## 📦 Installation

```bash
dart pub global activate dig_cli
```

After installation, use `dig` as the command.

---

## ⚙️ Usage

### Interactive Menu (Recommended)

```bash
dig
```

### Direct Commands

- Build APK: `dig create apk`
- Build AAB: `dig create bundle`
- Clean Project: `dig clean`
- Create ZIP: `dig zip`
- Show Version: `dig --version`

---

## 🖥️ Interactive Menu Example

```
╔════════════════════════════════════════╗
║          DIG CLI TOOL v1.1.0          ║
╠════════════════════════════════════════╣
║  1. 🚀 Build APK                       ║
║  2. 📦 Build AAB                       ║
║  3. 🧹 Clean Project                   ║
║  4. 🤐 Create Project ZIP              ║
║  5. ✨ Update to v1.2.0                ║
║  0. 🚪 Exit                            ║
╚════════════════════════════════════════╝
```
*Build and update options are shown dynamically based on project status and version availability.*

---

## 🧪 Examples

```bash
# Launch the interactive menu for guided actions
dig

# Build an APK with a custom name and output to the Downloads folder
dig create apk --name MyApp --output ~/Downloads

# Deep clean the project's build artifacts
dig clean

# Create a clean, shareable ZIP file of the project on the Desktop
dig zip
```

---

## ⚙️ Options

| Option            | Alias | Description                                 |
|-------------------|-------|---------------------------------------------|
| `--help`          | `-h`  | Show help (when used with a command)        |
| `--version`       | `-v`  | Show the tool's version                     |
| `--output <dir>`  | `-o`  | Specify output directory (default: Desktop) |
| `--name <prefix>` | `-n`  | Custom name prefix for build/zip output file|

---

## 🖥️ Platform-specific Setup

### macOS & Linux (Ubuntu)

By default, use `dig_cli` in your terminal. If you prefer a shorter command, you can set up an alias:

```bash
# Add this to ~/.zshrc, ~/.bashrc, or ~/.zshenv
alias myflutter="dig_cli"
```

- You can use any alias name you like. After adding the alias and restarting your terminal (or running `source ~/.zshrc` or `source ~/.bashrc`), you can use your chosen alias (e.g., `myflutter`) instead of `dig_cli` in all commands.

### Windows

#### PowerShell

Add the following line to your PowerShell profile (you can find your profile path with `$PROFILE`):

```powershell
Set-Alias myflutter dig_cli
```

- Restart PowerShell or run the above command in your current session to use your alias (e.g., `myflutter`).

#### Command Prompt (cmd.exe)

You can create a simple batch file to act as an alias:

1. Open Notepad and add the following line:
   ```bat
   @echo off
   dig_cli %*
   ```
2. Save the file as `myflutter.bat` in a directory included in your system's PATH (e.g., `C:\Windows`).
3. Now you can use `myflutter` instead of `dig_cli` in Command Prompt.

---

## 🔗 Links

- [Pub.dev](https://pub.dev/packages/dig_cli)
- [GitHub](https://github.com/Digvijaysinh2204/dig_cli)

---

## 🤝 Contributing

1. Fork this repo
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'feat: add something'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

---

## 📝 License

Licensed under the [MIT License](LICENSE).

---

Made with ❤️ by [Digvijaysinh Chauhan](https://github.com/Digvijaysinh2204)