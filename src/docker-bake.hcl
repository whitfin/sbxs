variable "REGISTRY" {
  default = ""
}

variable "CLAUDE_BASE_IMAGE" {
  default = "docker.io/docker/sandbox-templates:claude-code-docker"
}

variable "CODEX_BASE_IMAGE" {
  default = "docker.io/docker/sandbox-templates:codex-docker"
}

variable "OPENCODE_BASE_IMAGE" {
  default = "docker.io/docker/sandbox-templates:opencode-docker"
}

group "default" {
  targets = ["codex", "claude", "opencode"]
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
  tags     = ["${REGISTRY}sbxs:claude"]
  args = {
    AGENT      = "claude"
    BASE_IMAGE = CLAUDE_BASE_IMAGE
  }
}

target "claude-publish" {
  inherits = ["claude", "publish"]
}

target "codex" {
  inherits = ["common"]
  tags     = ["${REGISTRY}sbxs:codex"]
  args = {
    AGENT      = "codex"
    BASE_IMAGE = CODEX_BASE_IMAGE
  }
}

target "codex-publish" {
  inherits = ["codex", "publish"]
}

target "opencode" {
  inherits = ["common"]
  tags     = ["${REGISTRY}sbxs:opencode"]
  args = {
    AGENT      = "opencode"
    BASE_IMAGE = OPENCODE_BASE_IMAGE
  }
}

target "opencode-publish" {
  inherits = ["opencode", "publish"]
}
