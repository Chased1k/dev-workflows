---
name: bug-diagnosis
description: Use when debugging a bug, diagnosing an issue, investigating a regression, or when the user says "debug this", "what's causing this", "bug diagnosis", "why is this broken", or "diagnose this bug". Uses context-hidden dual-agent diagnosis: the Elephant forms a hypothesis privately, a fresh Goldfish diagnoses from symptom + code only, then compares for convergence.
---

# Bug Diagnosis

You are the **Bug Diagnosis** orchestrator — you run a dual-agent diagnostic process inspired by Google's Elephant-Goldfish Method. The Elephant (you, main session) forms a hypothesis privately. A fresh Goldfish (stateless subagent) diagnoses from only the symptom and code. If they converge, high confidence. If they diverge, that's signal.

## When to use

- A bug or regression needs diagnosis
- User reports unexpected behavior
- User says "debug this", "why is this broken", "what's causing this"
- A test is failing and the cause is unclear

## The flow

### Step 1: Gather the symptom

Collect from the user or issue tracker:
- **Symptom:** What's happening that shouldn't be
- **Repro steps:** How to trigger it (exact steps, inputs, environment)
- **Expected vs. actual behavior:** What should happen vs. what does happen
- **Environment:** OS, runtime, dependencies, config (if relevant)
- **Recent changes:** Last commit, recent deploys, config changes (if known)

If the user gives an issue number, fetch the issue details first.

### Step 2: Elephant forms hypothesis (PRIVATE)

As the Elephant (main session), read the relevant code files and form your own hypothesis about the root cause. **Do NOT share this with the user yet.** Hold it privately.

Your hypothesis should include:
- Root cause hypothesis (your best guess)
- Affected files
- Suggested test case that would confirm it
- Confidence level (high/medium/low)

### Step 3: Spawn the Goldfish diagnostician

Launch a `goldfish` subagent with ONLY:
- The symptom and repro steps
- The relevant code files (read the files and pass their contents)
- The output format

**Do NOT pass:**
- Your hypothesis
- Conversation history
- Prior decisions or context
- Any hints about what you think the cause is

The Goldfish returns:
```
ROOT_CAUSE_HYPOTHESIS: [their best guess at what's wrong, with reasoning]
AFFECTED_FILES: [which files likely need to change]
SUGGESTED_TEST_CASE: [a failing test that would confirm the diagnosis]
CONFIDENCE: high | medium | low
```

### Step 4: Compare diagnoses

Compare your (Elephant) hypothesis with the Goldfish's:

| Outcome | Meaning | Action |
|---|---|---|
| **Converged** — same root cause | High confidence diagnosis | Proceed to Step 5 |
| **Partially converged** — same area, different specifics | Medium confidence | Investigate the differences, then proceed |
| **Diverged** — different root causes | Low confidence — signal to investigate | Proceed to Step 6 |

### Step 5: Converged — write failing test, hand off

When diagnoses converge (or partially converge after investigation):

1. **Write a failing test** that reproduces the bug based on the agreed diagnosis
2. Confirm the test fails (red phase)
3. Present both diagnoses to the user for transparency:
   ```
   DIAGNOSIS (converged):
   Elephant: [your hypothesis]
   Goldfish: [their hypothesis]
   Confidence: HIGH
   
   Failing test written: [test file path]
   Test confirms bug: [yes/no]
   
   Recommended next step: Run sprint-orchestrator to fix the bug (test is already red — Implementer just needs to make it green).
   ```
4. Hand off to the sprint-orchestrator with the failing test as the starting point

### Step 6: Diverged — second goldfish round, then escalate

When diagnoses diverge:

1. **Spawn a second goldfish** with the same symptom + code, but also include both hypotheses (Elephant's and first Goldfish's) labeled as "Hypothesis A" and "Hypothesis B" (don't reveal which is which). Ask the goldfish: "Which hypothesis is more likely correct, and why? Or is there a third explanation?"
2. If the second goldfish picks one hypothesis confidently, proceed to Step 5 with that diagnosis
3. If still unclear, **escalate to the user** with all hypotheses:
   ```
   DIAGNOSIS (diverged — needs human input):
   
   Elephant hypothesis: [your diagnosis]
   Goldfish 1 hypothesis: [their diagnosis]
   Goldfish 2 assessment: [their pick or "neither"]
   
   Evidence for each:
   - [key evidence points]
   
   I recommend: [your best guess at which is right, or "investigate [specific area]"]
   
   What do you think? Should I proceed with [recommended hypothesis] or investigate further?
   ```
4. Wait for user input before proceeding

### Step 7: After user decides (if escalated)

Once the user picks a direction:
1. Write the failing test for the agreed diagnosis
2. Confirm it fails
3. Hand off to sprint-orchestrator

## What to tell the user

After a converged diagnosis:
- Both diagnoses (for transparency)
- Confidence level
- Failing test location
- Recommended next step (sprint-orchestrator)

After a diverged diagnosis:
- All hypotheses
- Evidence for each
- Your recommendation
- Ask which direction to pursue

## Safety rules
- Never share the Elephant's hypothesis with the Goldfish — this defeats the entire method
- Never skip the failing test — the bug must be reproduced before any fix is attempted
- The Goldfish must receive ONLY symptom + repro + code — no conversation, no hints
- If the Goldfish can't form a confident diagnosis from what it's given, provide more code context and respawn — don't hint at the answer
- If diagnoses diverge twice, always escalate to the user — don't keep spawning goldfish hoping for convergence
- Never fix the bug in this skill — hand off to sprint-orchestrator for the actual fix
- Maximum 2 goldfish rounds before escalating to the user