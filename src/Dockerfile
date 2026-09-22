# syntax=docker/dockerfile:1.7

ARG BASE_IMAGE=docker.io/docker/sandbox-templates:codex-docker
FROM ${BASE_IMAGE} AS agent

ARG AGENT=codex

LABEL \
    org.opencontainers.image.title="Sandbox Worker" \
    org.opencontainers.image.source="https://github.com/whitfin/sbxs" \
    org.opencontainers.image.description="A batteries-included Docker Sandbox agent template"

USER root

# Remove inherited npm packages before installing each agent's standalone
# Linux distribution as the agent user below.
RUN case "$AGENT" in \
        codex) npm uninstall --global @openai/codex ;; \
        claude) npm uninstall --global @anthropic-ai/claude-code ;; \
        opencode) npm uninstall --global opencode-ai ;; \
        *) echo "Unsupported AGENT: $AGENT (expected codex, claude, or opencode)" >&2; exit 1 ;; \
    esac \
 && rm -rf /root/.npm /home/agent/.npm

USER agent

# The official installers write standalone releases to the agent's home and
# expose them through /home/agent/.local/bin.
RUN case "$AGENT" in \
        codex) \
            curl -fsSL https://chatgpt.com/codex/install.sh -o /tmp/install-agent.sh \
                && CODEX_NON_INTERACTIVE=1 sh /tmp/install-agent.sh \
                && rm /tmp/install-agent.sh \
            ;; \
        claude) \
            curl -fsSL https://claude.ai/install.sh -o /tmp/install-agent.sh \
         && bash /tmp/install-agent.sh \
         && rm /tmp/install-agent.sh \
            ;; \
        opencode) \
            curl -fsSL https://opencode.ai/install -o /tmp/install-agent.sh \
         && bash /tmp/install-agent.sh --no-modify-path \
         && mkdir -p /home/agent/.local/bin \
         && ln -s /home/agent/.opencode/bin/opencode /home/agent/.local/bin/opencode \
         && rm /tmp/install-agent.sh \
            ;; \
    esac \
 && rm -rf /home/agent/.npm

FROM agent AS worker

USER root

# Native compilation, Ruby, JVM build tools, and SQLite. Projects using Gradle
# are expected to provide the standard Gradle Wrapper (`./gradlew`).
RUN apt update \
 && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
        build-essential \
        clang \
        cmake \
        curl \
        elixir \
        erlang-dev \
        git \
        liblzma-dev \
        libsqlite3-dev \
        libssl-dev \
        maven \
        ninja-build \
        pkg-config \
        ruby-bundler \
        ruby-dev \
        ruby-full \
        sqlite3 \
        unzip \
        xz-utils \
        zip \
 && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=/opt/flutter \
    FLUTTER_ROOT=/opt/flutter \
    PATH=/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:/home/agent/.cargo/bin:$PATH

# Keep only the Flutter source and the Dart SDK bootstrapped by the Flutter
# tool. Platform engines, Android tooling, and desktop build libraries are
# intentionally omitted: this image is intended for package resolution and
# static analysis, not for compiling or running Flutter applications.
ARG FLUTTER_VERSION=3.47.4
RUN git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_HOME" \
 && git -C "$FLUTTER_HOME" switch -c stable \
 && git -C "$FLUTTER_HOME" update-ref refs/remotes/origin/stable HEAD \
 && git -C "$FLUTTER_HOME" config remote.origin.fetch '+refs/heads/stable:refs/remotes/origin/stable' \
 && git -C "$FLUTTER_HOME" config branch.stable.remote origin \
 && git -C "$FLUTTER_HOME" config branch.stable.merge refs/heads/stable \
 && chown -R agent:agent "$FLUTTER_HOME"

USER agent

# Keep the Python environment outside the runtime-mounted workspace so it is
# available to sandbox workers regardless of which project is mounted.
RUN uv venv --python python3 --seed /home/agent/.venv

ENV UV_PROJECT_ENVIRONMENT=/home/agent/.venv \
    VIRTUAL_ENV=/home/agent/.venv \
    PATH=/home/agent/.venv/bin:$PATH

# rustup installs per-user and keeps future toolchain updates straightforward.
RUN curl --proto '=https' --tlsv1.2 -fsS https://sh.rustup.rs -o /tmp/rustup.sh \
 && sh /tmp/rustup.sh -y --profile minimal --component clippy,rustfmt \
 && rm /tmp/rustup.sh

RUN mix local.hex --force \
 && mix local.rebar --force

RUN flutter config --no-analytics \
 && flutter --version \
 && dart --version

WORKDIR /workspace
