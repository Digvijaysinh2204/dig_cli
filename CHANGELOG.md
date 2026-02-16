# Changelog

All notable changes to this project will be documented in this file.

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
