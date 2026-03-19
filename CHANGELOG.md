# Changelog

All notable changes to this project will be documented in this file.

## [1.7.1-dev.1] - 2026-03-19

### Added
- **Premium Interactive Menu**: Completely redesigned startup screen with ASCII Logo, vibrant colors, and arrow-key navigation.
- **Firebase Command Suite**: New `dg firebase` command with `login`, `logout`, `configure`, and `check` subcommands.
- **Firebase Auto-Installer**: Automatic detection and installation of `firebase-tools` and `flutterfire_cli`.
- **Firebase Account Display**: Interactive menu now shows the currently logged-in Firebase email.
- **Pubspec Automation**: `dg asset build` now automatically registers new asset folders and `.env` files in `pubspec.yaml`.

### Fixed
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
