# Changelog

All notable changes to this project will be documented in this file.

## [1.4.0] - 2026-02-13

### Fixed
- **Template Widget Test**: Fixed `widget_test.dart` template to use `PROJECT_NAME` placeholder instead of hardcoded `structure`
- **Code Formatting**: Applied `dart format` to entire codebase for consistency
- **JKS Gitignore**: Confirmed `*.jks` files are properly ignored in template `.gitignore`

## [1.3.6] - 2026-02-13

### Fixed

- **Test File Imports**: Fixed `widget_test.dart` in generated projects to use correct package name instead of hardcoded `structure`
- **Import Replacement**: Updated `_updateDartImports` to process both `lib/` and `test/` directories

## [1.3.5] - 2026-02-13

### Fixed

- **Smart Path Resolution**: Implemented an aggressive search strategy for the project template, fixing "Template not found" errors when run globally.
- **Flexible Bundle IDs**: Updated regex to allow two-segment IDs (e.g., `com.sapphire`) and support mixed-case input.

## [1.3.3] - 2026-02-13

### Fixed

- **Smart Path Resolution**: Implemented an aggressive search strategy for the project template, fixing "Template not found" errors when run globally.
- **Flexible Bundle IDs**: Updated regex to allow two-segment IDs (e.g., `com.sapphire`) and support mixed-case input.

## [1.3.2] - 2026-02-13

### Fixed

- **Clean Analysis**: Fixed a lint warning in `create-project` command to ensure clean CI builds.

## [1.3.1] - 2026-02-13

### Fixed

- **Global Path Resolution**: Fixed a critical bug where the project template could not be found when the CLI was run as a global package.
- **Improved Prompts**: Added separate prompts for "Project Name" (slug/folder) and "App Display Name" during project creation.

## [1.3.0] - 2026-02-13

### Added

- **Proper Project Creation**: New `dg create-project` command to bootstrap highly structured Flutter projects.
- **Automated JKS Integration**: Creates unique JKS keystores and configures signing automatically during project setup.
- **Comprehensive Rebranding**: Massive improvements to renaming logic for Project Name, App Name, and Bundle IDs across all files.
- **Firebase Skeletons**: Pre-configured Firebase files that guide the user to run `flutterfire configure`.
- **Directory Restructuring**: Improved Android package directory moving and empty directory cleanup.
- **Dotfile Support**: CLI now correctly handles and copies `.gitignore` and `.env` files.

### Changed

- **Credits**: Updated all attribution to "Digvijaysinh Chauhan" with links to pub.dev packages.
- **Robustness**: Improved template stability with `flutter analyze` verified code and default `.env` values.
- **UI/UX**: Clearer terminal feedback and Firebase setup reminders.

## [1.2.8] - 2026-01-12

### Added

- **iOS Build**: New option to build iOS IPA directly to Desktop (macOS only).
- **SHA Keys**: Get SHA1 and SHA256 keys using `./gradlew signingReport` (shows both debug & release keys).
- **Pub Cache Repair**: Quick option to run `flutter pub cache repair`.

### Changed

- **SHA Keys**: Automatically navigates to android directory, runs command, and restores original directory.
- **Menu Improvements**: iOS build option only visible on macOS.

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
