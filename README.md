# sbxs

A small set of extended templates for [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) with OpenCode, Codex and Claude Code.

The templates built from this repository add the following to the `sbx` base images:

- A native C/C++ build toolchain: GCC, Clang, Make, CMake, Ninja, and `pkg-config`
- Rust stable through `rustup`, including Cargo, Clippy, and `rustfmt`
- Flutter stable and its bundled Dart SDK for package resolution and static analysis
- Ruby, Ruby headers, and Bundler
- Elixir, Erlang/OTP, Hex, and Rebar
- Maven and Gradle projects via `./gradlew`
- SQLite CLI and development headers

Codex, Claude Code, and OpenCode are reinstalled through their vendors' standalone Linux installers after their inherited global npm packages are removed. This fixes several issues (specifically with Codex) related to `remote-control` and generally keeps things more uniform.

## Starting a sandbox

You can create a sandbox from the latest published image very easily:

```shell
sbx run -t ghcr.io/whitfin/sbxs/codex:latest codex
sbx run -t ghcr.io/whitfin/sbxs/claude:latest claude
sbx run -t ghcr.io/whitfin/sbxs/opencode:latest opencode
```

The GHCR images support both `linux/amd64` and `linux/arm64` and are published by CI from main.

## Build the images

If you want to customize and build images for yourself:

```shell
make build
make install
```

You can build for specific agents or using custom base images via environment and/or Make variables:

```shell
export SBXS_AGENTS="claude codex"
export SBXS_REGISTRY="ghcr.io/whitfin"
export SBXS_CODEX_BASE_IMAGE="example/codex-base:latest"
export SBXS_CLAUDE_BASE_IMAGE="example/claude-base:latest"
export SBXS_OPENCODE_BASE_IMAGE="example/opencode-base:latest"
```

By default, all supported agents are built using the latest Docker Sandbox image (e.g. `sandbox-templates:codex-docker`) and will be tagged in the form `sbxs/<agent>:latest`.

## Contributions

Any feedback or contributions are appreciated; this repository is deliberately pretty opinionated as I'm mainly just sharing my personal setup, but I'm happy to expand and adjust things if they'd be useful to a wider audience.
