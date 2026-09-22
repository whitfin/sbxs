variable "SBXS_VERSION" {
  default = "latest"
}

variable "SBXS_REGISTRY" {
  default = ""
}

variable "SBXS_CLAUDE_BASE_IMAGE" {
  default = "docker.io/docker/sandbox-templates:claude-code-docker"
}

variable "SBXS_CODEX_BASE_IMAGE" {
  default = "docker.io/docker/sandbox-templates:codex-docker"
}

variable "SBXS_OPENCODE_BASE_IMAGE" {
  default = "docker.io/docker/sandbox-templates:opencode-docker"
}

group "default" {
  targets = [
    "codex",
    "claude",
    "opencode"
  ]
}

target "common" {
  context    = "."
  dockerfile = "Dockerfile"
}

target "publish" {
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}

target "claude" {
  inherits = ["common"]
  tags     = ["${SBXS_REGISTRY}sbxs/claude:${SBXS_VERSION}"]
  args = {
    AGENT      = "claude"
    BASE_IMAGE = SBXS_CLAUDE_BASE_IMAGE
  }
}

target "claude-publish" {
  inherits = ["claude", "publish"]
}

target "codex" {
  inherits = ["common"]
  tags     = ["${SBXS_REGISTRY}sbxs/codex:${SBXS_VERSION}"]
  args = {
    AGENT      = "codex"
    BASE_IMAGE = SBXS_CODEX_BASE_IMAGE
  }
}

target "codex-publish" {
  inherits = ["codex", "publish"]
}

target "opencode" {
  inherits = ["common"]
  tags     = ["${SBXS_REGISTRY}sbxs/opencode:${SBXS_VERSION}"]
  args = {
    AGENT      = "opencode"
    BASE_IMAGE = SBXS_OPENCODE_BASE_IMAGE
  }
}

target "opencode-publish" {
  inherits = ["opencode", "publish"]
}
