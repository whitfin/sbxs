SBXS_AGENTS ?= codex claude opencode
SBXS_ARCHIVES := $(addprefix sbxs-,$(addsuffix .tar,$(SBXS_AGENTS)))

SBXS_VERSION ?= latest
SBXS_REGISTRY ?=
SBXS_REGISTRY := $(patsubst %/,%,$(SBXS_REGISTRY))

ifneq ($(strip $(SBXS_REGISTRY)),)
SBXS_REGISTRY := $(SBXS_REGISTRY)/
endif

.PHONY: build check verify load

build:
	cd src && \
		SBXS_VERSION="$(SBXS_VERSION)" \
		SBXS_REGISTRY="$(SBXS_REGISTRY)" \
		docker buildx bake --load $(SBXS_AGENTS)

check:
	@set -eu; \
	for agent in $(SBXS_AGENTS); do \
		docker run --rm --env SBX_AGENT="$$agent" "$(SBXS_REGISTRY)sbxs/$$agent:$(SBXS_VERSION)" bash -lc '\
			git --version; \
			node --version; \
			python3 --version; \
			go version; \
			java -version; \
			rustc --version; \
			cargo --version; \
			ruby --version; \
			bundle --version; \
			mvn --version; \
			elixir --version; \
			mix --version; \
			erl -noshell -eval "io:format(\"OTP ~s~n\", [erlang:system_info(otp_release)]), halt()."; \
			sqlite3 --version; \
            dart --version; \
			flutter --version; \
			case "$$SBX_AGENT" in \
				codex) \
					test -x /home/agent/.local/bin/codex; \
					test ! -e /usr/local/share/npm-global/lib/node_modules/@openai/codex; \
					codex --version \
					;; \
				claude) \
					test -x /home/agent/.local/bin/claude; \
					test ! -e /usr/local/share/npm-global/lib/node_modules/@anthropic-ai/claude-code; \
					claude --version \
					;; \
				opencode) \
					test -x /home/agent/.local/bin/opencode; \
					test ! -e /usr/local/share/npm-global/lib/node_modules/opencode-ai; \
					opencode --version \
					;; \
			esac'; \
	done

load:
	@set -eu; \
	trap 'rm -f -- $(SBXS_ARCHIVES)' EXIT HUP INT TERM; \
	for agent in $(SBXS_AGENTS); do \
		archive="sbxs-$$agent.tar"; \
		docker image save --output "$$archive" "$(SBXS_REGISTRY)sbxs/$$agent:$(SBXS_VERSION)"; \
		sbx template load "$$archive"; \
		rm -f -- "$$archive"; \
	done

verify: build
	$(MAKE) check \
		SBXS_AGENTS="$(SBXS_AGENTS)" \
		SBXS_REGISTRY="$(SBXS_REGISTRY)" \
		SBXS_VERSION="$(SBXS_VERSION)"
