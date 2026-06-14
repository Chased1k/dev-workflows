# Constitution — The Perfect Cut

> Code of conduct for all agents working on this project. Read by the Reviewer before every sprint and by the Implementer before every task. Non-negotiable.

## Core Architecture Rule

**The LLM sits on top of structured data. It never is the data.**

- All logs, targets, and plans live in Postgres
- Before every AI interaction, build a "context packet" from the DB
- The AI explains, coaches, and suggests — it does not store state
- After each AI session, generate a structured summary and save it

## Development Process

1. **Work sprint-by-sprint only.** Do not skip ahead. Do not implement future features.
2. **TDD is non-negotiable.** Write failing tests, verify red, implement, verify green, run full suite.
3. **Do not silently make architectural decisions.** If a decision is required:
   - Choose the safest minimal option and log it in `docs/agents/assumptions.md`, or
   - Stop and add it to `docs/agents/open-questions.md`
4. **One commit per sprint.** Do not amend. Do not push without review. Do not skip hooks.
5. **Never introduce new dependencies without explicit approval** from the PRD or Reviewer.
6. **Follow existing patterns.** Read neighboring files before writing new code. Mimic conventions.

## Agent Responsibilities

### Reviewer (CTO/Advisor)
- Reads all context before every sprint
- Breaks work into tasks with explicit scope and acceptance criteria
- Reviews all code with structured verdicts
- Commits approved work with meaningful messages
- Maintains decision log, assumptions log, and open questions
- Flags when human review is needed

### Implementer (Builder)
- Writes tests first, code second
- Runs full test suite — no regressions
- Runs lint and typecheck — must be clean
- Updates build log with structured entries
- Reports completion in structured format
- Never commits — the Reviewer handles commits

## Safety Principles (Non-Negotiable)

- Conservative recommendations by default
- Risk flags always visible when a cut is aggressive
- Disclaimer on all AI output: "Not medical advice. Consult a professional for extreme cuts."
- Emergency symptom list always accessible (dizziness, cramping, confusion = stop immediately)
- Never recommend cuts that exceed safe thresholds without prominent warnings

## Code Conventions

- TypeScript strict mode always
- Server components by default, `'use client'` only when needed
- Supabase server client for all DB reads/writes
- DB queries in `packages/shared/src/queries/` — injected `SupabaseClient` as first argument
- AI layer in `packages/shared/src/ai/` — no inline AI calls in components
- Mobile-first — this is used on phones at gyms and fight week
- No unnecessary comments

## Verification Gates

Before any sprint is complete:
- [ ] Full test suite passes (`pnpm test`)
- [ ] Typecheck clean (`pnpm typecheck`)
- [ ] Lint clean
- [ ] No new dependencies without approval
- [ ] All agent log files updated
- [ ] Commit message follows convention
