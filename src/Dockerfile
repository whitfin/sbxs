# syntax=docker/dockerfile:1.7

ARG BASE_IMAGE=docker.io/docker/sandbox-templates:codex-docker
FROM ${BASE_IMAGE} AS agent

ARG AGENT=codex

LABEL org.opencontainers.image.title="Sandbox Worker" \
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
    esac

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
    esac

FROM agent AS worker

USER root

# Native compilation, Ruby, JVM build tools, SQLite, and the libraries needed
# to build Flutter Linux applications. Maven comes from Ubuntu; Gradle is
# installed separately below because Ubuntu's Gradle package is obsolete.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        clang \
        cmake \
        curl \
        git \
        libglu1-mesa \
        libgtk-3-dev \
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

# Install a current Gradle release instead of Ubuntu's legacy 4.x package.
ARG GRADLE_VERSION=9.7.1
RUN curl -fsSLo /tmp/gradle.zip \
        "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    && curl -fsSLo /tmp/gradle.zip.sha256 \
        "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip.sha256" \
    && echo "$(cat /tmp/gradle.zip.sha256)  /tmp/gradle.zip" | sha256sum --check --strict \
    && unzip -q /tmp/gradle.zip -d /opt \
    && ln -s "/opt/gradle-${GRADLE_VERSION}/bin/gradle" /usr/local/bin/gradle \
    && rm /tmp/gradle.zip /tmp/gradle.zip.sha256

ENV ANDROID_HOME=/opt/android-sdk-linux \
    ANDROID_SDK_ROOT=/opt/android-sdk-linux \
    FLUTTER_HOME=/opt/flutter \
    FLUTTER_ROOT=/opt/flutter \
    PATH=/opt/android-sdk-linux/cmdline-tools/latest/bin:/opt/android-sdk-linux/platform-tools:/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:/home/agent/.cargo/bin:$PATH

USER agent

# rustup installs per-user and keeps future toolchain updates straightforward.
RUN curl --proto '=https' --tlsv1.2 -fsS https://sh.rustup.rs -o /tmp/rustup.sh \
    && sh /tmp/rustup.sh -y --profile minimal --component clippy,rustfmt \
    && rm /tmp/rustup.sh

USER root

# Flutter is included in every variant. Cloning it rather than unpacking its
# official Linux archive also supports native ARM64 sandbox hosts.
ARG FLUTTER_VERSION=3.47.4
ARG ANDROID_COMMAND_LINE_TOOLS_VERSION=13114758
ARG ANDROID_PLATFORM_VERSION=36
ARG ANDROID_BUILD_TOOLS_VERSION=36.0.0
ARG TARGETARCH
RUN git clone --depth 1 --branch "$FLUTTER_VERSION" \
      https://github.com/flutter/flutter.git "$FLUTTER_HOME" \
    && git -C "$FLUTTER_HOME" switch -c stable \
    && git -C "$FLUTTER_HOME" update-ref refs/remotes/origin/stable HEAD \
    && git -C "$FLUTTER_HOME" config remote.origin.fetch \
      '+refs/heads/stable:refs/remotes/origin/stable' \
    && git -C "$FLUTTER_HOME" config branch.stable.remote origin \
    && git -C "$FLUTTER_HOME" config branch.stable.merge refs/heads/stable \
    && chown -R agent:agent "$FLUTTER_HOME" \
    && if [ "$TARGETARCH" = "amd64" ]; then \
      curl -fsSLo /tmp/android-tools.zip \
        "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_COMMAND_LINE_TOOLS_VERSION}_latest.zip" \
      && mkdir -p "$ANDROID_HOME/cmdline-tools" \
      && unzip -q /tmp/android-tools.zip -d "$ANDROID_HOME/cmdline-tools" \
      && mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest" \
      && rm /tmp/android-tools.zip \
      && yes | sdkmanager --licenses >/dev/null \
      && sdkmanager \
        "platform-tools" \
        "platforms;android-${ANDROID_PLATFORM_VERSION}" \
        "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
      && chown -R agent:agent "$ANDROID_HOME"; \
    fi

USER agent

RUN flutter config --no-analytics \
    && flutter precache --linux \
    && flutter doctor -v

WORKDIR /workspace
