# Codex Worker

This small project contains a Docker container designed for remote Codex work.

The container is based on a Microsoft Dev Container image, with the simple
addition of Codex and automated launch/pairing of ChatGPT/Codex.

## Getting Started

Copy the environment template and set your workspace path:

```sh
cp .env.example .env
# Edit WORKSPACE_PATH in .env
```

Then build and start the worker as shown below:

```sh
docker compose up --build
```

The first launch will display any pairing configuration and endpoints to open
on your host, and once you do so you should be able to execute code remotely
via ChatGPT/Codex on your host machine.

## Session State

A volume mount is used for the Codex authentication and/or session information,
so handshakes only occur on first launch. If this volume is remove, you'll have
to go ahead with a fresh handshake.
