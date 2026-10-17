#!/bin/sh
# One-command setup. Two paths:
#   - Docker available -> build the image and run the container
#   - No Docker (e.g. a Ucloud VM/app that already has R) -> install Ollama and
#     the ellmer package directly, then run the pipeline. No Docker-in-Docker.
if command -v docker >/dev/null 2>&1; then
  set -e
  docker build -t hostile-rhetoric .
  if command -v nvidia-smi >/dev/null 2>&1; then GPU="--gpus all"; else GPU=""; fi
  docker run --rm $GPU \
    -v "$PWD/output:/app/output" \
    -v "$HOME/.ollama:/root/.ollama" \
    hostile-rhetoric
  exit 0
fi

set -e

# Ollama: local LLM server (uses the GPU automatically if drivers are present)
if ! command -v ollama >/dev/null 2>&1; then
  if sudo -n true 2>/dev/null; then
    curl -fsSL https://ollama.com/install.sh | sudo sh
  else
    # no root: user-local install (tarball holds bin/ollama + lib/ollama)
    mkdir -p "$HOME/.local"
    curl -fsSL https://ollama.com/download/ollama-linux-amd64.tgz | tar -xz -C "$HOME/.local"
    export PATH="$HOME/.local/bin:$PATH"
  fi
fi

# The only R package the pipeline needs
Rscript -e 'if (!requireNamespace("ellmer", quietly = TRUE)) install.packages("ellmer", repos = "https://cloud.r-project.org")'

# Start the server, download the model, run the analysis
sh entrypoint.sh
