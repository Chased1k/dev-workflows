# Dev Workflows

> Workflow-as-code: reusable AI agent orchestration for software development. Sprint orchestration, multi-lens brainstorming, PRD building, TDD implement-review loops, and context-hidden bug diagnosis. Works with Claude Code, Codex CLI, and opencode.

## What this is

A collection of skills, agent definitions, templates, and examples for running structured AI-driven development workflows. Instead of prompting an AI to "build this feature," you run a **workflow** — a defined loop where specialized agents plan, implement, review, and commit in a structured cycle with logs, decisions, and human review gates.

Inspired by and adopting patterns from [Google's Elephant-Goldfish Method (EGM)](https://github.com/google/elephant-goldfish-model) — the principle that a context-rich agent (Elephant) paired with a stateless, zero-context agent (Goldfish) produces higher-confidence outcomes than either alone.

## Workflows included

| Workflow | What it does |
|---|---|
| **Brainstormer** | Multi-lens exploration: spawns 3-5 parallel goldfish subagents (technical, business, UX, contrarian) on a seed problem, synthesizes into a ranked concepts brief. Runs before the PRD Builder. |
| **PRD Builder** | Architect interviews you (grill-me session) to produce a detailed PRD, implementation plan, mockup specs, and constitution. Accepts a concepts brief as input. Gets to consensus before any code is written. |
| **Sprint Orchestrator** | Dual-agent TDD loop with a design review gate: fresh goldfish verifies the design doc is implementation-ready, then Reviewer (CTO) plans sprints, Implementer builds with TDD, Reviewer reviews with structured verdicts, commits on approval. Maintains build log, decision log, assumptions log, open questions. |
| **Bug Diagnosis** | Context-hidden dual-agent diagnosis: Elephant forms a hypothesis privately, fresh Goldfish diagnoses from symptom + code only. Convergence = high confidence, divergence = signal. Failing test before any fix. |
| **Bootstrap** | Adaptive script that detects the project's stack (Node, Python, Rust, Go, Ruby, Flutter, Java, PHP, Elixir, C/C++, Deno, Bun) and customizes the constitution with the right test, lint, typecheck, and build commands. |

## The full pipeline

```
Rough idea
    │
    ▼
┌──────────────┐
│  Brainstormer │  Multi-lens exploration (3-5 goldfish subagents)
│  (optional)   │  → concepts-brief.md
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  PRD Builder  │  Grill-me interview → PRD + implementation plan + constitution
│               │  Accepts concepts brief as input (Phase 0)
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────┐
│  Sprint Orchestrator                       │
│  ┌─────────────────┐                       │
│  │ Step 0: Design   │  Fresh goldfish      │
│  │ Review Gate      │  reviews design doc  │
│  └────────┬────────┘                       │
│           │ pass                            │
│           ▼                                 │
│  ┌─────────────────┐    ┌──────────────┐   │
│  │ Step 1: Reviewer │───▶│ Step 2:      │   │
│  │ plans sprint     │    │ Implementer  │   │
│  └─────────────────┘    │ builds (TDD)  │   │
│           ▲              └──────┬───────┘   │
│           │                     │           │
│  ┌────────┴─────────┐           ▼           │
│  │ Step 3: Reviewer │◀────────────────       │
│  │ reviews + commit │                      │
│  └────────┬─────────┘                      │
│           │ approved                       │
│           ▼                                 │
│  Step 4: Next sprint (loop)                │
└──────────────────────────────────────────────┘

Bug found? ──▶ ┌──────────────┐  ──▶ Sprint Orchestrator (fix)
               │ Bug Diagnosis │  (failing test already written)
               └──────────────┘
```

## Architecture

```
dev-workflows/
  README.md                        ← You are here
  scripts/
    bootstrap.sh                   ← Adaptive stack detection + constitution generation
  skills/
    brainstormer/
      SKILL.md                     ← Multi-lens brainstorming skill
    prd-builder/
      SKILL.md                     ← The PRD builder skill (accepts concepts brief)
    sprint-orchestrator/
      SKILL.md                     ← The orchestrator skill (with design review gate)
    bug-diagnosis/
      SKILL.md                     ← Context-hidden bug diagnosis skill
  agents/
    goldfish.md                    ← Stateless zero-context critic agent
    implementer.md                 ← TDD implementer agent definition
    reviewer.md                    ← CTO/reviewer agent definition
    architect.md                   ← PRD architect agent definition
  templates/
    constitution.md                ← Blank constitution template
    concepts-brief.md              ← Blank concepts brief template (brainstormer output)
    prd.md                         ← Blank PRD template
    implementation-plan.md         ← Blank phase/task plan template
    current-sprint.md              ← Blank sprint tracking template
    build-log.md                   ← Blank build log template
    decision-log.md                ← Blank decision log template
    assumptions.md                 ← Blank assumptions log template
    open-questions.md              ← Blank open questions template
    agent-file-templates.md        ← Formal spec for all log file formats
  examples/
    constitution.md                ← Filled-out example constitution
    prd.md                         ← Filled-out example PRD
    implementation-plan.md         ← Filled-out example plan
    current-sprint.md              ← Filled-out example sprint
    build-log.md                   ← Filled-out example build log
    decision-log.md                ← Filled-out example decisions
    assumptions.md                 ← Filled-out example assumptions
    open-questions.md              ← Filled-out example questions
  provisional/
    TOOLS.md                       ← Provisional notes
```

## How to use

### Bootstrap a new project

```bash
# From your project root:
bash /path/to/dev-workflows/scripts/bootstrap.sh .

# Or copy the script and run it:
cp dev-workflows/scripts/bootstrap.sh your-project/
cd your-project && bash bootstrap.sh .
```

The bootstrap script detects your stack and generates a customized constitution + docs structure. Then:

### Run the workflows

#### With opencode

Copy the files you need into your project:

```bash
# Copy the full workflow suite
cp -r dev-workflows/skills/* your-project/.opencode/skills/
cp -r dev-workflows/agents/* your-project/.opencode/agent/
cp -r dev-workflows/templates/* your-project/docs/agents/
```

Then restart opencode. Trigger with "brainstorm", "start sprint", "run sprint", "build PRD", "grill me", "debug this", or "diagnose this bug".

#### With Claude Code

Claude Code loads skills from `~/.claude/skills/`. Copy the skills there:

```bash
cp -r dev-workflows/skills/* ~/.claude/skills/
```

Agent definitions can be referenced inline or placed in `.claude/agents/`.

#### With Codex CLI

Place skills in Codex's skills directory and reference agent definitions in your session prompts.

## Model recommendations

These workflows are model-agnostic. The agent definitions use placeholder model names. Recommended pairings:

| Role | Budget option | Quality option |
|---|---|---|
| Implementer | DeepSeek V3 / Kimi K2.6 / Qwen3 Coder | Claude Sonnet 4 / Codex |
| Reviewer | DeepSeek V4 Pro / Kimi K27 | Claude Opus 4 |
| Architect (PRD) | DeepSeek V4 Pro | Claude Opus 4 / Gemini 2.5 Pro |
| Goldfish (critic) | DeepSeek V3 / Qwen3 | Claude Sonnet 4 / Gemini 2.5 Pro |

The Goldfish role benefits from a strong model — it's doing fresh-perspective analysis, not pattern-matching on context. But a budget model works well for straightforward review tasks.

Adjust models in the agent files to match your provider and budget.

## Elephant-Goldfish Method attribution

Several patterns in this project are adopted from [Google's Elephant-Goldfish Model (EGM)](https://github.com/google/elephant-goldfish-model):

| Pattern | EGM concept | Where it's used |
|---|---|---|
| Multi-lens brainstorming | Multiple goldfish with different perspectives | Brainstormer skill |
| Design review gate | Fresh goldfish reviews design before implementation | Sprint Orchestrator Step 0 |
| Context-hidden bug diagnosis | Elephant hypothesis hidden from goldfish | Bug Diagnosis skill |
| Stateless critic agent | Goldfish: zero-context, receives only what's handed | Goldfish agent definition |

The core insight: context-rich agents (Elephants) and context-free agents (Goldfish) have complementary strengths. Convergence between them is high-confidence signal. Divergence is signal to investigate.

## Philosophy

1. **The LLM sits on top of structured data. It never is the data.** All state lives in files — PRDs, logs, plans. The AI reads them, acts on them, updates them.
2. **TDD is non-negotiable.** Tests before code, full suite must pass, no regressions.
3. **No silent decisions.** Every assumption is logged with risk level. Every architectural choice is documented with rationale.
4. **Human review gates.** Critical sprints are flagged for human review. Escalation path exists for plan/spec contradictions.
5. **Granular commits.** One commit per approved sprint with meaningful messages.
6. **Independent verification.** The Reviewer never trusts the Implementer's report — it runs the checks itself.
7. **Fresh eyes catch what familiar eyes miss.** The Goldfish role provides unbiased, context-free review at key gates — design review, bug diagnosis, and brainstorming.

## Contributing

This is a living project. As you run workflows and discover what works and what doesn't, update the templates, agent definitions, and examples. The goal is to capture hard-won workflow knowledge in reusable form.

## License

MIT — use, modify, share freely.