# Changelog

All notable changes to this project will be documented in this file.

## [1.1.3] - 2025-09-26

### ✨ Added
-   **CI/CD Workflows**:
    -   Added a `validate.yml` workflow to automatically run `dart format` and `dart analyze` on every push and pull request to ensure code quality.
    -   Added a `release.yml` workflow to automatically test, build, and publish the package to both GitHub Releases and pub.dev when a new version tag is pushed.
-   **Community Health Files**: Added professional repository files like `BUG_REPORT.md`, `PULL_REQUEST_TEMPLATE.md`, and `dependabot.yml` for automated dependency updates.

### 🐛 Fixed
-   **Dynamic Versioning**: Fixed a critical bug where the CLI would show `v0.0.0` when run as a global executable. The version is now correctly read from the package's `pubspec.yaml` in all contexts.
-   **Menu Selection Logic**: Corrected an issue where menu option selection would fail if some options (like build commands) were dynamically hidden.
