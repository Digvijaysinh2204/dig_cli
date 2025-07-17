# 🛠️ dig_cli

> **Note:** The default command is `dig_cli`. If you want to use a shorter command, you must set up an alias (see the 'Setup Alias' section below).

A powerful Flutter CLI tool for building APKs and AABs with automatic timestamped filenames, cleaning build artifacts, and organizing output — all from your terminal.

[![pub package](https://img.shields.io/pub/v/dig_cli.svg)](https://pub.dev/packages/dig_cli)  
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## 🚀 Features

- 📦 **Build APK**: Generate release APKs with datetime-stamped filenames  
- 🎯 **Build AAB**: Generate Android App Bundles (.aab) with timestamps  
- 🧹 **Clean Projects**: Deep clean Flutter, iOS, and Android build files  
- 🖥️ **Auto-Export to Desktop**: Outputs are automatically moved to your Desktop  
- ⏱ **Timestamp Naming**: Output files are named using the current date and time  
- 🛠 **Cross-Platform**: Works on macOS, Windows, and Linux  

---

## 📦 Installation

### ✅ From pub.dev

```bash
flutter pub global activate dig_cli
```

### 📁 From GitHub (local source)

```bash
git clone https://github.com/Digvijaysinh2204/dig_cli.git
cd dig_cli
flutter pub global activate --source path .
```

Install globally via Git:

```bash
dart pub global activate --source git https://github.com/Digvijaysinh2204/dig_cli.git
```
---

## 🖥️ Platform-specific Setup

### macOS & Linux (Ubuntu)

By default, use `dig_cli` in your terminal. If you prefer a shorter command, you can set up an alias (macOS and Linux setup is the same):

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

## ⚙️ Usage

### Build APK

```bash
dig_cli create build
```

Output (Desktop): `yourproject-25-12-2025-02.30PM.apk`

### Build AAB

```bash
dig_cli create bundle
```

Output (Desktop): `yourproject-25-12-2025-02.30PM.aab`

### Clean Project

```bash
dig_cli clean
```

Or:

```bash
dig_cli clear build
```

This cleans:
- Flutter build and cache  
- Android `.gradle`, `.cxx`, build folders  
- iOS workspace, Pods, build folder, and DerivedData (macOS only)

---

## 🧪 Examples

```bash
dig_cli create apk
dig_cli create build
# Builds PubSpecName-DD-MM-YYYY-HH.MMAM.apk to Desktop

dig_cli create build --name MyApp
# Builds MyApp-DD-MM-YYYY-HH.MMAM.apk to Desktop

dig_cli create bundle -o ./output
# Builds AAB to ./output folder

dig_cli clean
# Fully cleans Android and iOS artifacts

# Build APK with custom name and output directory

dig_cli create apk --name MyApp --output ~/Downloads
# Builds MyApp-DD-MM-YYYY-HH.MMAM.apk to your Downloads folder
```

---

## 📂 Output File Naming

All output files follow the pattern:

- **APK**: `{project_or_custom_name}-{dd-mm-yyyy}-{hh.mmAM}.apk`  
- **AAB**: `{project_or_custom_name}-{dd-mm-yyyy}-{hh.mmAM}.aab`  

These are automatically moved to your Desktop (or a specified output directory).

---

## ⚙️ Options

| Option              | Alias | Description                                                  |
|---------------------|-------|--------------------------------------------------------------|
| `--help`            | `-h`  | Show help                                                    |
| `--version`         | `-v`  | Show version information                                     |
| `--output <dir>`    | `-o`  | Specify output directory (default: Desktop)                  |
| `--name <prefix>`   | `-n`  | Use custom prefix instead of project name for the output     |

---

## 🧬 Requirements

- Flutter SDK ≥ 3.0.0  
- Dart SDK ≥ 2.19.0  
- Android SDK (for APK/AAB)  
- Xcode & CocoaPods (for iOS cleanup on macOS)

---

## 🔧 Setup Alias (Optional)

By default, use `dig_cli` in your terminal. If you prefer a shorter command, you can set up an alias:

```bash
# Add this to ~/.zshrc or ~/.bashrc or ~/.zshenv
alias myflutter="dig_cli"
```

- You can use any alias name you like. After adding the alias and restarting your terminal (or running `source ~/.zshrc`), you can use your chosen alias (e.g., `myflutter`) instead of `dig_cli` in all commands.

---

## 🔗 Links

- **Pub.dev**: https://pub.dev/packages/dig_cli  
- **GitHub**: https://github.com/Digvijaysinh2204/dig_cli  

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
---

## 🔄 Updating dig_cli

### From pub.dev (Stable)
To update to the latest stable version:
```bash
flutter pub global activate dig_cli
```

### From GitHub (Beta/Latest)
To update to the latest beta or development version:
```bash
flutter pub global activate --source git https://github.com/Digvijaysinh2204/dig_cli.git
```

After updating, you can check your version with:
```bash
dig --version
```

---

## 🖥️ Interactive Menu
If you run `dig_cli` (or your alias) with no arguments, you'll see an interactive menu:

```
=== DIG CLI MENU ===
1. Build APK
2. Build AAB
3. Clean Project
4. Show Version
5. Update to latest STABLE (if available)
6. Update to latest BETA (if available)
0. Exit
```

Select an option by entering its number. Update options will only appear if a newer version is available.

