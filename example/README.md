# dig_cli Example

This directory contains examples of how to use the `dig_cli` tool.

## Installation

First, install the dig_cli tool globally:

```bash
flutter pub global activate dig_cli
```

## Usage Examples

### 1. Clean a Flutter Project

Navigate to any Flutter project and run:

```bash
dig clean
```

This will:
- Clean Flutter cache and build files
- Clean iOS workspace, Pods, and DerivedData
- Clean Android Gradle and build directories
- Reinstall dependencies

### 2. Build APK

In a Flutter project:

```bash
dig create build
```

This will:
- Build a release APK
- Name it with project name and timestamp
- Move it to your Desktop

### 3. Build App Bundle (AAB)

In a Flutter project:

```bash
dig create bundle
```

This will:
- Build a release AAB
- Name it with project name and timestamp
- Move it to your Desktop

## Example Output

```
🕒 Current date: Thursday, July 17, 2025, 10:43 AM IST
🚀 Flutter iOS + Android Project Cleaner
⏰ Started at 17-07-2025 10:43 AM IST
🗂 Current Directory: /path/to/your/project
📦 Pre-caching Flutter iOS artifacts...
🧹 Cleaning Flutter...
📦 Getting Dart packages...
🧼 iOS: Cleaning workspace, Pods, build, symlinks...
📥 Installing CocoaPods...
🧼 Android: Removing build and cache directories...
✅ All Clean! Flutter, iOS & Android project reset complete.
```

## File Naming Convention

Builds are automatically named with the following format:
- **APK**: `{project_name}-{dd-mm-yyyy}-{hh.mmAM}.apk`
- **AAB**: `{project_name}-{dd-mm-yyyy}-{hh.mmAM}.aab`

Example: `myapp-17-07-2025-10.43AM.apk` 