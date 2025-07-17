# 🛠️ dig_cli

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

---

## ⚙️ Usage

### Build APK

```bash
dig create build
```

Output (Desktop): `yourproject-25-12-2025-02.30PM.apk`

### Build AAB

```bash
dig create bundle
```

Output (Desktop): `yourproject-25-12-2025-02.30PM.aab`

### Clean Project

```bash
dig clean
```

Or:

```bash
dig clear build
```

This cleans:
- Flutter build and cache  
- Android `.gradle`, `.cxx`, build folders  
- iOS workspace, Pods, build folder, and DerivedData (macOS only)

---

## 🧪 Examples

```bash
dig create build --name MyApp
# Builds MyApp-DD-MM-YYYY-HH.MMAM.apk to Desktop

dig create bundle -o ./output
# Builds AAB to ./output folder

dig clean
# Fully cleans Android and iOS artifacts
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

To shorten the command, you can create a terminal alias:

```bash
# Add this to ~/.zshrc or ~/.bashrc
alias dig="dig_cli"
```

Then restart your terminal or run `source ~/.zshrc`.

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