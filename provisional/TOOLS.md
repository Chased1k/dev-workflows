# Provisional Tools & Patterns

Tools, frameworks, and patterns we're evaluating but haven't adopted yet. Each has potential — we're testing before committing.

---

## 1. Wasp OpenSaaS Boilerplate

**Status:** 🔬 Evaluating
**Source:** https://youtu.be/Doznvb9QXuA | [Full digest](../../obsidian/chiron-brain/reference/youtube/2026-08-05-wasp-opensaas-boilerplate.md)
**Repo:** https://github.com/wasp-lang/open-saas

**What:** Free, open-source SaaS template built on Wasp framework (React + Node.js + PrismaDB). Auth, Stripe, blog/docs, email, analytics, SEO, file upload out of the box.

**Why we care:**
- Dual Stripe model (subscription + credits) matches Team Chase payment needs exactly
- Declarative `main.wasp` config — define entities, routes, auth, and Wasp generates the code
- No vendor lock-in — full source code, deploy anywhere
- Could accelerate Perfect Cut MVP and Work Daddy frontend significantly

**Key features:**
- Auth: email/password + Google OAuth + GitHub OAuth (uncomment to enable)
- Stripe: subscription-based AND usage-based (credits) — local testing via Stripe CLI webhook
- Blog + Docs: Starlight template, write markdown → auto-generates doc site
- Email: SendGrid, Mailgun support
- Analytics: Plausible + Google Analytics
- SEO: Meta tags, Open Graph, structured data
- Admin dashboard with user management
- Docker + PostgreSQL for local dev

**Limitations:**
- Mac/Linux only (Windows needs WSL)
- React + Node.js stack only
- Newer framework — smaller ecosystem than Next.js

**Next steps:**
- [ ] `wasp new` with OpenSaaS template locally
- [ ] Test auth + Stripe setup end-to-end
- [ ] Evaluate for Perfect Cut and Work Daddy frontends

---

## 2. Super Simple Software Factory (SSSF)

**Status:** 🔬 Evaluating
**Source:** https://youtu.be/haUfb1ievTE (Dev Dan) | [Full digest](../../obsidian/chiron-brain/reference/youtube/2026-08-05-agentic-engineering-brain-dump.md)
**Repo:** Open-source (link in video description)

**What:** An agentic software factory that combines agents + deterministic code in structured workflows. Observable, customizable, reusable.

**Why we care:**
- "Agents + code beats agents alone" is exactly how OpenClaw skills work — this formalizes it
- Deterministic gate checks between agent steps (type validation, lint, test runs)
- Model stack thinking: Opus 5 for planning, Gemini Flash for building, cheap models for simple tasks
- Handoff via shared directory — agents write outputs, next agent reads previous agent's plan + notes
- Workflow types: Scout (research), Plan→Build, Plan→Build→Test, full SDLC

**Key patterns:**
- Core 4 of every agent: Context, Model, Prompt, Tools — swap any independently
- Deterministic checks between steps: code validates agent output, failed checks → auto re-prompt
- Swim-lane observability: see every agent run, model used, tokens, cost, prompts, tool calls
- Pi coding agent as default harness with custom harness engineering per agent

**Relevance to our stack:**
- Could improve our coding-agent skill with deterministic gate checks
- Model stack pattern maps to our GLM 5.2 / Opus 5 / Gemini Flash routing
- Software factory pattern fits TaskFlow / cron orchestration

**Next steps:**
- [ ] Clone and review the SSSF repo
- [ ] Evaluate deterministic gate check pattern for our coding agent skill
- [ ] Test model stack routing in our workflows

---

## 3. Wayfinder (swyx / AI Hero)

**Status:** 🔬 Evaluating
**Source:** https://youtu.be/F3lL98Pj90o (swyx) | [Full digest](../../obsidian/chiron-brain/reference/youtube/2026-08-05-agentic-engineering-brain-dump.md)
**Repo:** Available in swyx's skills repo

**What:** A planning skill that maps the "fog of war" for big projects. Creates decision tickets (not implementation tickets), tracks frontier (decisions you can make now) vs fog (blocked decisions), and orchestrates research, prototyping, and discussion sessions.

**Why we care:**
- Our OPEN-QUESTIONS.md files are already decision tickets — Wayfinder formalizes this
- Fog of war concept explains why big projects feel stuck
- Works with any issue tracker (GitHub, Linear, Jira)
- Each decision ticket gets its own agent session with auto-generated prompts

**Key concepts:**
- **4 ticket types**: Research, Prototype, Grilling (discussion), Task
- **Frontier vs Fog**: Frontier = decisions you can make now; Fog = decisions blocked on unknowns
- **Prototypes prevent waterfall**: high-fidelity validation before committing
- **Specs are disposable**: after spec is in code, close and delete the spec
- **Works for non-coding tasks**: used it for planning a garden office

**Workflow:**
1. Invoke wayfinder with destination description
2. It grills you about what "done" looks like
3. Creates initial map with decision tickets
4. Work through each ticket in separate agent sessions
5. Resolved tickets reveal new frontier decisions
6. When fog clears → convert map to spec → implementation tickets

**Relevance to our stack:**
- Maps perfectly to how we use Linear + sub-agents for big projects
- Could formalize our AgentForge and Underwater Treadmill planning
- Issue-tracker-agnostic → works with our Linear setup

**Next steps:**
- [ ] Install wayfinder skill from swyx's repo
- [ ] Test on a current OPEN-QUESTIONS.md item
- [ ] Evaluate for AgentForge and Underwater Treadmill planning

---

## 4. BMAD Loop (BMAD Method + Automator)

**Status:** 🔬 Evaluating
**Source:** https://youtu.be/iW86sMHszJw (Brian / BMAD Code + Paul/PinkyD)
**Repo:** BMAD Method (npm/npx install), Loop is the automator harness

**What:** An agentic development loop that automates the BMAD Method (Build, Measure, Analyze, Decide). Runs epics/stories through dev + review cycles automatically, with escalation, deferred work management, and a TUI dashboard.

**Why we care:**
- Automated dev + review cycles with escalation to human
- Deferred work ledger that intelligently iterates until resolved
- Supports Claude Code, Codex, Gemini, GitHub Copilot (adapter-based)
- TUI dashboard for observability (worktrees, sprint status, agent sessions)
- Model-agnostic — can mix models for dev vs review

**Key features:**
- **Sprint-based workflow**: runs stories in epics, stops between epics by default
- **Deferred work**: items not appropriate for current spec get deferred, then swept and resolved in batch
- **Escalation**: when a story hits a problem it can't solve, it spawns a resolution session for human input
- **Tmux-based**: uses tmux sessions for each agent run (not headless) — avoids API restrictions
- **Worktrees**: git worktrees per story or per run for isolation
- **Sweep mode**: goes through entire deferred work ledger, triages, bundles resolvable items, iterates until clean
- **Hooks system**: extensible adapter API for new coding assistants (codeless config via TOML)

**How it works:**
1. `npx bmad-method next install` → installs BMAD + Loop
2. `bmad setup` in project → configures skills, hooks, adapters
3. Choose coding harness (Claude, Codex, Gemini, Copilot)
4. Run by epic or story number (e.g., "7" for all of epic 7, "31" for story 1 of epic 3)
5. TUI shows sprint status, running sessions, deferred work
6. Escalation sessions spawn for human review when agent gets stuck

**Limitations:**
- Requires tmux 3.2+
- Still in early release (edge/next channel)
- Primarily designed for Claude Code + Codex workflows
- Hook system requires supported platforms (Claude, Codex, Gemini, Copilot CLI)

**Relevance to our stack:**
- 🟡 Could complement our coding-agent skill for longer autonomous runs
- 🟡 Deferred work + sweep pattern is interesting for managing tech debt
- 🟡 The escalation → resolution session pattern is similar to our sub-agent approach
- 🟡 TUI observability is nice but we have OpenClaw dashboard

**Next steps:**
- [ ] Install BMAD Method + Loop on a test project
- [ ] Evaluate deferred work management pattern for our workflows
- [ ] Test escalation flow for human-in-the-loop coding

---

## Cross-Cutting Patterns

These tools share several patterns worth noting:

1. **Deterministic + Agentic**: All combine code validation with LLM reasoning. Not pure agent — agents + code beats agents alone.

2. **Decision Tickets vs Implementation Tickets**: Wayfinder and BMAD both separate "what should we do?" from "do this thing." Our OPEN-QUESTIONS.md already does this.

3. **Deferred Work Management**: Both BMAD Loop and Wayfinder handle work that can't be addressed now. BMAD sweeps iteratively; Wayfinder tracks fog.

4. **Model Stack**: SSSF and BMAD both route different models to different tasks. Expensive models for planning, cheap models for building.

5. **Observability**: All four provide visibility into agent runs — swim lanes, TUI dashboards, issue tracker maps, or file-based paper trails.

6. **Handoff Patterns**: SSSF uses shared directories, Wayfinder uses issue tracker tickets, BMAD uses tmux sessions. All create persistent state between agent turns.