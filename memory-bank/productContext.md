# Product Context — Tiny Link

Last updated: 2025-10-04

1. Purpose and Problem
- Purpose: Define why Tiny Link exists and how it delivers value to users.
- Working Hypotheses (to be validated):
  - Tiny Link could be a link utility: URL shortener, link organizer, or smart link hub.
  - Primary value may include simplifying sharing, tracking engagement, or organizing personal/professional links.

2. Users and Personas (TBD)
- Creator/Marketer: Needs branded/trackable short links for campaigns.
- Individual/Student: Needs quick, memorable links for personal sharing or organization.
- Team Member: Needs shared link spaces, roles/permissions, and basic analytics.
- Admin/Owner: Needs usage reports, quotas, and simple governance.

3. Core Use Cases (vague until vision is set)
- Create a link: Input long URL -> get short link.
- Manage links: List, search, tag, archive links.
- Share links: Copy, QR, app share sheet (platform-specific).
- Track performance: Click counts and basic analytics (if in scope).
- Organize: Collections/Folders/Tags to group links (if in scope).

4. Experience Principles
- Fast: Single-action flows for common tasks (create, copy).
- Clear: Minimal fields; defaults and sensible confirmations.
- Trustworthy: No unexpected redirects or tracking beyond what’s disclosed.
- Cross-platform: Consistent UX across mobile/desktop/web with platform-appropriate affordances.

5. Scope v1.0 (Hypotheses for MVP — confirm or revise)
- Must-have:
  - On-device link list (local data persistence) OR API-backed list if backend exists.
  - Add new link with validation and duplication checks.
  - Copy-to-clipboard and quick-share actions.
- Nice-to-have:
  - QR generation for links.
  - Basic analytics (click count; depends on backend feasibility).
  - Tags or folders for organization.
- Out-of-scope (initial):
  - Team/roles, billing, SSO/OAuth.
  - Advanced analytics dashboards.

6. Success Metrics (proposed)
- Time-to-first-link (TTFL): < 20 seconds for a new user.
- Task success: > 95% successful link creation attempts.
- Retention proxy: >= 30% users return within 7 days (if telemetry exists).
- Reliability: < 1% crash rate per release.

7. Competitive/Alternatives (notes)
- Bitly, TinyURL, Rebrandly, Linktree-like “link hubs”.
- Differentiators might include: privacy-first, offline-friendly, simple/no-signup, open-source.

8. Risks and Assumptions
- Risk: Ambiguous product definition can stall technical choices.
- Risk: Without backend, “shortening” is local-only (not shareable globally).
- Assumption: Flutter is acceptable for all target platforms and performance envelope.
- Assumption: Initial release can succeed without server analytics.

9. Open Questions
- Exact product: Shortener vs organizer vs hub? One or a hybrid?
- Data model: Local-only (e.g., SQLite) vs backend service (API)? If backend, which stack?
- Branding: Name, icon, color, typography requirements?
- Privacy/Telemetry: Collect metrics? If yes, how to disclose and store?

10. Decisions Awaiting Input
- MVP scope confirmation.
- Backend presence and minimal API spec (if applicable).
- State management and navigation strategy.
- Initial UI flow: landing screen, create-link flow, list view, detail view.

11. Next Steps
- Confirm product vision and MVP boundaries.
- Draft user stories and acceptance criteria for MVP features.
- Align with systemPatterns.md on architecture choices.
- Reflect confirmed decisions in activeContext.md and progress.md.
