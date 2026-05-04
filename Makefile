COMPOSE = docker compose
AGENT_SERVICE = pi-agent

# 1. Capture the second word as the directory path
# 2. $(eval $(RUN_ARGS):;@:) tells Make to do nothing with the path target so it doesn't error
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)

# Generate the extension flags (e.g., -e pi-observability -e pi-web-access)
# 1. Read extensions.txt
# 2. Remove comments and empty lines
# 3. Strip the 'npm:' prefix
# 4. Add '-e ' before each name
EXT_FLAGS := $(shell [ -f extensions.txt ] && grep -v '^[[:space:]]*$$' extensions.txt |  grep '^npm' | sed 's/^/-e /' | tr '\n' ' ')

.PHONY: help build up down chat shell

help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

build: ## Build the images
	$(COMPOSE) build

update: ## Build with the newest images
	$(COMPOSE) build --pull

refresh: ## Rebuild the agent (run this after changing extensions.txt)
	$(COMPOSE) build --no-cache $(AGENT_SERVICE)

up: ## Start llama-cpp in the background
	$(COMPOSE) up -d llama-cpp

chat: up ## Start agent in a dir with extensions. Usage: make chat ~/my-project
	@echo "Activating extensions: $(EXT_FLAGS)"
	echo "##########" $(EXT_FLAGS)
	@HOST_PATH=$(if $(RUN_ARGS),$(RUN_ARGS),.) $(COMPOSE) run --rm $(AGENT_SERVICE) pi $(EXT_FLAGS)

shell: up ## Open bash in a dir. Usage: make shell ~/my-project
	@HOST_PATH=$(if $(RUN_ARGS),$(RUN_ARGS),.) $(COMPOSE) run --rm $(AGENT_SERVICE) /bin/bash

down: ## Stop all services
	$(COMPOSE) down

logs: ## View output from containers
	$(COMPOSE) logs -f
