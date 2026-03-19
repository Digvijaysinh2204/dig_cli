# Changelog

All notable changes to this project will be documented in this file.

## [1.7.1] - 2026-03-19

### Added
- **Categorized Developer Dashboard**: The interactive menu is now organized into a clean 15-item list across 6 logical sections: **BUILD & RELEASE**, **CLEAN & FIX**, **SIGNING & KEYS**, **CONFIGURATION**, **PROJECT MANAGEMENT**, and **UTILITIES**.
- **Enhanced Author Branding**: Prominent "**Made with ❤️ by Digvijaysinh Chauhan**" branding added to the main dashboard and version command for a premium, personal touch.
- **Fast Clean (Option 4)**: New dedicated option for a simple `flutter clean` to quickly wipe local build artifacts.
- **Full Project Reset (Option 5)**: Thorough cleanup command that runs `flutter clean`, `pub get`, and `pod install` (on Mac), with an optional "Nuclear" global cache wipe.
- **One-click Update (Option 15)**: New helper in the UTILITIES section to check for updates on pub.dev and automatically run `dart pub global activate` if a newer version is available.
- **Firebase Command Suite**: New `dg firebase` command with `login`, `logout`, `configure`, and `check` subcommands.
- **Firebase Auto-Installer**: Automatic detection and installation of `firebase-tools` and `flutterfire_cli`.
- **Hash Key Generation**: New option to generate base64-encoded SHA1 hash keys for Android (required for Facebook/Google Login).
- **Firebase Account Display**: Interactive menu now shows the currently logged-in Firebase email in the sub-menu header, with dynamic Login/Logout options.
- **Pubspec Automation**: `dg asset build` now automatically registers new asset folders and `.env` files in `pubspec.yaml`.

### Fixed
- **Ultra-Robust Firebase Detection**: The CLI now reads the official Firebase config file directly, ensuring 100% accurate and instantaneous login status detection.
- **Smart iOS Cleanup**: `Full Project Reset` now explicitly checks for a `Podfile` before attempting CocoaPods operations, ensuring compatibility with SPM-only projects.
- **Cross-Platform Watching**: Switched to `package:watcher` for reliable asset watching on Ubuntu, Windows, and macOS.
- **JKS Portability**: `create-jks` now uses relative paths for `storeFile` in `key.properties`.

## [1.7.0] - 2026-02-25

### Initial Release

- **Smart Scaffolding**: Bootstrap a "Proper" Flutter Project with dynamic app name injection, pre-configured GetX architecture, and best practices.
- **UIScene & SceneDelegate**: Full support for the modern iOS `UIScene` lifecycle by default.
- **Firebase Robustness**: 100% crash-proof initial launch with pre-configured, commented-out Firebase initializers for easy setup.
- **Asset Generation**: Subfolder-based, type-safe asset constants generation with `dg asset build/watch`.
- **Dependency Management**: Native Swift Package Manager (SPM) integration for iOS, eliminating CocoaPods friction.
- **Module Creator**: Automated GetX scaffolding (`View`, `Controller`, `Binding`) with auto-routing.
- **Deep Rename**: One-command smart renaming for Android, iOS, macOS, Windows, Linux, and Web.
- **Security**: Automatic JKS generation and secure `.env` API key injection.
- **Deep Clean**: A "nuclear" clean command that wipes caches across all platforms.
- **Notification Services**: Pre-integrated, align with official best practices, and controllable via bindings.
- **Documentation**: Professional, "wowed" `README.md` and comprehensive asset generation guides.
