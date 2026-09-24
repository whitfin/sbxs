# syntax=docker/dockerfile:1.7
ARG BASE_IMAGE=docker.io/docker/sandbox-templates:codex-docker
FROM ${BASE_IMAGE}
USER root

LABEL \
    org.opencontainers.image.title="sbxs" \
    org.opencontainers.image.source="https://github.com/whitfin/sbxs" \
    org.opencontainers.image.description="A Docker Sandbox agent template with extended toolchains"

# Install all toolchains we can fetch directly via apt. It's generally better
# to pull from apt when possible because it's more resilient to base image changes.
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

# Configure Flutter toolchain paths
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

# Switch to the working user for future steps, starting with disabling
# Flutter's automatic analytics (even though they'd be sandbox blocked...).
USER agent
RUN flutter config --no-analytics \
 && flutter precache --linux

# Install the coding agent directly through the initial installers so they
# live in the default locations rather than via npm.
ARG AGENT=opencode
RUN case "$AGENT" in \
        codex) \
            npm uninstall --global @openai/codex \
         && curl -fsSL https://chatgpt.com/codex/install.sh -o /tmp/install-agent.sh \
         && CODEX_NON_INTERACTIVE=1 sh /tmp/install-agent.sh \
         && rm /tmp/install-agent.sh \
            ;; \
        claude) \
            npm uninstall --global @anthropic-ai/claude-code \
         && curl -fsSL https://claude.ai/install.sh -o /tmp/install-agent.sh \
         && bash /tmp/install-agent.sh \
         && rm /tmp/install-agent.sh \
            ;; \
        opencode) \
            npm uninstall --global opencode-ai \
         && curl -fsSL https://opencode.ai/install -o /tmp/install-agent.sh \
         && bash /tmp/install-agent.sh --no-modify-path \
         && mkdir -p /home/agent/.local/bin \
         && ln -s /home/agent/.opencode/bin/opencode /home/agent/.local/bin/opencode \
         && rm /tmp/install-agent.sh \
            ;; \
        *) \
            echo "Unsupported agent: $AGENT (expected codex, claude, or opencode)" >&2 \
         && exit 1 ;; \
    esac \
 && rm -rf /home/agent/.npm

# Keep the Python environment outside the runtime-mounted workspace so it is
# available to sandbox workers regardless of which project is mounted.
ENV UV_PROJECT_ENVIRONMENT=/home/agent/.venv \
    VIRTUAL_ENV=/home/agent/.venv \
    PATH=/home/agent/.venv/bin:$PATH
RUN uv venv --python python3 --seed $UV_PROJECT_ENVIRONMENT

# Install rustup as well as common components to keep Rust installation simple
RUN curl --proto '=https' --tlsv1.2 -fsS https://sh.rustup.rs -o /tmp/rustup.sh \
 && sh /tmp/rustup.sh -y --profile minimal --component clippy,rustfmt \
 && rm /tmp/rustup.sh

# Pre-cache Hex and Rebar so they're always available
RUN mix local.hex --force \
 && mix local.rebar --force

# Create our toolchain verification script for testing.
COPY --chmod=0755 docker-test /usr/local/bin/sbxs-check
ENV SBXS_AGENT=$AGENT
