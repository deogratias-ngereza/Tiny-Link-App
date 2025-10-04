# Tech Context — Tiny Link

Last updated: 2025-10-04

1. Stack Overview
- Language: Dart (^3.9.2)
- Framework: Flutter
- App Type: Multi-platform (Android, iOS, Web, Windows, macOS, Linux)
- Current State: Fresh Flutter template app (counter) using Material widgets and setState.

2. Dependencies (from pubspec.yaml)
- Runtime:
  - flutter (SDK)
  - cupertino_icons: ^1.0.8
- Dev:
  - flutter_test (SDK)
  - flutter_lints: ^5.0.0

3. Tooling and Conventions
- Linting:
  - analysis_options.yaml includes package:flutter_lints/flutter.yaml (recommended Flutter lints).
  - No custom lint overrides yet (e.g., prefer_single_quotes is commented out).
- Formatting:
  - Use dart format (default). Recommended command: dart format .
- Static Analysis:
  - flutter analyze
- Testing:
  - Unit/Widget tests via flutter test
  - Default scaffold test present at test/widget_test.dart
- IDE:
  - Visual Studio Code
  - Suggested extensions: Dart, Flutter (not enforced by repo)
- Versioning:
  - Semantic version in pubspec.yaml: 1.0.0+1 (Android versionCode/iOS CFBundleVersion mapping applies)
- Git:
  - .gitignore present (standard Flutter ignores). No hooks configured in repo.

4. Platforms and Build Targets
- Platform folders present:
  - android/, ios/, web/, windows/, macos/, linux/
- Common Commands:
  - Retrieve deps: flutter pub get
  - Analyze: flutter analyze
  - Format: dart format .
  - Test: flutter test
  - Run (examples):
    - Android: flutter run -d emulator-5554 (example device id)
    - iOS: flutter run -d <simulator-id> (macOS required)
    - Web (Chrome): flutter run -d chrome
    - Windows: flutter run -d windows
    - macOS: flutter run -d macos
    - Linux: flutter run -d linux
  - Build (examples):
    - Android APK: flutter build apk --release
    - iOS: flutter build ios --release (macOS/Xcode required)
    - Web: flutter build web --release
    - Windows: flutter build windows --release
    - macOS: flutter build macos --release
    - Linux: flutter build linux --release

5. App Entry and Structure (current)
- Entry point: lib/main.dart
  - MaterialApp root with seed ColorScheme (deepPurple).
  - Home: MyHomePage (StatefulWidget) with setState counter increment.
- Navigation:
  - None yet (single-screen).
- State Management:
  - setState only (no additional state libraries).

6. CI/CD (not configured)
- No CI workflows are present in the repository.
- Recommendation (future):
  - Add CI to run: flutter pub get, dart format --output=none --set-exit-if-changed ., flutter analyze, flutter test.
  - Optional: cache pub dependencies to speed up builds.

7. Security/Secrets
- No secrets in repo (as expected).
- Policy:
  - Do not commit API keys/secrets.
  - Use environment-specific configuration and secret managers when backend integration is introduced.

8. Theming/UX
- Material theming via ColorScheme.fromSeed(seedColor: Colors.deepPurple).
- No custom fonts/assets configured in pubspec.yaml.

9. Performance and Footprint
- Default debug performance for Flutter template.
- No heavy dependencies or native integrations currently.

10. Technical Risks and Constraints
- Multi-platform build specifics may require per-OS setup (Xcode for iOS/macOS, SDK/NDK for Android, toolchains for desktop).
- Product direction unknown; choice of state management and navigation is pending.

11. Commands Quick Reference
- Setup:
  - flutter pub get
- Dev:
  - flutter run -d chrome
  - flutter analyze
  - dart format .
  - flutter test
- Build:
  - flutter build web --release
  - flutter build apk --release

12. Next Steps (Tech)
- Decide state management approach (Provider/Riverpod/BLoC/etc.).
- Choose navigation strategy (Navigator 2.0/go_router/auto_route).
- Establish app module structure under lib/ (e.g., core, features, shared).
- Add CI workflow for format, analyze, test.
- Define environment/config pattern (dev/prod) and secrets handling (if backend).
