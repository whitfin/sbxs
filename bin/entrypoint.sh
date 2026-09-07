#!/usr/bin/env bash
set -Eeuo pipefail

export CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"
export CODEX_AUTH="${CODEX_HOME}/auth.json"
export CODEX_PAIR="${CODEX_HOME}/paired.lock"

if ! codex login status >/dev/null 2>&1; then
  echo "Codex authentication is required."
  codex login --device-auth
fi

echo "Starting Codex remote control..."
codex remote-control start

if [[ ! -f "${CODEX_PAIR}" ]]; then
  echo "Pairing this worker..."
  codex remote-control pair
  touch $CODEX_PAIR
fi

exec tail -f /dev/null
