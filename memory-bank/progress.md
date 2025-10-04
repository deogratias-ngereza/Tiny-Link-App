# Progress — Tiny Link

Last updated: 2025-10-04

1) Current Status
- App implemented per requirements using Flutter + GetX + Hive.
- Grouping by Apps, each with multiple Links.
- CRUD for Apps and Links, search on links, professional M3 UI.
- Per-link WebView configuration:
  - JavaScript: native on/off.
  - Local storage: approximated disable via runtime JS shim (see notes).
  - Zoom: not universally controllable via webview_flutter; platform default behavior applies.
- First-run Accept screen implemented; acceptance persisted locally.
- AndroidX build issue resolved by replacing flutter_webview_plugin with webview_flutter.
- Device run command executed; app launches to Accept -> Apps -> Links -> Browser flow.

2) What Works Now
- Data and Storage
  - Hive boxes: apps_box, links_box, settings_box (acceptance flag).
  - Models: AppModel (typeId 0), LinkModel (typeId 1), WebViewConfig (typeId 3) with manual adapters.
  - Seed example apps (YouTube, Gmail, Docs).
- Navigation and State
  - GetX controllers: AppController (apps list CRUD), LinkController (links CRUD, search, lastUrl update).
  - Routes: /accept, /, /links, /edit-link, /browser with arguments validation.
  - Dynamic initialRoute: Accept if not accepted; else Apps.
- UI
  - AcceptPage: Accept & Continue (persists flag).
  - AppsPage: List, create, edit, delete apps; navigate to links.
  - LinksPage: List with search, create/edit/delete links; open in Browser.
  - EditLinkPage: Title, URL, color hex, per-link toggles (JS, Zoom, Local Storage).
  - BrowserPage (webview_flutter): loads link, back/forward/reload, persists lastUrl on change, applies JS toggle; JS shim used to approximate localStorage disabling.
- Tests
  - Placeholder unit test to keep CI green (widget tests TBD).

3) What’s Left To Build (High-Level)
- Optional enhancements:
  - Copy-to-clipboard and system share for link URL.
  - Color picker for nicer tag selection.
  - Import/export links (JSON).
  - QR generation for links (optional).
  - Widget tests for controllers and pages; golden tests for visuals.
  - CI workflow (format, analyze, test).
- WebView advanced controls:
  - If strict zoom/local-storage native toggles are required, consider migrating BrowserPage to flutter_inappwebview (supports options like supportZoom, javaScriptEnabled, domStorageEnabled) for closer parity with requested toggles.

4) Known Issues and Risks
- Plugin choice change:
  - flutter_webview_plugin caused Android Gradle failure (AndroidX namespace). Replaced with webview_flutter for AndroidX compatibility.
- Config parity:
  - Zoom toggle: not universally controllable in webview_flutter; depends on platform defaults.
  - Local storage toggle: approximated via JS shim when JS is enabled. No native setting exposed by plugin.
- iOS considerations:
  - For non-HTTPS URLs, ATS exceptions may be required in Info.plist if needed.
- Desktop/Web:
  - The requested mobile-style webview experience doesn't apply to Flutter Web/Desktop targets.

5) Decisions Log (Evolution)
- Replace flutter_webview_plugin with webview_flutter to fix AndroidX build failure.
- GetX for state/navigation across the app.
- Hive for local data and settings.
- Per-link JS on/off native; local storage disabled via JS shim when requested; zoom follows platform.

6) Milestones
- M0: Memory Bank initialized and checked in. [DONE]
- M1: Product vision and backlog defined; system patterns selected. [DONE (initial implementation)]
- M2: MVP architecture scaffolded (navigation, state mgmt, theming). [DONE]
- M3: First feature vertical implemented and tested. [DONE – Apps/Links/WebView]
- M4: Multi-platform build/release validation. [IN PROGRESS – Android run attempted, iOS TBD]

7) Next Actions Checklist
- [ ] Add copy/share actions for links in LinksPage.
- [ ] Add color picker widget for selecting tag colorHex.
- [ ] Write widget tests (controllers, page flows).
- [ ] Add CI workflow (format/analyze/test).
- [ ] iOS run validation; add ATS exceptions if needed.
- [ ] Optional: Evaluate flutter_inappwebview if strict native toggles (zoom/local storage) are a hard requirement.

8) Changelog
- 2025-10-04:
  - Implemented full app (Apps, Links, Edit Link, Browser) with GetX + Hive.
  - Replaced flutter_webview_plugin with webview_flutter due to AndroidX build error.
  - Device run executed; app launches per flow.
  - Updated Memory Bank (activeContext.md, progress.md).

9) References
- techContext.md: tooling, commands, platforms.
- systemPatterns.md: architecture and module layout.
- activeContext.md: current focus, decisions, and near-term plan.
