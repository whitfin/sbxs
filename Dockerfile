FROM mcr.microsoft.com/devcontainers/universal:linux
USER codespace
WORKDIR /home/codespace/workspace

RUN CODEX_RELEASE=latest \
    CODEX_NON_INTERACTIVE=1 \
    curl -fsSL https://chatgpt.com/codex/install.sh | sh

ENV HOME=/home/codespace

COPY --chown=codespace:codespace bin/entrypoint.sh /usr/local/bin/codex-worker
RUN chmod 0755 /usr/local/bin/codex-worker
ENTRYPOINT ["/usr/local/bin/codex-worker"]
