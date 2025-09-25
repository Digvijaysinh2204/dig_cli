# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 25-09-2025
### 🐛 Fixed
-   Fixed a execute issue

## [1.0.2] - 25-09-2025

### ✨ Added
-   **Create Project ZIP**: Added a new `zip` command and interactive menu option to create a clean ZIP archive of the project.
-   The ZIP functionality intelligently excludes files and folders based on the project's `.gitignore` file.
-   The ZIP filename is automatically timestamped (`ProjectName-YYYY-MM-DD-HH-MM.zip`).

### 🎨 Changed
-   **Revamped Interactive Menu**: The interactive menu has been redesigned with a beautiful, modern box-style UI with icons for better visual appeal.
-   **Smart Menu Logic**: The menu now checks if `lib/main.dart` exists. If not, it intelligently hides the "Build APK" and "Build AAB" options to prevent failed builds.
-   **Dynamic Version Display**: The tool's version is now read dynamically from `pubspec.yaml` and displayed in the menu, ensuring it's always accurate.
-   Menu numbering is now dynamic and corrects itself based on available options.

### 🐛 Fixed
-   Fixed a "Bad file descriptor" error during the ZIP creation process by switching to synchronous file operations.
-   Corrected menu alignment and numbering issues, especially when options were dynamically hidden.
