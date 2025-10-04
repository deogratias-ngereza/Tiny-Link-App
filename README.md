# Tiny Link

Tiny Link is a cross‑platform Flutter app to organize links by app/group, open them in an embedded webview with per‑link configuration, and navigate smoothly with professional UX patterns.

- Multi-platform targets: Android, iOS, Web, Windows, macOS, Linux
- State & navigation: GetX
- Local database: Hive
- Browser: webview_flutter with per‑link settings
- Theming: Material 3 with reactive seed color (via Settings)
- Tabs: In‑memory session tabs with switch/close/close‑all
- External links (Privacy, Terms, GitHub, About) defined in one constants file

## Table of Contents

- Features
- Screens
- Architecture and Folders
- Models and Persistence
- Per‑Link WebView Configuration
- Professional Navigation and Tabs
- Theming and Settings
- External Links (constants)
- Setup and Run
- App Icon (Launcher Icons)
- Android Notes (HTTP/Cleartext)
- Limitations and Tradeoffs
- Roadmap
- Troubleshooting

## Features

- Group links by App (e.g., YouTube, Gmail, Docs)
- Link CRUD with search
- Per‑link configuration for webview:
  - JavaScript on/off (native support)
  - Local storage enable/disable (shimmed)
  - Initial zoom (50–200%) best‑effort via JS/meta viewport
  - Start in fullscreen
  - Fullscreen Home FAB position: 9 placements (top/center/bottom × left/center/right)
- Embedded browser:
  - Title bar & system bars color match link color
  - High‑contrast Back/Forward buttons
  - Unified actions menu (Home, start URL, reload, tabs)
  - Blocks system back pop; uses in‑page back navigation
- Settings:
  - Change app-wide theme seed color (reactive)
  - External links section (Privacy Policy, Terms & Conditions, GitHub Repo, About Us)
- Tabs:
  - View current tabs, switch to a tab, close individual tabs, close all

## Screens

- Accept (first‑run): “Accept & Continue” (persisted)
- Apps (home): List, create, edit, delete groups; open a group’s links; Settings icon
- Links: Per‑app list with search; open/edit/delete links
- Edit Link: Title, URL, color hex, and per‑link webview settings (JS, storage, zoom, fullscreen, FAB position)
- Browser: Embedded webview page with actions and navigation
- Settings: Change theme color; open external links

## Architecture and Folders

- lib/
  - core/
    - constants/
      - links.dart (centralized external URLs)
  - controllers/
    - app_controller.dart (Apps CRUD)
    - link_controller.dart (Links CRUD/search/lastUrl)
    - tabs_controller.dart (in‑memory opened tabs)
    - theme_controller.dart (reactive theming)
  - data/
    - hive_service.dart (Hive init, boxes, adapters, settings)
  - models/
    - app_model.dart (Hive typeId 0)
    - link_model.dart (Hive typeId 1)
    - webview_config.dart (Hive typeId 3)
  - routes/
    - app_pages.dart (GetX routes)
  - ui/
    - accept/accept_page.dart
    - apps/apps_page.dart
    - links/links_page.dart, edit_link_page.dart
    - browser/browser_page.dart
    - settings/settings_page.dart
  - main.dart (bootstrap, reactive theme)

## Models and Persistence

- AppModel (typeId 0)
  - id, name, colorHex
- LinkModel (typeId 1)
  - id, appId, title, url, colorHex, lastUrl, config, createdAt, updatedAt
- WebViewConfig (typeId 3)
  - javascriptEnabled (bool)
  - zoomEnabled (bool)
  - localStorageEnabled (bool)
  - initialZoom (double, default 1.0)
  - startFullscreen (bool)
  - homeIconPosition (String: topLeft/topCenter/topRight/centerLeft/center/centerRight/bottomLeft/bottomCenter/bottomRight)

Hive:
- Boxes: apps_box, links_box, settings_box
- Manual adapters (no code gen)

## Per‑Link WebView Configuration

- JavaScript: WebViewController.setJavaScriptMode
- Local Storage: Approximated when disabling via injected JS shim (window.localStorage overridden)
- Initial Zoom: Injected meta viewport + CSS zoom (best effort; requires JS)
- Fullscreen: Hides AppBar and bottom bar; Home FAB shown
- FAB Position: 9 placements via `homeIconPosition`

## Professional Navigation and Tabs

- System back is intercepted in BrowserPage; if webview can go back, it navigates in history; otherwise, page pop is blocked—use Home/action menu.
- Actions menu (available both fullscreen and non‑fullscreen):
  - Go Home (Apps)
  - Go to Start URL (root of the link)
  - Reload
  - Tabs (list, switch, close, close all)
- TabsController tracks opened tabs during the session (non‑persistent by default)

## Theming and Settings

- ThemeController exposes reactive ThemeData from a seed color
- Settings > App Theme:
  - Quick palette (dark + bright tones) and hex input (#RRGGBB or #AARRGGBB)
  - Changes persist in settings_box and apply instantly across app

## External Links (constants)

- Edit `lib/core/constants/links.dart` to change:
  - privacyPolicy
  - termsAndConditions
  - githubRepo
  - aboutUs
- Settings > Legal & About opens these in the external browser (url_launcher)

## Setup and Run

Prerequisites:
- Flutter SDK (stable)
- Device/emulator/simulator

Install dependencies:
```
flutter pub get
```

Run (example Android device):
```
flutter run -d <device-id>
```

Optional analysis and tests:
```
flutter analyze
flutter test
```

## App Icon (Launcher Icons)

- Add your icon at: `assets/icon/app_icon.png`
- Configure in `pubspec.yaml` under `flutter_launcher_icons`
- Generate:
```
flutter pub get
dart run flutter_launcher_icons
```

## Android Notes (HTTP/Cleartext)

To support HTTP (cleartext) URLs:
- Manifest sets `android:usesCleartextTraffic="true"`
- Network security config at `android/app/src/main/res/xml/network_security_config.xml`
- For production, consider restricting to specific domains

## Limitations and Tradeoffs

- Zoom: webview_flutter does not expose a universal native zoom toggle; initial zoom is best‑effort via JS/meta.
- Local Storage: disable is approximated by a JS shim; other storage APIs (e.g., IndexedDB) are not blocked.
- Tabs: In‑memory only; not persisted (can be extended to Hive if needed).

## Roadmap

- Persist tabs session to settings_box
- Color picker for link tags (friendlier than hex)
- Import/export links (JSON)
- Copy/share actions on links
- Optional: migrate BrowserPage to flutter_inappwebview for native zoom/storage options
- CI workflow (format/analyze/test)

## Troubleshooting

ERR_CLEARTEXT_NOT_PERMITTED:
- Using HTTP links requires cleartext enabled. The project includes:
  - `usesCleartextTraffic="true"`
  - `network_security_config.xml` with `cleartextTrafficPermitted="true"`
- For production, restrict to specific domains in the network security config.

No back navigation in Browser:
- System back is intentionally blocked. Use:
  - In‑page Back/Forward buttons
  - Actions menu: Home, Start URL, Reload
  - Tabs menu to switch or close

Theme not updating:
- Confirm Settings > App Theme > Apply is used
- Check `settings_box` has `themeColor` updated

## License

MIT (placeholder). Update with your license as needed.
