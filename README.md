# sbxs

A small set of extended templates for [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) with OpenCode, Codex and Claude Code.

Docker's agent bases already supply Node.js, Python with `uv`, Go, Java, Git, and a Docker engine. This template adds:

- A native C/C++ build toolchain: GCC, Clang, Make, CMake, Ninja, and `pkg-config`
- Rust stable through `rustup`, including Cargo, Clippy, and `rustfmt`
- Flutter stable and its bundled Dart SDK for package resolution and static analysis
- Ruby, Ruby headers, and Bundler
- Maven and Gradle projects via `./gradlew`
- SQLite CLI and development headers

Codex, Claude Code, and OpenCode are reinstalled through their vendors' standalone Linux installers after their inherited global npm packages are removed. This fixes several issues (specifically with Codex) related to `remote-control` and generally keeps things more uniform.

## Prerequisites

Install Docker Desktop and its `sbx` CLI, then authenticate each agent you intend to use. Docker Sandboxes keeps its template image store separate from the ordinary Docker daemon, so locally built images must be exported and loaded before use.

## Build the images

Build, check, and load all three images for the host architecture:

```bash
$ make build
$ make check
$ make load
```

`make build` runs the Bake matrix from `src`, so the three variants build together from `src/Dockerfile`. `make matrix` is an alias for the same operation. The resulting images are `sbxs:codex`, `sbxs:claude`, and `sbxs:opencode`.

The matrix bases can also be overridden independently:

```bash
CODEX_BASE_IMAGE=example/codex-base:latest \
CLAUDE_BASE_IMAGE=example/claude-base:latest \
OPENCODE_BASE_IMAGE=example/opencode-base:latest \
  make build
```

Each override must remain paired with its corresponding agent because Docker Sandbox startup behavior comes from the base template.

`make load` loads each image into Docker Sandboxes and deletes its temporary tar archive immediately afterward.

## Run the images

After building and loading the templates, create your initial sandboxes:

```bash
$ sbx create --name codex --template sbxs:codex codex . "$HOME/.codex/config.toml:rw"
$ sbx create --name claude --template sbxs:claude claude . "$HOME/.claude/settings.json:rw"
$ sbx create --name opencode --template sbxs:opencode opencode . "$HOME/.config/opencode/opencode.json:rw"
```

Successful builds on `main` publish multi-platform (`linux/amd64` and `linux/arm64`) templates to GitHub Container Registry:

```bash
$ sbx create --name codex --template ghcr.io/whitfin/sbxs:codex codex . "$HOME/.codex/config.toml:rw"
$ sbx create --name claude --template ghcr.io/whitfin/sbxs:claude claude . "$HOME/.claude/settings.json:rw"
$ sbx create --name opencode --template ghcr.io/whitfin/sbxs:opencode opencode . "$HOME/.config/opencode/opencode.json:rw"
```

Then you can attach to your sandbox at any time:

```bash
$ sbx run --name codex
$ sbx run --name claude
$ sbx run --name opencode
```

To replace a named sandbox after rebuilding its template, remove or rename the existing sandbox and run `sbx create` again. Existing sandboxes retain the filesystem created from the older template.
