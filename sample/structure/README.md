# 🏗️ Your "Proper" Flutter Project

Congratulations! You've successfully bootstrapped a high-performance, standardized Flutter project using **DIG CLI**. This template is built for scalability, robustness, and speed.

---

## 🔥 Key Highlights

| Concept | Implementation |
| :--- | :--- |
| **Architecture** | Scalable folder structure following GetX Best Practices. |
| **Notifications** | Pre-configured `flutter_local_notifications` for background isolates. |
| **Assets** | Type-safe, subfolder-based asset generation. |
| **Native** | Clean iOS `SceneDelegate` and automated Android Signing. |
| **Cleanup** | Robust handling for unconfigured Firebase (No crashes!). |

---

## 🚀 Finalizing Your Setup

### 1. Configure Firebase (Optional but Recommended)
This project includes Firebase skeletons. To enable Push Notifications:
1. **Configure**: Run `flutterfire configure`.
2. **Download Plists**: Add your generated `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to their respective native folders.
3. **Enable**: Go to `main.dart`, `AppBindings`, and `AppDelegate.swift` and uncomment the Firebase initialization lines marked with `TODO(Developer)`.

### 2. Manage Assets Like a Pro
Say goodbye to hardcoded strings!
1. **Add**: Drop your assets into `assets/`. Use subfolders to organize (e.g., `assets/icons/png/`).
2. **Sync Pubspec**: Ensure your new folders are added to `pubspec.yaml` under the `assets:` section.
3. **Generate**: Run `dg asset build` (or `dg asset watch`).
4. **Use**: Access them via generated classes:
   ```dart
   import 'package:your_app/generated/assets.dart';
   
   // Type-safe and auto-completed!
   Image.asset(IconsPng.logo);
   ```

### 3. Localization
The project is pre-configured for localization. Use `localization_key.dart` for type-safe strings.

---

## 🛠️ Essential Commands

- **Install Deps**: `flutter pub get`
- **Build Assets**: `dg asset build`
- **Run App**: `flutter run`
- **Release Build**: `dg create apk` (Android) or `dg create ipa` (iOS)

---

## 📂 Project Structure

```text
lib/
├── app/
│   ├── api/          # Network & API logic
│   ├── constants/    # App configurations & keys
│   ├── modules/      # Your screens (GetX pattern)
│   ├── routes/       # Centralized routing
│   ├── services/     # Long-running background services
│   ├── storage/      # Path provider & storage logic
│   └── widget/       # Shared UI components
├── generated/        # Auto-generated assets & localizations
└── firebase_options.dart # Firebase configuration
```

---
_Crafted with precision by **DIG CLI**._
