# Project Brief — Tiny Link

Last updated: 2025-10-04

1. Project Overview
- Name: Tiny Link
- Type: Flutter application (multi-platform: Android, iOS, Web, Windows, macOS, Linux)
- Current State: Fresh Flutter template (counter app) scaffold present; no domain features implemented yet.
- Purpose: Establish a durable Memory Bank that persists project intent and progress across sessions. Product vision and feature set are currently TBD and will be refined.

2. Goals
- Immediate
  - Initialize Memory Bank core documents to serve as the single source of truth.
  - Capture current tech context from repository.
  - Record initial assumptions and open questions.
- Short-term
  - Define product vision and user stories for “Tiny Link”.
  - Identify initial architecture decisions (state management, navigation, data layer).
  - Establish basic CI commands (format, analyze, test) and quality gates.
- Long-term
  - Deliver an MVP with core features (to be defined).
  - Harden multi-platform build/release processes.

3. In Scope (initial)
- Flutter application codebase and its configuration.
- Documentation via Memory Bank in memory-bank/ directory.
- Multi-platform targets supported by Flutter project scaffolding.

4. Out of Scope (initial)
- Backend services or APIs (not yet defined).
- Detailed UX design system (colors, typography) beyond Flutter defaults.

5. Assumptions and Initial Decisions
- Language/Runtime: Dart SDK ^3.9.2 (per pubspec.yaml).
- Framework: Flutter stable channel assumed.
- Current dependencies: cupertino_icons only (no additional packages).
- App structure: MaterialApp root with a basic StatefulWidget (counter) using setState.
- No navigation, persistence, or network layers are present yet.

6. Constraints
- Must remain compatible with the platforms included in the repo scaffold.
- No sensitive credentials or secrets stored in repo.
- Follow flutter_lints recommended rules (per analysis_options.yaml + flutter_lints).

7. Stakeholders
- Product Owner: TBD
- Engineering: This repository’s maintainers
- Design: TBD

8. Milestones (proposed)
- M0: Memory Bank initialized and checked in.
- M1: Product vision and backlog defined; system patterns selected.
- M2: MVP architecture scaffolded (navigation, state mgmt, theming).
- M3: First feature vertical implemented and tested.
- M4: Multi-platform build/release validation.

9. Risks
- Ambiguity in product scope until vision is defined.
- Platform-specific build issues not yet tested on all targets.

10. Open Questions
- What is the exact product vision for “Tiny Link”? (URL shortener, link organizer, or something else?)
- What are the primary user personas and workflows?
- Is there a backend/API? If yes, hosting and auth strategy?
- Preferred state management (Provider, Riverpod, BLoC, etc.) and navigation approach (Navigator 2.0, go_router, etc.)?
- Branding/theme requirements?

11. Next Steps
- Populate productContext.md with problem statements and UX goals.
- Document current tech stack and repo conventions in techContext.md.
- Capture initial architecture sketch in systemPatterns.md.
- Set active priorities and immediate tasks in activeContext.md.
- Track current status and known issues in progress.md.
