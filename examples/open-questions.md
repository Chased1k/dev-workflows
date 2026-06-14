# Open Questions

> Unresolved questions that need human input. Updated by the Reviewer agent.

---

### 2026-06-13 — Metric/Imperial Unit Preference

**Context:** The app currently uses metric units (kg, cm, ml, mg) throughout. The PRD notes this as a known gap.
**Question:** Should we add a unit preference toggle (metric/imperial) to athlete profiles, and if so, should it be Phase 1 or deferred?
**Why it matters:** US-based athletes think in pounds, ounces, inches. Without imperial support, they'll convert manually or abandon the app.
**Blocked work:** None currently — all engine math works in metric regardless. UI display layer would need conversion.
**Suggested options:**
1. Add unit preference to athlete profile in Sprint 1.1 follow-up, convert all UI displays
2. Defer to Phase 1 mobile app (post-MVP web launch)
3. Support both — store metric, display in user preference

### 2026-06-14 — Multiple Events Per Athlete

**Context:** We assumed single active event (see assumptions log). An athlete might have a tournament next month and another in 6 months — they'd want to plan both.
**Question:** Should we support multiple events per athlete, with one marked "active" for dashboard purposes?
**Why it matters:** Affects data model (events table is already one-to-many), query functions (getActiveEvent vs. listEvents), and UI (event switcher).
**Blocked work:** None currently — single-event assumption works for MVP. Would need to revisit before multi-event UI.
**Suggested options:**
1. Keep single active event for MVP, add event switching in Phase 2
2. Add event list + active toggle now (Sprint 1.1 follow-up)
3. Support multiple concurrent active events (complex — which one drives the dashboard?)

### 2026-06-14 — Symptom Severity Tracking

**Context:** We assumed symptoms are free-text tags (see assumptions log). For AI coach quality, structured severity would enable trend detection.
**Question:** Should symptoms include severity scores (1-10) or remain as simple tags?
**Why it matters:** Severity scores enable the AI coach to detect worsening trends ("your dizziness has increased from 2 to 6 this week"). Tags alone are less actionable.
**Blocked work:** None currently — tag-based symptoms work for MVP. Would affect daily_logs schema and logging UI.
**Suggested options:**
1. Keep tags for MVP, add severity in Phase 2
2. Add optional severity field now (nullable, doesn't break existing logs)
3. Structured symptom catalog with predefined symptoms + severity
