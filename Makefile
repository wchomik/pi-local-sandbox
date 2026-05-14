COMPOSE = docker compose
AGENT_SERVICE = pi-agent

# 1. Capture the second word as the directory path
# 2. $(eval $(RUN_ARGS):;@:) tells Make to do nothing with the path target so it doesn't error
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)

# Comma-separated list of extensions to install and load
# e.g. EXTENSIONS=npm:pi-observability,npm:pi-web-access
EXTENSIONS ?= npm:pi-observability,npm:pi-web-access

# Generate the extension flags (e.g., -e pi-observability -e pi-web-access)
comma := ,
EXT_FLAGS := -e $(subst $(comma), -e ,$(EXTENSIONS))

.PHONY: help build up down chat serve shell logs

help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

build: ## Build the images
	$(COMPOSE) build

update: ## Build with the newest base images
	$(COMPOSE) build --pull

refresh: ## Rebuild the agent (run this after changing dependencies)
	$(COMPOSE) build --no-cache $(AGENT_SERVICE)

up: ## Start llama-cpp in the background
	$(COMPOSE) up -d llama-cpp

chat: up ## Start agent in a dir (interactive terminal). Usage: make chat ~/my-project
	@echo "Extensions: $(EXTENSIONS)"
	@HOST_PATH=$(if $(RUN_ARGS),$(RUN_ARGS),.) PI_EXTENSIONS=$(EXTENSIONS) $(COMPOSE) run --rm $(AGENT_SERVICE) pi $(EXT_FLAGS)

serve: up ## Start agent via ttyd in browser (http://localhost:7681). Usage: make serve ~/my-project
	@echo "Extensions: $(EXTENSIONS)"
	@echo "Open http://localhost:7681 in your browser"
	@HOST_PATH=$(if $(RUN_ARGS),$(RUN_ARGS),.) PI_EXTENSIONS=$(EXTENSIONS) $(COMPOSE) up -d $(AGENT_SERVICE)

shell: up ## Open bash in a dir. Usage: make shell ~/my-project
	@HOST_PATH=$(if $(RUN_ARGS),$(RUN_ARGS),.) PI_EXTENSIONS=$(EXTENSIONS) $(COMPOSE) run --rm $(AGENT_SERVICE) /bin/bash

down: ## Stop all services
	$(COMPOSE) down

logs: ## View output from containers
	$(COMPOSE) logs -f
