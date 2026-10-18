#!/bin/sh
# Setup: install Ollama + the ellmer R package, then download the model.
set -e

# Ollama (uses the GPU automatically if drivers are present)
if ! command -v ollama >/dev/null 2>&1; then
  if sudo -n true 2>/dev/null; then
    curl -fsSL https://ollama.com/install.sh | sudo sh
  else
    # no root: user-local install
    mkdir -p "$HOME/.local"
    curl -fsSL https://ollama.com/download/ollama-linux-amd64.tgz | tar -xz -C "$HOME/.local"
    export PATH="$HOME/.local/bin:$PATH"
  fi
fi

# The only R package the pipeline needs
Rscript -e 'if (!requireNamespace("ellmer", quietly = TRUE)) install.packages("ellmer", repos = "https://cloud.r-project.org")'

# Start the server if it is not already up (no systemd in containers)
ollama list >/dev/null 2>&1 || { ollama serve >/dev/null 2>&1 & sleep 3; }

# Download the model (~4.7 GB, cached in ~/.ollama)
ollama pull "${MODEL:-qwen2.5:7b}"
