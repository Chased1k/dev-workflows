# Agent Harness Sandbox

One command per coding agent, with the agent running inside a Colima/Docker sandbox instead of directly on the Mac.

## Quick Setup

Run this once per machine:

```bash
cd ~/Documents/Coding/dev-workflows
git pull
agent-harness-sandbox/scripts/setup-safe-aliases
source ~/.zshrc
```

Use `source ~/.bashrc` instead if that machine uses bash.

## Daily Use

From the repo you want the agent to edit:

```bash
cd ~/Documents/Coding/some-project
claude-safe
codex-safe
opencode-safe
```

The first run starts Colima if needed, builds the Docker image if missing, and launches the agent. The current directory is mounted as:

```bash
/workspace
```

## Extra Repos

Mount an additional folder with `-extra`:

```bash
cd ~/Documents/Coding/Workdaddy-Front
claude-safe -extra ~/Documents/Coding/work-daddy
```

Inside the container:

```bash
/workspace
/extra/work-daddy
```

`-extra` works with all wrappers:

```bash
claude-safe -extra ~/Documents/Coding/work-daddy
codex-safe -extra ~/Documents/Coding/work-daddy
opencode-safe -extra ~/Documents/Coding/work-daddy
```

Repeat `-extra` for more folders.

## Persistence

The container is disposable, but agent auth/config persists in this Docker volume:

```bash
agent-harness-home
```

That volume is mounted at:

```bash
/home/node
```

You may need to log in once inside each harness. After that, Claude/Codex/OpenCode auth should persist across `*-safe` runs.

`codex-safe` publishes `127.0.0.1:1455` on the Mac and forwards it to Codex's loopback listener inside the container, so browser login callbacks like `http://localhost:1455/auth/callback?...` can reach the Codex process that started login. If port `1455` is already busy on the Mac, run Codex with a different host port:

```bash
AGENT_CODEX_AUTH_PORT=1456 codex-safe
```

Then change only the port in the callback URL from `1455` to `1456` before opening or pasting it.

The wrapper intentionally does not mount host auth folders like:

```bash
~/.claude
~/.codex
~/.ssh
~/.aws
~/.config
```

## Status Lines

The sandbox bootstraps familiar status/config defaults into `/home/node` on each run:

- `claude-safe`: command status line with cwd, model, context, rate limits, and tokenbank when available.
- `codex-safe`: built-in status-line items for model, current dir, context, used tokens, 5h limit, and weekly limit.
- `opencode-safe`: native OpenCode UI. No compatible command status-line hook was found in the local OpenCode config.

## Safety Defaults

The wrapper runs agents as non-root user `node`, with:

```bash
--cap-drop=ALL
--security-opt no-new-privileges
```

It mounts only the current repo, optional `-extra` folders, the persistent container home, and read-only guardrail/shim files.

Command shims add defense-in-depth:

- `sudo` is denied.
- dangerous `rm -rf` patterns are denied.
- obvious `curl | bash` and `wget | sh` are denied.
- `git push`, `git commit`, `git rebase`, and `git reset --hard` require typed approval unless `AGENT_ALLOW_GIT_WRITE=1`.

The real security boundary is still Docker plus not mounting host secrets.

## tmux

For remote persistence:

```bash
tmux new -s agent
cd ~/Documents/Coding/some-project
claude-safe
```

Detach:

```text
Ctrl-b d
```

Resume:

```bash
tmux attach -t agent
```

## Troubleshooting

Check running containers:

```bash
docker ps
```

Kill a stuck sandbox container:

```bash
docker kill <container_id>
```

See images:

```bash
docker images | grep agent-harness-sandbox
```

Remove the persistent auth/config volume only if you want to reset onboarding:

```bash
docker volume rm agent-harness-home
```

If Docker is not reachable, the launcher tries:

```bash
colima start
```

## Internals

- Launcher: `scripts/agent-yolo`
- Alias installer: `scripts/setup-safe-aliases`
- Dockerfile: `agent/sandbox/Dockerfile`
- Guardrail policy: `agent/sandbox/policy/agent-guardrails.json`
- Command shims: `agent/sandbox/shims/`
- Home bootstrap and status line scripts: `agent/sandbox/bin/`

Detailed implementation notes live in `agent/sandbox/README.md`.
