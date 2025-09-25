Markdown

# 🛠️ dig_cli

A powerful Flutter CLI tool to automate building, cleaning, and packaging your projects.

[![pub package](https://img.shields.io/pub/v/dig_cli.svg)](https://pub.dev/packages/dig_cli)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**dig_cli** is a robust command-line interface designed to streamline your Flutter workflow. It automates common tasks such as creating timestamped APKs/AABs, performing deep system-specific cleaning, and packaging your project into a clean ZIP archive that respects `.gitignore` rules.

Featuring a beautiful and smart interactive menu, `dig_cli` provides a user-friendly experience for managing your builds, complete with dynamic version checking from `pubspec.yaml` and update notifications.

---

## 🚀 Features

-   **Interactive Menu**: A beautiful, smart menu for easy navigation if you run the tool without commands.
-   **Build APK/AAB**: Generate release builds with automatic `ProjectName-YYYY-MM-DD-HH-MM` naming.
-   **Deep Clean**: A powerful clean command that removes caches for Flutter, Gradle, Xcode, and Pods on macOS, Windows, and Linux.
-   **Create Clean ZIP**: Package your project into a ZIP file, automatically excluding files listed in `.gitignore`.
-   **Smart Menu Logic**: The menu intelligently hides build options if it detects you're not in a buildable Flutter project (by checking for `lib/main.dart`).
-   **Dynamic Versioning**: The tool's version is read dynamically from `pubspec.yaml`.
-   **Auto Update Check**: The interactive menu automatically checks for new versions on pub.dev and provides an update option.

---

## 📦 Installation

```bash
dart pub global activate dig_cli
After installation, you can use dig as the command.

⚙️ Usage
Interactive Menu (Recommended)
Simply run the command without any arguments to launch the beautiful interactive menu.

Bash

dig
Direct Commands
Build APK: dig create apk

Build AAB: dig create bundle

Clean Project: dig clean

Create ZIP: dig zip

Show Version: dig --version

🖥️ Interactive Menu
Running dig without arguments launches the menu:

╔════════════════════════════════════════╗
║          DIG CLI TOOL v1.1.0           ║
╠════════════════════════════════════════╣
║  1. 🚀 Build APK                       ║
║  2. 📦 Build AAB                       ║
║  3. 🧹 Clean Project                   ║
║  4. 🤐 Create Project ZIP              ║
║  5. ✨ Update to v1.2.0                  ║
║  0. 🚪 Exit                            ║
╚════════════════════════════════════════╝
Note: Build and update options are shown dynamically based on project status and version availability.

🧪 Examples
Bash

# Launch the interactive menu for guided actions
dig

# Build an APK with a custom name and output to the Downloads folder
dig create apk --name MyApp --output ~/Downloads

# Deep clean the project's build artifacts
dig clean

# Create a clean, shareable ZIP file of the project on the Desktop
dig zip
⚙️ Options
Option	Alias	Description
--help	-h	Show help (when used with a command)
--version	-v	Show the tool's version
--output <dir>	-o	Specify output directory (default: Desktop)
--name <prefix>	-n	Custom name prefix for build/zip output file

Export to Sheets
🔧 Using a Custom Alias (Optional)
If you prefer a different command name instead of dig, you can set up an alias in your shell's configuration file (e.g., ~/.zshrc, ~/.bashrc, or PowerShell profile).

macOS / Linux:

Bash

alias mytool="dig"
PowerShell:

PowerShell

Set-Alias mytool dig
After adding the alias, restart your terminal or source the profile file. You can then use mytool instead of dig.

🔗 Links
Pub.dev: https://pub.dev/packages/dig_cli

GitHub: https://github.com/Digvijaysinh2204/dig_cli

🤝 Contributing
Fork this repo

Create a feature branch (git checkout -b feature/my-feature)

Commit your changes (git commit -m 'feat: add something')

Push to the branch (git push origin feature/my-feature)

Open a Pull Request

📝 License
Licensed under the MIT License.