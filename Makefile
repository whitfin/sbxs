SBXS_AGENTS ?= codex claude opencode
SBXS_ARCHIVES := $(addprefix sbxs-,$(addsuffix .tar,$(SBXS_AGENTS)))

SBXS_VERSION ?= latest
SBXS_REGISTRY ?=
SBXS_REGISTRY := $(patsubst %/,%,$(SBXS_REGISTRY))

ifneq ($(strip $(SBXS_REGISTRY)),)
SBXS_REGISTRY := $(SBXS_REGISTRY)/
endif

.PHONY: build check install

build:
	cd src && \
		SBXS_VERSION="$(SBXS_VERSION)" \
		SBXS_REGISTRY="$(SBXS_REGISTRY)" \
		docker buildx bake --load $(SBXS_AGENTS)

check:
	@set -eu; \
	for agent in $(SBXS_AGENTS); do \
		docker run --rm --env SBX_AGENT="$$agent" "$(SBXS_REGISTRY)sbxs/$$agent:$(SBXS_VERSION)" sbxs-check; \
	done

install:
	@set -eu; \
	trap 'rm -f -- $(SBXS_ARCHIVES)' EXIT HUP INT TERM; \
	for agent in $(SBXS_AGENTS); do \
		archive="sbxs-$$agent.tar"; \
		docker image save --output "$$archive" "$(SBXS_REGISTRY)sbxs/$$agent:$(SBXS_VERSION)"; \
		sbx template load "$$archive"; \
		rm -f -- "$$archive"; \
	done
