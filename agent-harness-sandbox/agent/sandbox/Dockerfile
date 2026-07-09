FROM node:22-bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    openssh-client \
    python3 \
    ripgrep \
    wget \
    zsh \
  && rm -rf /var/lib/apt/lists/*

# Agent CLIs change package names and auth flows over time. Keep these installs
# in one layer so failures are obvious during image build.
RUN npm install -g \
    @anthropic-ai/claude-code \
    @openai/codex \
    opencode-ai

WORKDIR /workspace
ENV SHELL=/bin/bash
CMD ["bash"]
