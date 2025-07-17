# dig_cli

A Flutter CLI tool for building APKs, AABs, and cleaning Flutter projects with date-time naming.

## Features

- 🚧 **Build APK**: Create release APKs with automatic date-time naming
- 📦 **Build AAB**: Create Android App Bundles with automatic date-time naming
- 🧹 **Clean Builds**: Comprehensive Flutter, iOS, and Android project cleanup
- 📱 **Desktop Integration**: Automatically moves builds to Desktop folder
- ⏰ **Timestamp Naming**: All builds include date and time in filename

## Installation

```bash
# Install globally
flutter pub global activate dig_cli

# Or install from source
git clone https://github.com/yourusername/dig_cli.git
cd dig_cli
flutter pub global activate --source path .
```

## Usage

### Build APK
```bash
dig create build
```
Creates a release APK with filename format: `projectname-dd-mm-yyyy-hh.mmAM.apk`

### Build App Bundle (AAB)
```bash
dig create bundle
```
Creates an Android App Bundle with filename format: `projectname-dd-mm-yyyy-hh.mmAM.aab`

### Clean Project
```bash
dig clear build
# or
dig clean
```
Performs comprehensive cleanup:
- Flutter cache and build files
- iOS workspace, Pods, and DerivedData
- Android Gradle and build directories
- Global Xcode DerivedData

## Examples

```bash
# Build APK and move to Desktop
dig create build
# Output: myapp-25-12-2024-02.30PM.apk

# Build AAB and move to Desktop  
dig create bundle
# Output: myapp-25-12-2024-02.30PM.aab

# Clean all build files
dig clean
# Output: Complete cleanup of Flutter, iOS & Android
```

## Requirements

- Flutter SDK
- Dart SDK
- For iOS builds: Xcode and CocoaPods
- For Android builds: Android SDK

## File Structure

Builds are automatically moved to your Desktop folder with the following naming convention:
- **APK**: `{project_name}-{dd-mm-yyyy}-{hh.mmAM}.apk`
- **AAB**: `{project_name}-{dd-mm-yyyy}-{hh.mmAM}.aab`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
# dig_cli
