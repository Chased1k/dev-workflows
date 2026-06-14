# Assumptions

> Assumptions made when specs are ambiguous. Updated by the Reviewer agent. Each assumption includes risk level and whether human review is needed.

---

### 2026-06-13 — Single Active Event Per Athlete

**Assumption:** An athlete has exactly one active event at a time. The dashboard, daily plans, and AI coach all reference the single active event.
**Why it was needed:** The PRD mentions "active event" in singular form throughout but doesn't explicitly state whether multiple concurrent events are supported.
**Risk level:** medium
**Human review needed:** yes
**Related files:** `packages/shared/src/queries/events.ts` (getActiveEvent returns single row), `apps/web/app/(dashboard)/page.tsx`

### 2026-06-13 — Weight Entries Are Morning Weigh-Ins

**Assumption:** Weight entries represent morning weigh-ins (fasted, post-bathroom). The daily weight target is compared against the most recent morning weight.
**Why it was needed:** The PRD says "log weight" but doesn't specify time-of-day convention. Combat athletes typically weigh in morning fasted.
**Risk level:** low
**Human review needed:** no
**Related files:** `packages/shared/src/queries/weight-entries.ts`, `packages/shared/src/engine/planner.ts`

### 2026-06-14 — Calorie Targets Use Mifflin-St Jeor Equation

**Assumption:** Daily calorie targets are derived from Mifflin-St Jeor BMR × activity factor, then adjusted by cut deficit. The PRD says "calorie targets computed by rules engine" but doesn't specify the formula.
**Why it was needed:** The engine needs a concrete formula to compute calorie targets. Mifflin-St Jeor is the most widely validated BMR equation.
**Risk level:** low
**Human review needed:** no
**Related files:** `packages/shared/src/engine/planner.ts`

### 2026-06-14 — Symptoms Are Free-Text Tags, Not Structured Severity

**Assumption:** The `symptoms` field in daily_logs is a text array of tags (e.g., ["dizziness", "fatigue", "cramping"]) rather than structured severity scores. The AI coach interprets them from context.
**Why it was needed:** The PRD lists "symptoms" as a log field but doesn't specify format. Structured severity (1-10 per symptom) would be more data-rich but adds UI complexity.
**Risk level:** medium
**Human review needed:** yes
**Related files:** `packages/shared/src/queries/daily-logs.ts`, `apps/web/components/logging/symptoms-input.tsx`
