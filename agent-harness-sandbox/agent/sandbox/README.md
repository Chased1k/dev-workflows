# Agent Harness Sandbox Internals

For normal usage, start with the top-level `README.md`. This file documents the implementation details.

This is a Colima/Docker wrapper for running AI coding harnesses in dangerous or low-friction modes without giving them your whole Mac account.

## What It Protects

The wrapper mounts only your current directory into the container as `/workspace`. It does not mount your host `~/.ssh`, `~/.aws`, `~/.config/gcloud`, `~/.kube`, shell profile, or home directory. The container is disposable and runs with dropped Linux capabilities plus `no-new-privileges`.

The command shims in `agent/sandbox/shims` add defense-in-depth for common shell paths:

- `git push`, `git commit`, `git rebase`, and `git reset --hard` require an explicit typed approval unless `AGENT_ALLOW_GIT_WRITE=1` is set.
- broad `rm -rf` is denied unless `AGENT_ALLOW_RM_RF=1` is set, and root/workspace wipes stay denied.
- `sudo` is denied.
- obvious `curl|bash` and `wget|sh` patterns are denied.

These shims are not a perfect security boundary. The boundary is the container plus the fact that host credentials are not mounted.

## Setup

```bash
cd ~/Documents/Coding/dev-workflows
git pull
agent-harness-sandbox/scripts/setup-safe-aliases
source ~/.zshrc
```

Use `source ~/.bashrc` instead if that is your shell. The launcher starts Colima when Docker is unavailable, then builds the image automatically the first time you run a safe command. Agents run as the non-root `node` user inside the container so Claude allows dangerous skip mode.

## Run

From the project directory you want the agent to edit:

```bash
cd ~/Documents/Coding/some-project
claude-safe
codex-safe
opencode-safe
```

To mount one sibling repo without mounting the whole parent directory:

```bash
cd ~/Documents/Coding/Workdaddy-Front
claude-safe -extra ~/Documents/Coding/Workdaddy
```

The current directory is `/workspace`. Extra folders are mounted under `/extra`, for example `/extra/Workdaddy`.

## Status Lines

Each run bootstraps status-line/config files into the persistent `/home/node` volume:

- Claude gets a command status line based on the host `~/.claude/statusline-command.sh`: current directory, model, context, rate limits, and tokenbank when a tokenbank status reader exists in the container home.
- Codex gets its built-in status-line items: model, current directory, context, used tokens, five-hour limit, and weekly limit.
- OpenCode keeps its native UI; no compatible command status-line hook was found in the local OpenCode config. It still uses the same persistent home and extra mounts.

The installed local flags verified on this Mac were:

- Claude Code `2.1.177`: `--dangerously-skip-permissions`
- Codex CLI `0.143.0`: `--dangerously-bypass-approvals-and-sandbox`
- AGY `1.0.16`: `--dangerously-skip-permissions`
- OpenCode `1.17.10`: no dangerous skip flag shown in `opencode --help`; this wrapper still isolates it externally.

The bundled Dockerfile installs Claude Code, Codex, and OpenCode. Your local `agy` is a macOS standalone binary, and no Linux install source was discoverable from `agy install --help`; the `agy` route is wired but requires a custom Linux image that contains `agy`:

```bash
AGENT_SANDBOX_IMAGE=my-agent-image-with-agy scripts/agent-yolo agy
```

## Credentials

The wrapper forwards these environment variables if already set on the host:

- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY`
- `GEMINI_API_KEY`

Claude/Codex/OpenCode config and auth state persist in the Docker volume `agent-harness-home`, mounted at `/home/node`. This avoids repeating onboarding every run without mounting your host `~/.claude`, `~/.codex`, or shell profile.

Use limited-scope keys. Any key available to a dangerous-mode agent can be read by that process. Avoid mounting native login folders such as `~/.claude`, `~/.codex`, or cloud credential directories unless you accept that risk.

## Git Push Workflow

The safest default is to let the agent edit and test inside the container, then review and push from the host:

```bash
git diff
git status
git push
```

If you intentionally want container-side git writes for one session, run a shell first and opt in there:

```bash
AGENT_ALLOW_GIT_WRITE=1 scripts/agent-yolo shell
```

Do not mount your host SSH directory just to make pushes work. Prefer HTTPS with a short-lived token or push from the host after review.

## Why Not One Universal Config File?

There is no single policy file that Claude Code, Codex, AGY, and OpenCode all parse as an enforcement source. `agent/sandbox/policy/agent-guardrails.json` is the shared source of intent for humans and wrappers. Enforcement comes from the Docker boundary and the mounted command shims.
