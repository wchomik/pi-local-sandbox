# pi-local-sandbox

A Docker-based local development environment for running the [pi coding agent](https://github.com/mariozechner/pi-coding-agent) with a local LLM — no cloud APIs required.

## Overview

This repo provides a self-contained, sandboxed setup that pairs:

- **llama.cpp server** — serves local LLM models on a GPU via an OpenAI-compatible API
- **pi-agent** — the pi coding agent, configured to use the local LLM endpoint

Everything runs in Docker, making it easy to spin up a private coding assistant with a single command. The agent can be used interactively in a terminal or accessed through a browser via ttyd.

## Quick Start

```bash
# Build images
make build

# Start the agent interactively in a terminal
make chat ~/my-project

# Or serve the agent through a browser (http://localhost:7681)
make serve ~/my-project

# Open a bash shell inside the agent container
make shell ~/my-project

# Stop all services
make down
```

## Commands

| Command | Description |
|---|---|
| `make build` | Build the Docker images |
| `make update` | Build with the newest base images |
| `make refresh` | Rebuild the agent (run after changing dependencies) |
| `make up` | Start the llama.cpp server in the background |
| `make chat <dir>` | Start the pi agent interactively in a directory |
| `make serve <dir>` | Start the pi agent via ttyd (browser at http://localhost:7681) |
| `make shell <dir>` | Open a bash shell inside the agent container |
| `make down` | Stop all services |
| `make logs` | View container output |

## Extensions

Extensions are configured via the `EXTENSIONS` variable (comma-separated):

```bash
# Default extensions
make chat ~/my-project

# Custom extensions
make chat EXTENSIONS=pi-observability,pi-web-access,pi-github ~/my-project

# No extensions
make chat EXTENSIONS= ~/my-project
```

Extensions are installed at container startup — no rebuild needed when changing them.

## Architecture

```
┌─────────────────────┐         ┌────────────────────────┐
│   llama-cpp server  │◄────────│     pi-agent           │
│   (GPU, port 8080)  │  HTTP   │  (pi coding agent)     │
│   ~/.models:/models │────────►│  PI_LLM_ENDPOINT       │
└─────────────────────┘         │  http://llama-cpp:8080 │
                                │  HOST_PATH:/app        │
                                │  PI_EXTENSIONS (env)   │
                                └───────────┬────────────┘
                                            │
                                    ┌───────┴────────┐
                                    │  ttyd (port     │
                                    │  7681)          │
                                    │  (serve mode)   │
                                    └─────────────────┘
```

- **llama.cpp** serves models from `~/.models` with GPU acceleration, running in [router mode](https://huggingface.co/blog/ggml-org/model-management-in-llamacpp) for dynamic model management
- **pi-agent** mounts your project directory at `/app` and persists its config in `~/.pi-sandbox`
- **ttyd** provides browser-based terminal access when using `make serve`

## Requirements

- Docker & Docker Compose
- NVIDIA GPU (for llama.cpp CUDA support)
- Local LLM models placed in `~/.models`

## License

MIT — Copyright (c) 2026 Wiktor Chomik
