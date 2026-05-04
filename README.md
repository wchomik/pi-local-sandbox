# pi-local-sandbox

A Docker-based local development environment for running the [pi coding agent](https://github.com/mariozechner/pi-coding-agent) with a local LLM — no cloud APIs required.

## Overview

This repo provides a self-contained, sandboxed setup that pairs:

- **llama.cpp server** — serves local LLM models on a GPU via an OpenAI-compatible API
- **pi-agent** — the pi coding agent, configured to use the local LLM endpoint

Everything runs in Docker, making it easy to spin up a private coding assistant with a single command.

## Quick Start

```bash
# Build images
make build

# Start the agent in a project directory
make chat ~/my-project

# Or open a bash shell inside the agent container
make shell ~/my-project

# Stop all services
make down
```

## Commands

| Command | Description |
|---|---|
| `make build` | Build the Docker images |
| `make update` | Build with the newest base images |
| `make refresh` | Rebuild the agent (run after changing `extensions.txt`) |
| `make up` | Start the llama.cpp server in the background |
| `make chat <dir>` | Start the pi agent in a directory with extensions loaded |
| `make shell <dir>` | Open a bash shell inside the agent container |
| `make down` | Stop all services |
| `make logs` | View container output |

## Extensions

Extensions are managed in `extensions.txt`. Add or uncomment lines to install additional pi extensions:

```
npm:pi-observability
npm:pi-web-access
# npm:pi-github
# npm:pi-web-search
```

After editing, run `make refresh` to rebuild the agent image with the new extensions.

## Architecture

```
┌─────────────────────┐         ┌────────────────────────┐
│   llama-cpp server  │◄────────│     pi-agent           │
│   (GPU, port 8080)  │  HTTP   │  (pi coding agent)     │
│   ~/.models:/models │────────►│  PI_LLM_ENDPOINT       │
└─────────────────────┘         │  http://llama-cpp:8080 │
                                │  HOST_PATH:/app        │
                                └────────────────────────┘
```

- **llama.cpp** serves models from `~/.models` with GPU acceleration, running in [router mode](https://huggingface.co/blog/ggml-org/model-management-in-llamacpp) for dynamic model management
- **pi-agent** mounts your project directory at `/app` and persists its config in `~/.pi-sandbox`

## Requirements

- Docker & Docker Compose
- NVIDIA GPU (for llama.cpp CUDA support)
- Local LLM models placed in `~/.models`

## License

MIT — Copyright (c) 2026 Wiktor Chomik
