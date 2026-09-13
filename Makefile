AGENTS := codex claude opencode
ARCHIVES := $(addprefix sbxs-,$(addsuffix .tar,$(AGENTS)))

.PHONY: build matrix check export load

build:
	cd src && docker buildx bake

matrix: build

check:
	@set -eu; \
	for agent in $(AGENTS); do \
		docker run --rm --env AGENT_TO_CHECK="$$agent" "sbxs:$$agent" bash -lc '\
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
			gradle --version; \
			sqlite3 --version; \
			flutter --version; \
			case "$$AGENT_TO_CHECK" in \
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

export:
	@set -eu; \
	for agent in $(AGENTS); do \
		docker image save --output "sbxs-$$agent.tar" "sbxs:$$agent"; \
	done

load:
	@set -eu; \
	trap 'rm -f -- $(ARCHIVES)' EXIT HUP INT TERM; \
	for agent in $(AGENTS); do \
		archive="sbxs-$$agent.tar"; \
		docker image save --output "$$archive" "sbxs:$$agent"; \
		sbx template load "$$archive"; \
		rm -f -- "$$archive"; \
	done
