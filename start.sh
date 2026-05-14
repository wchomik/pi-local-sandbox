#!/bin/bash
# Install extensions from PI_EXTENSIONS env var (comma-separated)
# e.g. PI_EXTENSIONS=pi-observability,pi-web-access,pi-subagents
if [ -n "$PI_EXTENSIONS" ]; then
  IFS=',' read -ra EXTS <<< "$PI_EXTENSIONS"
  for ext in "${EXTS[@]}"; do
    ext="$(echo "$ext" | xargs)"  # trim whitespace
    [ -z "$ext" ] && continue
    pi install "npm:$ext" 2>/dev/null
  done
fi

# Build extension flags for pi (e.g., -e pi-observability -e pi-web-access)
EXT_FLAGS=""
if [ -n "$PI_EXTENSIONS" ]; then
  IFS=',' read -ra EXTS <<< "$PI_EXTENSIONS"
  for ext in "${EXTS[@]}"; do
    ext="$(echo "$ext" | xargs)"
    [ -z "$ext" ] && continue
    EXT_FLAGS="$EXT_FLAGS -e $ext"
  done
fi

exec ttyd -p 7681 -W pi $EXT_FLAGS "$@"
