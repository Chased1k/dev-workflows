# Agent File Templates

> Formal specification for all agent-maintained log files. Both the Implementer and Reviewer must follow these formats.

---

## BUILD_LOG.md

```md
# Build Log

## Current Status

Project status:
Current sprint:
Last completed sprint:
Test status:

---

## Sprint History

### Sprint [N] — [Date] — [Title]

**Status:** in_progress | completed | blocked
**Implementer:** [model name]
**Reviewer:** [model name]
**Commit:** [hash or "pending"]

**Summary:** [One-line description]

**Files changed:**
- `path/to/file` — [what changed]

**Test results:**
- New tests: [N] written, [N] passing
- Full suite: [N]/[N] passing
- Lint: clean | issues found
- Typecheck: clean | issues found

**Deviations:** [Any plan deviations with rationale, or "none"]

**Notes:** [Context for future sprints]
```

---

## DECISIONS.md

```md
# Decision Log

## Format

### YYYY-MM-DD — Decision Title

**Context:** [What situation required a decision]
**Decision:** [What was decided]
**Rationale:** [Why this choice]
**Alternatives considered:** [What else was considered and why rejected]
**Impact:** [What this affects — files, future sprints, architecture]
**Related files:** [Files affected]
```

---

## ASSUMPTIONS.md

```md
# Assumptions

## Format

### YYYY-MM-DD — Assumption Title

**Assumption:** [What was assumed]
**Why it was needed:** [What was ambiguous in the specs]
**Risk level:** low | medium | high
**Human review needed:** yes | no
**Related files:** [Files affected]
```

---

## OPEN_QUESTIONS.md

```md
# Open Questions

## Format

### YYYY-MM-DD — Question Title

**Context:** [Where this came up]
**Question:** [What needs answering]
**Why it matters:** [What is blocked or at risk]
**Blocked work:** [What sprint/task is blocked]
**Suggested options:** [Possible answers if known]
```

---

## CURRENT_SPRINT.md

```md
# Current Sprint

**Sprint:** [N]
**Phase:** [Phase name/number]
**Goal:** [One-line objective]
**Status:** not_started | in_progress | completed | blocked
**Human review required:** yes | no

## Scope

**Included:**
- [What this sprint builds]

**Excluded:**
- [What is explicitly NOT in this sprint]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Sprint Queue

| # | Task | Status | Assigned | Commit |
|---|---|---|---|---|
| — | — | — | — | — |

## Blocked Items

| Task | Blocker | Since |
|---|---|---|
| — | — | — |

## Notes

[Any context for the Reviewer or Implementer]
```
