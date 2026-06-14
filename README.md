# Dev Workflows

> Workflow-as-code: reusable AI agent orchestration for software development. Sprint orchestration, PRD building, TDD implement-review loops. Works with Claude Code, Codex CLI, and opencode.

## What this is

A collection of skills, agent definitions, templates, and examples for running structured AI-driven development workflows. Instead of prompting an AI to "build this feature," you run a **workflow** — a defined loop where specialized agents plan, implement, review, and commit in a structured cycle with logs, decisions, and human review gates.

## Workflows included

| Workflow | What it does |
|---|---|
| **Sprint Orchestrator** | Dual-agent TDD loop: Reviewer (CTO) plans sprints from PRD/specs, Implementer builds with TDD, Reviewer reviews with structured verdicts, commits on approval. Maintains build log, decision log, assumptions log, open questions. |
| **PRD Builder** | Architect interviews you (grill-me session) to produce a detailed PRD, implementation plan, mockup specs, and constitution. Gets to consensus before any code is written. |

## Architecture

```
dev-workflows/
  README.md                     ← You are here
  skills/
    sprint-orchestrator/
      SKILL.md                  ← The orchestrator skill
    prd-builder/
      SKILL.md                  ← The PRD builder skill
  agents/
    implementer.md              ← TDD implementer agent definition
    reviewer.md                 ← CTO/reviewer agent definition
    architect.md                ← PRD architect agent definition
  templates/
    constitution.md             ← Blank constitution template
    prd.md                      ← Blank PRD template
    implementation-plan.md      ← Blank phase/task plan template
    current-sprint.md           ← Blank sprint tracking template
    build-log.md                ← Blank build log template
    decision-log.md             ← Blank decision log template
    assumptions.md              ← Blank assumptions log template
    open-questions.md           ← Blank open questions template
    agent-file-templates.md     ← Formal spec for all log formats
  examples/
    constitution.md             ← Filled-out example constitution
    prd.md                      ← Filled-out example PRD
    implementation-plan.md      ← Filled-out example plan
    current-sprint.md           ← Filled-out example sprint
    build-log.md                ← Filled-out example build log
    decision-log.md             ← Filled-out example decisions
    assumptions.md              ← Filled-out example assumptions
    open-questions.md           ← Filled-out example questions
```

## How to use

### With opencode

Copy the files you need into your project:

```bash
# Copy the full workflow suite
cp -r dev-workflows/skills/* your-project/.opencode/skills/
cp -r dev-workflows/agents/* your-project/.opencode/agent/
cp -r dev-workflows/templates/* your-project/docs/agents/
```

Then restart opencode. Trigger with "start sprint", "run sprint", "build PRD", or "grill me".

### With Claude Code

Claude Code loads skills from `~/.claude/skills/`. Copy the skills there:

```bash
cp -r dev-workflows/skills/* ~/.claude/skills/
```

Agent definitions can be referenced inline or placed in `.claude/agents/`.

### With Codex CLI

Place skills in Codex's skills directory and reference agent definitions in your session prompts.

## Model recommendations

These workflows are model-agnostic. The agent definitions use placeholder model names. Recommended pairings:

| Role | Budget option | Quality option |
|---|---|---|
| Implementer | DeepSeek V3 / Kimi K2.6 / Qwen3 Coder | Claude Sonnet 4 / Codex |
| Reviewer | DeepSeek V4 Pro / Kimi K27 | Claude Opus 4 |
| Architect (PRD) | DeepSeek V4 Pro | Claude Opus 4 / Gemini 2.5 Pro |

Adjust models in the agent files to match your provider and budget.

## Philosophy

1. **The LLM sits on top of structured data. It never is the data.** All state lives in files — PRDs, logs, plans. The AI reads them, acts on them, updates them.
2. **TDD is non-negotiable.** Tests before code, full suite must pass, no regressions.
3. **No silent decisions.** Every assumption is logged with risk level. Every architectural choice is documented with rationale.
4. **Human review gates.** Critical sprints are flagged for human review. Escalation path exists for plan/spec contradictions.
5. **Granular commits.** One commit per approved sprint with meaningful messages.
6. **Independent verification.** The Reviewer never trusts the Implementer's report — it runs the checks itself.

## Contributing

This is a living project. As you run workflows and discover what works and what doesn't, update the templates, agent definitions, and examples. The goal is to capture hard-won workflow knowledge in reusable form.

## License

MIT — use, modify, share freely.
