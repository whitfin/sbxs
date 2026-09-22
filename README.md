# sbxs

A small set of extended templates for [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) with OpenCode, Codex and Claude Code.

Docker's agent bases already supply Node.js, Python with `uv`, Go, Java, Git, and a Docker engine. This template adds:

- A native C/C++ build toolchain: GCC, Clang, Make, CMake, Ninja, and `pkg-config`
- Rust stable through `rustup`, including Cargo, Clippy, and `rustfmt`
- Flutter stable and its bundled Dart SDK for package resolution and static analysis
- Ruby, Ruby headers, and Bundler
- Elixir, Erlang/OTP, Hex, and Rebar
- Maven and Gradle projects via `./gradlew`
- SQLite CLI and development headers

Codex, Claude Code, and OpenCode are reinstalled through their vendors' standalone Linux installers after their inherited global npm packages are removed. This fixes several issues (specifically with Codex) related to `remote-control` and generally keeps things more uniform.

## Build the images

Build, verify, and load all images for the host architecture:

```bash
$ make build
$ make check
$ make load
```

This creates local `sbxs:<agent>` images for each supported agent. You can build only specific agents or use custom base images:

```bash
SBXS_AGENTS="claude codex" \
SBXS_REGISTRY=ghcr.io/whitfin \
SBXS_CODEX_BASE_IMAGE=example/codex-base:latest \
SBXS_CLAUDE_BASE_IMAGE=example/claude-base:latest \
SBXS_OPENCODE_BASE_IMAGE=example/opencode-base:latest \
  make build
```

By default, all supported agents are built using the latest Docker Sandbox image (e.g. `sandbox-templates:codex-docker`).

## Run the images

After building and loading the templates, create your initial sandboxes:

```bash
$ sbx create --name codex --template sbxs/codex codex . "$HOME/.codex/config.toml:rw"
$ sbx create --name claude --template sbxs/claude claude . "$HOME/.claude/settings.json:rw"
$ sbx create --name opencode --template sbxs/opencode opencode . "$HOME/.config/opencode/opencode.json:rw"
```

Successful builds on `main` publish multi-platform (`linux/amd64` and `linux/arm64`) templates with the `latest` tag.

```bash
$ sbx create --name codex --template ghcr.io/whitfin/sbxs/codex:latest codex "$PWD" "$HOME/.codex/config.toml:rw"
$ sbx create --name claude --template ghcr.io/whitfin/sbxs/claude:latest claude "$PWD" "$HOME/.claude/settings.json:rw"
$ sbx create --name opencode --template ghcr.io/whitfin/sbxs/opencode:latest opencode "$PWD" "$HOME/.config/opencode/opencode.json:rw"
```

For a pinned release, replace `latest` with a published tag such as `1.2.3`. Then you can attach to your sandbox at any time:

```bash
$ sbx run --name codex
$ sbx run --name claude
$ sbx run --name opencode
```

To replace a named sandbox after rebuilding its template, remove or rename the existing sandbox and run `sbx create` again. Existing sandboxes retain the filesystem created from the older template.
