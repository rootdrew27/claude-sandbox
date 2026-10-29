# Sandbox image, built on first use. `claude-sandbox rebuild` updates Claude
# Code. Add tools you want in every sandbox here.
FROM node:22-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl gh git less procps python3 ripgrep tmux \
 && rm -rf /var/lib/apt/lists/*

# Owned by node so copied-in workspaces are writable.
RUN mkdir /workspace && chown node:node /workspace

COPY sandbox-setup sandbox-claude /usr/local/bin/

USER node
WORKDIR /home/node

# ~/.claude is created now so node owns it before a template is copied in.
RUN curl -fsSL https://claude.ai/install.sh | bash \
 && mkdir -p /home/node/.claude

# Push to GitHub over HTTPS with the GH_TOKEN passed in at launch, even when
# the remote is an SSH URL.
RUN git config --global credential.https://github.com.helper '!gh auth git-credential' \
 && git config --global url.https://github.com/.insteadOf git@github.com:

# Mouse-wheel scrolling and focus tracking in tmux. Hold Option/Shift while
# dragging to select text.
RUN printf 'set -g mouse on\nset -g focus-events on\n' > /home/node/.tmux.conf

# Keep all Claude state in ~/.claude. No self-updates; use `rebuild`.
ENV PATH="/home/node/.local/bin:${PATH}" \
    CLAUDE_CONFIG_DIR=/home/node/.claude \
    DISABLE_AUTOUPDATER=1

# Just stay up; claude-sandbox starts Claude in tmux with docker exec.
CMD ["sleep", "infinity"]
