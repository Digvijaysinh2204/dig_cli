# Changelog

All notable changes to this project will be documented in this file.

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