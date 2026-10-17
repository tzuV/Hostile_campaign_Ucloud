#!/bin/sh
# One-command setup: build the image, download the model, run the analysis.
set -e
docker build -t hostile-rhetoric .
if command -v nvidia-smi >/dev/null 2>&1; then GPU="--gpus all"; else GPU=""; fi
docker run --rm $GPU \
  -v "$PWD/output:/app/output" \
  -v "$HOME/.ollama:/root/.ollama" \
  hostile-rhetoric
