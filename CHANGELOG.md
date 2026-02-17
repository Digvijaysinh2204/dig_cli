# Changelog

All notable changes to this project will be documented in this file.

## [1.5.9] - 2026-02-17

### Enhanced

- **Asset Generation**: Major improvements to the `asset` command
  - **Multi-file Structure**: Assets now organized into separate files by category and type
    - `IconsPng`, `IconsSvg`, `ImagesPng`, `ImagesJpg`, `FontsTtf`, `FontsOtf`
    - Category export files: `icons.dart`, `images.dart`, `fonts.dart`
    - Single main export: `assets.dart` for easy imports
  - **Skip/Exclude Feature**: New `skip` configuration in `dig.yaml`
    - Skip entire folders: `skip: icons`
    - Skip specific subfolders: `skip: icons/svg`
    - Skip multiple folders with list syntax
  - **Improved Naming**: Better camelCase conversion handles any file name format
    - `semi-bold.ttf` → `semiBold`
    - `SOmeIcon.svg` → `someIcon`
    - `ic_back.svg` → `icBack`
  - **Better Organization**: Default output changed to `lib/generated` (configurable)
  - **Enhanced Output**: Shows all generated files in tree structure

### Fixed

- **Version Check**: Fixed issue where update prompt showed even when already on latest version
  - Now correctly syncs `kDigCliVersion` with `pubspec.yaml`
- **Analysis Options**: Added `flutter_lints` to sample project dependencies to fix warnings

## [1.5.8] - 2026-02-16

### Added

- **Asset Generation**: New `asset` command to auto-generate type-safe Dart constants from assets
  - `dg asset build` - Generate asset constants once
  - `dg asset watch` - Watch for asset changes and auto-regenerate
  - Configuration via `dig.yaml` (similar to `l10n.yaml`)
  - Separate classes for each asset type: `IconAssetSVG`, `ImageAssetPNG`, `ImageAssetJPG`, `ImageAssetSVG`
  - Auto-converts file names to camelCase (`ic_back.svg` → `IconAssetSVG.icBack`)
  - Skips empty classes (only generates classes with actual files)
  - Comprehensive warnings and documentation in generated files

## [1.5.7] - 2026-02-16

### Added

- **Create Module**: New `create-module` command to automate GetX scaffolding with robust PascalCase naming and auto-registration in routes and exports.
- **Dashboard UI**: Redesigned the project template's `MainView` into a professional system status dashboard.
- **Centralized Exports**: Introduced `lib/app/module/module_export.dart` to streamline module imports across the project.

### Fixed

- **Firebase Robustness**: Wrapped Firebase initialization in `try-catch` blocks within the template. The app now survives and runs gracefully even if Firebase is not configured.
- **Analysis Cleanup**: Resolved multiple unnecessary imports and analysis warnings in the project template.
- **Documentation**: Updated the template's `README.md` with clearer Firebase setup guides and a "Run without Firebase" section.

## [1.5.5] - 2026-02-16

### Fixed

- **Firebase Initialization**: Added guards to `Firebase.initializeApp` in the project template to prevent `[core/duplicate-app]` errors during startup or background message handling.

## [1.5.4] - 2026-02-16

### Changed

- **Formatting**: Performed a full project-wide code formatting for both the CLI and the project template.
- **XML Cleanliness**: Optimized `AndroidManifest.xml` and other Android XML resources for better readability and standard indentation.

## [1.5.3] - 2026-02-16

### Fixed

- **Update Logic**: Fixed an issue where the CLI would prompt to update even if the installed version matched the latest version. Now strictly checks for newer versions.

## [1.5.2] - 2026-02-16

### Fixed

- **Version Info**: The CLI now correctly displays both the **Installed** version and the **Latest** available version from pub.dev. It also shows the **Executable Path**, so you know exactly which binary is running (local vs global).
- **Package Name**: Fixed an issue where Kotlin/Java files retained the old package name (e.g., `com.example.structure`) after rebranding.
- **Interactive Menu**: Code cleanup and import fixes for better stability.

## [1.5.1] - 2026-02-16

### Fixed

- **Cleanup**: Fixed an issue where default Flutter assets (like specific Android launcher icons and Kotlin files) were persisting after project creation.
- **Assets**: Ensures `android/app/src/main/res` and `ios/Runner/Assets.xcassets` are fully replaced by the template, preventing duplicate resources.

## [1.5.0] - 2026-02-16

### Added

- **Project Structure**: Introduced a new "Flutter Create First" approach for cleaner, compliant projects.
- **Dynamic App Name**: CLI now auto-injects your project name into `AppConstant` during creation.
- **Dependencies**: Added `package_info_plus` to the template for runtime metadata access.
- **Download Manager**: New refactored `DownloadManager` service for handling file downloads.
- **Localization**: Added dynamic localization support for download notifications.
- **Notification Service**: Enhanced notification handling with improved reliability.
- **JKS Cleanup**: Automatically removes `sample.jks` and generates a project-specific keystore.
- **Secure API Key**: Generates a secure API key in `.env` during project creation.
- **Improved README**: Generates a premium `README.md` with project details.

### Changed

- **Config**: Updated iOS icon to a simplified 1024x1024 source.
- **Resources**: Synced Android `res` styles and colors, added notification icon.
- **Refactoring**: Extensive code cleanup and formatting across the CLI and template.
- **Documentation**: Updated walkthroughs and task tracking.

### Fixed

- **Download Manager**: Refactored to a proper `GetxService` (removed singleton instance).
- **Service Access**: Fixed dependency injection issues in `DownloadManager`.
- **Initialization**: `DownloadManager` is now properly initialized in `InitialBindings`.

## [1.2.7] - 2026-01-05

### Fixed

- **CI/CD Workflow**: Improved auto-format push logic with `git pull --rebase` to prevent "rejected (non-fast-forward)" errors when multiple workflows run in parallel.

## [1.2.6] - 2026-01-05

### Fixed

- **CI/CD Workflow**: Updated `validate.yml` to support auto-formatting and faster Dart setup. Sync'd logic with `publish.yml`.

## [1.2.5] - 2026-01-05

### Fixed

- **CI/CD Workflow**: Fixed "detached HEAD" error when pushing auto-formatted code back to the repository.

## [1.2.4] - 2026-01-05

### Added

- **Performance**: Added caching to project root discovery for faster command execution.
- **UX**: Professional loading spinners added to the interactive menu for update checks.

### Changed

- **Workflow Optimization**: Parallelized publishing and binary builds. Pub.dev release is now significantly faster.

## [1.2.3] - 2026-01-05

### Changed

- **CI/CD Workflow**: Auto-formats code before analysis instead of rejecting push.
- **Faster Builds**: Switched from Flutter to Dart SDK only (lighter weight).

## [1.2.2] - 2026-01-05

### Fixed

- **Bundle ID Update (Android)**: Added support for Kotlin DSL (`build.gradle.kts`) and various `applicationId` formats.
- **Bundle ID Update (iOS)**: Improved regex to handle quoted and unquoted bundle IDs in `project.pbxproj`.

## [1.2.1] - 2026-01-05

### Fixed

- **Command Conflict**: Renamed the primary executable from `dig` to `dg` to avoid conflicts with the system `dig` (DNS lookup) utility.
- **Code Validation**: Fixed formatting and analysis issues as per CI requirements.

## [1.2.0] - 2026-01-05

### Added

- **Smart Rename Feature**: Full support for renaming apps across Android, iOS, macOS, Windows, Linux, and Web.
- **Android Restructuring**: Automatically moves source files to match the new bundle ID and updates package declarations.

### Changed

- **Modular Architecture**: Complete refactor to use `CommandRunner` for better maintainability.
- **Alias Friendly**: Log messages are now generic and work perfectly with custom aliases like `df`.
- **Improved Build Logic**: Build options are now conditionally shown in the interactive menu.
- **Optimized CI/CD**: True cross-platform binary builds (Linux, Windows, macOS) and faster analysis.

## [1.1.6] - 2025-09-26

- Release
