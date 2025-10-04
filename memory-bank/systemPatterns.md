# System Patterns — Tiny Link

Last updated: 2025-10-04

1. Architecture Overview
- Current app state: Single-screen Flutter template using MaterialApp + StatefulWidget with setState.
- Target style: Feature-first modular structure with lightweight Clean Architecture boundaries as complexity grows.
- Principles:
  - Separation of concerns (UI, domain, data).
  - Testability first (pure Dart where possible, thin platform/UI).
  - Incremental adoption (start simple; add DI, routing libs, persistence as needed).

2. Proposed Module Structure (incremental)
- lib/
  - core/
    - config/ (env, constants)
    - error/ (failure types, exceptions)
    - utils/ (formatters, validators)
  - shared/
    - widgets/ (reusable UI components)
    - theming/ (theme, colors, typography)
  - features/
    - links/ (example MVP feature)
      - presentation/ (pages, widgets, controllers/state)
      - domain/ (entities, value objects, use cases)
      - data/ (repositories, data sources: local/remote)
- notes:
  - Start with presentation-only for links (simple local list) and layer-in domain/data when needed.

3. State Management
- Current: setState
- Candidates:
  - Provider/ChangeNotifier (simple, built-in patterns)
  - Riverpod (testable, DI-friendly)
  - BLoC/Cubit (event/state explicitness)
- Recommendation:
  - Start with simple Provider or Riverpod for MVP; revisit if complexity grows.

4. Navigation and Routing
- Current: Single route
- Candidates:
  - Navigator 2.0 (manual)
  - go_router (declarative, URL-based, deep links)
  - auto_route (code generation)
- Recommendation:
  - go_router for multi-page MVP and web-friendly URLs.

5. Data and Storage
- MVP options:
  - Local-only: SharedPreferences (key-value), Hive (NoSQL boxes), or sqflite (relational).
  - Remote-backed: REST/GraphQL API with auth and analytics capabilities.
- Repository Pattern:
  - Domain: abstract LinkRepository
  - Data: LocalLinkDataSource, RemoteLinkDataSource
  - Composition: repository decides source-of-truth and sync rules.
- Entities/VOs (example):
  - Link { id, originalUrl, shortUrl?, title?, createdAt, tags[]? }
  - Url (validated), ShortCode (validated)

6. Networking (if remote)
- HTTP client: http or dio
- Concerns:
  - Retry/backoff
  - Connectivity awareness
  - Request/response models + mappers
  - Auth strategy (TBD)

7. Error Handling
- Failures vs Exceptions:
  - Wrap infrastructure exceptions into domain Failures (e.g., NetworkFailure, ValidationFailure).
- UI surfacing:
  - Non-blocking toasts/snackbars for minor issues, dialogs for destructive actions.
- Validation:
  - URL validation at input and VO level.

8. Logging and Telemetry
- App logs:
  - Simple debug prints guarded or use a logger package.
- Analytics (TBD and privacy-first):
  - Feature flags to disable/enable.
  - Respect user consent where required.

9. Theming and Design System
- Start with ColorScheme.fromSeed; centralize in shared/theming/.
- Define spacing, typography scale, and component themes for consistency.
- Dark mode support via ThemeMode.system.

10. Internationalization (i18n) and Accessibility (a11y)
- i18n:
  - Add Flutter localization scaffolding if content grows.
- a11y:
  - Proper semantics, contrast, tappable areas, and screen reader labels.

11. Performance
- UI:
  - Avoid unnecessary rebuilds (selectors, const widgets).
- Data:
  - Batch operations and lazy loading for large lists.
- Startup:
  - Defer heavy init, show skeletons/placeholders.

12. Testing Strategy
- Unit (domain, utilities)
- Widget (presentation)
- Integration (repository + data sources)
- Golden tests for key widgets (optional)
- Suggested commands:
  - flutter test
  - Consider coverage integration in CI.

13. Build/Release and Environments
- Flavors or config per environment (dev/stage/prod) via core/config/.
- Platform specifics (Android signing, iOS provisioning) handled when release-ready.

14. Security and Privacy
- No secrets in repo; use platform keystores/secret managers.
- Link data privacy: document lifecycle and storage rules.
- If analytics: clear disclosure and opt-in/out.

15. Risks and TBD Decisions
- Product ambiguity blocks data model and backend choice.
- Pick state management: Provider vs Riverpod vs BLoC.
- Choose router (leaning go_router).
- Storage choice for MVP (Hive vs sqflite vs SharedPreferences).
- Backend presence and minimal API spec.

16. Example Flow (MVP, local-only)
- Create Link:
  - UI validates input URL -> domain VO -> repository.saveLocal -> show in list -> copy/share.
- List Links:
  - repository.listLocal -> presentation state -> list with actions.
- Optional QR:
  - Generate QR from original/short URL (if package added).

17. ASCII Sketch

   [UI Widgets/Pages]
          |
      [State/Controller]  <— Provider/Riverpod/BLoC
          |
       [Use Cases]
          |
      [Repositories]
       /         \
[Local DS]     [Remote DS]
 (Hive/SQL)     (HTTP/TBD)
