# Decision Log

> Architectural decisions, assumptions, and rationale. Updated by the Reviewer agent.

---

### 2026-06-13 — Query Functions Use Injected SupabaseClient

**Context:** Needed a pattern for database access that works in both server components and API routes.
**Decision:** All query functions in `packages/shared/src/queries/` take an injected `SupabaseClient` as the first argument. No global singleton.
**Rationale:** Server components get a request-scoped client via cookies; API routes get one via headers. Injection makes both work without duplicating query logic. Also makes testing trivial — pass a mock client.
**Alternatives considered:** Global singleton (breaks request-scoping), React hooks (can't use in API routes), ORM (adds dependency, less control over RLS).
**Impact:** Every query function signature, all callers in server components and API routes.
**Related files:** `packages/shared/src/queries/*.ts`, `apps/web/lib/supabase/server.ts`

### 2026-06-13 — Feasibility Engine is Pure TypeScript, No DB Dependency

**Context:** The feasibility engine needs current weight, target weight, days remaining, and weigh-in format. It could query the DB directly or receive data as parameters.
**Decision:** Engine functions are pure — they receive data as parameters and return results. No DB access inside the engine.
**Rationale:** Makes the engine independently testable without a database. Allows the same engine to run on the server (with DB data) or be pre-computed for the AI context packet. Follows the "LLM sits on top of structured data" principle.
**Alternatives considered:** Engine queries DB internally (harder to test, couples engine to Supabase), engine as API endpoint (adds network latency for what should be instant math).
**Impact:** Engine functions in `packages/shared/src/engine/`, query functions in `packages/shared/src/queries/` feed data to engine.
**Related files:** `packages/shared/src/engine/feasibility.ts`, `packages/shared/src/queries/`

### 2026-06-14 — Risk Flag Thresholds

**Context:** The PRD says "risk flags for aggressive cuts" but doesn't specify exact thresholds. Needed concrete numbers for the engine.
**Decision:**
- Same-day weigh-in + >5% bodyweight cut → high risk
- <4 weeks remaining + >8% bodyweight cut → high risk
- Athlete estimated BMI <18 (from height/weight) → medium risk (too lean)
- >10% bodyweight cut regardless of timeline → extreme risk
**Rationale:** Based on sports science literature and conservative safety principles. Thresholds can be adjusted later with real-world data.
**Alternatives considered:** Higher thresholds (6% same-day, 10% short-timeline) — rejected as too permissive for safety-critical app. Lower thresholds (3% same-day) — rejected as too restrictive, would flag nearly all combat sport cuts.
**Impact:** `packages/shared/src/engine/feasibility.ts` risk flag detection, assessment UI warning display.
**Related files:** `packages/shared/src/engine/feasibility.ts`, `packages/shared/src/engine/__tests__/feasibility.test.ts`
